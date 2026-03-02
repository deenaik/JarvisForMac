# Jarvis for Mac

A macOS personal AI assistant that runs as a CLI agent and a native SwiftUI app, automating Mac workflows via shell commands, AppleScript, Shortcuts, and more. Uses OpenRouter for LLM reasoning with tool calling.

## Tech Stack

- **Language**: TypeScript (strict mode), ESM (`"type": "module"`) + Swift/SwiftUI (native app)
- **Runtime**: Node.js + tsx (no compile step needed)
- **LLM**: OpenRouter API (OpenAI-compatible, native tool/function calling)
- **Database**: better-sqlite3 (synchronous, WAL mode, no server)
- **Mac Automation**: osascript (AppleScript/JXA)
- **Native App**: SwiftUI + NSPanel + Carbon hotkeys (macOS 14+)
- **IPC**: NDJSON over stdin/stdout (Swift ↔ Node.js)
- **Package Manager**: npm (Node.js), Xcode (Swift)

## Running

```bash
npx tsx jarvis.ts          # Interactive CLI
npm start                  # Same thing
npx tsx jarvis-server.ts   # IPC server (used by native app)
```

Native app: open `JarvisApp/JarvisApp.xcodeproj` in Xcode and Run, or:
```bash
cd JarvisApp && xcodebuild -scheme JarvisApp -configuration Debug build
```

## Project Structure

```
jarvis.ts                  # CLI entry point (readline loop)
jarvis-server.ts           # NDJSON-over-stdio server for the Swift app
config/
  openrouter.ts            # API key, base URL, model selection
  database.ts              # DB path, schema version
  jarvis.ts                # System prompt, MAX_AGENT_STEPS, TOOL_TIMEOUT_MS
  mcp.ts                   # MCP server definitions (Phase 2)
models/
  OpenRouterTypes.ts       # Request/Response/ToolCall/ToolDefinition types
  AgentTypes.ts            # Conversation, AgentStep, ToolCall, ToolResult, ProgressCallback
  ToolTypes.ts             # Tool interface + ToolDefinition
  MemoryTypes.ts           # Episodic/Semantic/Procedural memory types (Phase 3)
services/
  openrouter-client.ts     # OpenRouter fetch client (chatCompletion + chatCompletionWithTools)
  agent-loop.ts            # ReAct loop with optional onProgress callback
  tool-registry.ts         # Register/lookup/execute tools, converts to OpenRouter format
  conversation-manager.ts  # Message history, SQLite persistence, truncation at 100 msgs
  database.ts              # better-sqlite3 init, schema, WAL mode, state helpers
  mcp-client.ts            # MCP server connections (Phase 2 stub)
  memory-service.ts        # Memory storage/retrieval (Phase 3 stub)
  embedding-service.ts     # Embedding generation (Phase 3 stub)
  vector-store.ts          # sqlite-vec vector search (Phase 3 stub)
  voice-service.ts         # STT + TTS (Phase 4 stub)
  scheduler.ts             # Periodic task runner (Phase 6 stub)
tools/
  shell.ts                 # Execute shell commands via execFile('/bin/zsh')
  file-read.ts             # Read files (1MB max)
  file-write.ts            # Write/append files, creates parent dirs
  applescript.ts           # Execute AppleScript or JXA via osascript
  shortcuts.ts             # List/run macOS Shortcuts
  web-search.ts            # Web search via DuckDuckGo HTML scraping
  claude-code.ts           # Invoke `claude -p` for coding tasks (Phase 2 stub)
  browser.ts               # Chrome automation via AppleScript (Phase 2 stub)
  mcp-tool.ts              # Dynamic MCP tool registration (Phase 2 stub)
  memory-query.ts          # Search knowledge base (Phase 3 stub)
  memory-store.ts          # Store facts/preferences (Phase 3 stub)
helpers/
  stt.swift                # Swift speech-to-text helper (Phase 4 stub)
data/                      # SQLite database (gitignored, auto-created)

JarvisApp/                 # Native macOS SwiftUI app
  JarvisApp.xcodeproj/     # Xcode project (macOS 14+, no sandbox, LSUIElement)
  JarvisApp/
    App/
      JarvisAppMain.swift      # @main, MenuBarExtra + AppDelegate adaptor
      AppDelegate.swift        # NSPanel setup, hotkey wiring, lifecycle
      AppState.swift           # ObservableObject state machine (idle/listening/thinking/speaking/error)
    Views/
      FloatingPanelView.swift  # Main container (header + chat + input)
      ChatView.swift           # Scrollable message list with auto-scroll
      MessageBubbleView.swift  # Individual message bubble + thinking dots
      InputBarView.swift       # Text field + send button + mic button
      WaveformView.swift       # Sine wave animation driven by audio level
      StatusMenuView.swift     # Menu bar dropdown (show/hide, new convo, quit)
    Services/
      NodeBridge.swift         # Spawns Node.js subprocess, NDJSON IPC, auto-restart
      SpeechRecognizer.swift   # SFSpeechRecognizer + AVAudioEngine, push-to-talk
      SpeechSynthesizer.swift  # AVSpeechSynthesizer with markdown stripping
      HotkeyManager.swift      # Global Cmd+Shift+J via Carbon RegisterEventHotKey
    Models/
      JarvisMessage.swift      # Chat message (role, text, isThinking, timestamp)
      IPCProtocol.swift        # Codable structs for NDJSON request/response
    Resources/
      Assets.xcassets/         # App icon, menu bar icons
      Jarvis.entitlements      # Microphone access
    Info.plist                 # LSUIElement=YES, speech/mic usage descriptions
```

