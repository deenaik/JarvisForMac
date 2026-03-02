# Jarvis for Mac

A macOS personal AI assistant that runs as a CLI agent, automating Mac workflows via shell commands, AppleScript, Shortcuts, and more. Uses OpenRouter for LLM reasoning with tool calling.

## Tech Stack

- **Language**: TypeScript (strict mode), ESM (`"type": "module"`)
- **Runtime**: Node.js + tsx (no compile step needed)
- **LLM**: OpenRouter API (OpenAI-compatible, native tool/function calling)
- **Database**: better-sqlite3 (synchronous, WAL mode, no server)
- **Mac Automation**: osascript (AppleScript/JXA)
- **Package Manager**: npm

## Running

```bash
npx tsx jarvis.ts        # Interactive CLI
npm start                # Same thing
```

## Project Structure

```
jarvis.ts                  # CLI entry point (readline loop)
config/
  openrouter.ts            # API key, base URL, model selection
  database.ts              # DB path, schema version
  jarvis.ts                # System prompt, MAX_AGENT_STEPS, TOOL_TIMEOUT_MS
  mcp.ts                   # MCP server definitions (Phase 2)
models/
  OpenRouterTypes.ts       # Request/Response/ToolCall/ToolDefinition types
  AgentTypes.ts            # Conversation, AgentStep, ToolCall, ToolResult, AgentResponse
  ToolTypes.ts             # Tool interface + ToolDefinition
  MemoryTypes.ts           # Episodic/Semantic/Procedural memory types (Phase 3)
services/
  openrouter-client.ts     # OpenRouter fetch client (chatCompletion + chatCompletionWithTools)
  agent-loop.ts            # ReAct loop: reason -> tool calls -> observe -> repeat
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
```

## Architecture

### Agent Loop (`services/agent-loop.ts`)
ReAct pattern: the LLM decides which tools to call, executes them, feeds results back, and repeats until it has a final text answer or hits `MAX_AGENT_STEPS` (25).

### Tool System
Every tool implements the `Tool` interface from `models/ToolTypes.ts`:
```ts
interface Tool {
  definition: ToolDefinition;  // name, description, JSON Schema parameters
  execute(args: Record<string, unknown>): Promise<string>;
}
```
Tools are registered in `services/tool-registry.ts`, which converts them to OpenRouter's function calling format and dispatches execution with timeout protection.

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

- **ESM imports**: All imports use `.js` extension (`import { foo } from './bar.js'`) — tsx resolves `.js` → `.ts` at runtime
- **Strict TypeScript**: `strict: true` in tsconfig.json
- **Type-only imports**: Use `import type { Foo }` when importing only types
- **Singleton services**: Services export both the class and a singleton instance (`export const fooService = new FooService()`)
- **Tool pattern**: Each tool file exports a named const (e.g., `export const shellTool: Tool = { ... }`)
- **No classes for tools**: Tools are plain objects implementing the `Tool` interface
- **Config from env**: All secrets/config via `process.env` loaded through `dotenv/config`
- **Sync database**: All better-sqlite3 operations are synchronous (no async/await for DB)
- **Error handling in tools**: Tools never throw — they return error strings so the LLM can reason about failures

## Phases

- **Phase 1**: CLI agent + basic tools — COMPLETE
- **Phase 2**: MCP client (`@modelcontextprotocol/sdk`) + Claude Code CLI + Chrome browser automation
- **Phase 3**: Memory system (episodic/semantic/procedural) + `sqlite-vec` vector search + RAG context injection
- **Phase 4**: Voice interface (Swift `SFSpeechRecognizer` STT + macOS `say` TTS)
- **Phase 5**: Menu bar UI (Tauri v2, global hotkey, chat popover)
- **Phase 6**: Background daemon (launchd) + scheduled tasks + self-learning

## Common Tasks

```bash
# Run the CLI
npx tsx jarvis.ts

# Reset the database (delete and re-create on next run)
rm -f data/jarvis.db

# Check TypeScript types without running
npx tsc --noEmit
```