## Architecture

### Agent Loop (`services/agent-loop.ts`)
ReAct pattern: the LLM decides which tools to call, executes them, feeds results back, and repeats until it has a final text answer or hits `MAX_AGENT_STEPS` (25). Accepts an optional `onProgress` callback for streaming tool_start/tool_result events to the native app.

### Tool System
Every tool implements the `Tool` interface from `models/ToolTypes.ts`:
```ts
interface Tool {
  definition: ToolDefinition;  // name, description, JSON Schema parameters
  execute(args: Record<string, unknown>): Promise<string>;
}
```
Tools are registered in `services/tool-registry.ts`, which converts them to OpenRouter's function calling format and dispatches execution with timeout protection.

**Important**: When adding a new tool, register it in **both** `jarvis.ts` and `jarvis-server.ts`.

### IPC Protocol (NDJSON over stdin/stdout)
The native app spawns `jarvis-server.ts` as a subprocess. Communication is newline-delimited JSON:

- **Swift → Node.js**: `{"id":"uuid","type":"query","text":"..."}` or `{"type":"new_conversation"}`
- **Node.js → Swift**: `{"type":"ready"}`, `{"type":"tool_start",...}`, `{"type":"tool_result",...}`, `{"type":"response","text":"..."}`, `{"type":"error","message":"..."}`

### Native App Architecture
- **NSPanel** (not SwiftUI Window) for floating, non-activating, borderless panel with .ultraThinMaterial
- **MenuBarExtra** with SF Symbol icons that change per `AppState.assistantState`
- **Carbon `RegisterEventHotKey`** for the global Cmd+Shift+J hotkey
- **`NodeBridge.swift`** manages the Node.js subprocess lifecycle including auto-restart on crash
- **`AppState.swift`** is the central `@MainActor ObservableObject` state machine
- **LSUIElement=YES** — no dock icon, menu bar app only
- **App Sandbox disabled** for dev (required for subprocess spawning)

### Model Selection
- Default: `google/gemini-2.0-flash-001` (fast, cheap — used for steps 1-10)
- Complex: `anthropic/claude-sonnet-4` (auto-escalated after step 10)
- Configured in `config/openrouter.ts`

### Database Schema (SQLite)
- `conversations` — conversation metadata (id, timestamps)
- `messages` — individual messages with role, content, tool_calls, tool_call_id
- `agent_state` — key-value store for persistent state
- `schema_version` — migration tracking

## Code Conventions

### TypeScript (Node.js backend)
- **ESM imports**: All imports use `.js` extension (`import { foo } from './bar.js'`) — tsx resolves `.js` → `.ts` at runtime
- **Strict TypeScript**: `strict: true` in tsconfig.json
- **Type-only imports**: Use `import type { Foo }` when importing only types
- **Singleton services**: Services export both the class and a singleton instance (`export const fooService = new FooService()`)
- **Tool pattern**: Each tool file exports a named const (e.g., `export const shellTool: Tool = { ... }`)
- **No classes for tools**: Tools are plain objects implementing the `Tool` interface
- **Config from env**: All secrets/config via `process.env` loaded through `dotenv/config`
- **Sync database**: All better-sqlite3 operations are synchronous (no async/await for DB)
- **Error handling in tools**: Tools never throw — they return error strings so the LLM can reason about failures
- **Dual registration**: New tools must be registered in both `jarvis.ts` and `jarvis-server.ts`

### Swift (Native app)
- **`@MainActor`**: All UI-facing classes use `@MainActor` for thread safety
- **ObservableObject**: `AppState` is the single source of truth, used via `@EnvironmentObject`
- **NSPanel via AppDelegate**: Panel setup uses `NSApplicationDelegateAdaptor`, not SwiftUI `Window`
- **Codable for IPC**: All IPC types are Codable structs in `Models/IPCProtocol.swift`
- **os.Logger**: Use `Logger(subsystem:category:)` for debug logging, not `print()`

## Phases

- **Phase 1**: CLI agent + basic tools — COMPLETE
- **Native App**: SwiftUI floating panel + menu bar + hotkey + voice — COMPLETE
- **Phase 2**: MCP client (`@modelcontextprotocol/sdk`) + Claude Code CLI + Chrome browser automation
- **Phase 3**: Memory system (episodic/semantic/procedural) + `sqlite-vec` vector search + RAG context injection
- **Phase 6**: Background daemon (launchd) + scheduled tasks + self-learning

## Common Tasks

```bash
# Run the CLI
npx tsx jarvis.ts

# Run the IPC server (for native app or testing)
npx tsx jarvis-server.ts

# Test IPC server
echo '{"id":"1","type":"query","text":"hello"}' | npx tsx jarvis-server.ts

# Reset the database (delete and re-create on next run)
rm -f data/jarvis.db

# Check TypeScript types without running
npx tsc --noEmit

# Build native app
cd JarvisApp && xcodebuild -scheme JarvisApp -configuration Debug build
```
