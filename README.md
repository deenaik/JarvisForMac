# Jarvis for Mac

A personal AI assistant for macOS that automates workflows via shell commands, AppleScript, Shortcuts, and more. Powered by OpenRouter with native tool calling.

Jarvis runs as both a **CLI agent** and a **native macOS app** — a Siri-like floating panel with global hotkey, menu bar icon, voice input/output, and chat interface. The Node.js backend handles reasoning and tool execution; the Swift app communicates with it over JSON IPC.

## Features

- **Shell commands** — run any terminal command
- **File operations** — read, write, and manage files
- **AppleScript/JXA** — control any macOS application (Finder, Safari, Mail, etc.)
- **macOS Shortcuts** — list and run your Shortcuts
- **Web search** — search the web via DuckDuckGo
- **Multi-step reasoning** — chains multiple tools automatically
- **Conversation persistence** — chat history stored in SQLite
- **Model escalation** — uses fast models for simple tasks, stronger models for complex ones
- **Native macOS app** — floating panel, menu bar icon, global hotkey (Cmd+Shift+J)
- **Voice input/output** — speech recognition (STT) and text-to-speech (TTS)

## Getting Started

### Prerequisites

- **Node.js** v18+ (tested with v24)
- **macOS 14+** (AppleScript/Shortcuts tools and the native app require macOS)
- **Xcode 16+** (only needed to build the native app)
- **OpenRouter API key** — get one at [openrouter.ai](https://openrouter.ai)

### Installation

```bash
# Clone the repo
git clone <repo-url> JarvisForMac
cd JarvisForMac

# Install dependencies
npm install

# Set your API key
cp .env.example .env   # or just edit .env directly
# Edit .env and set: OPENROUTER_API_KEY=sk-or-v1-your-key-here
```

### Running the CLI

```bash
npx tsx jarvis.ts
```

Or use the npm script:

```bash
npm start
```

### Running the Native App

```bash
# Build the app
cd JarvisApp
xcodebuild -project JarvisApp.xcodeproj -scheme JarvisApp -configuration Debug build

# Run it (from Xcode, or find the .app in DerivedData)
open ~/Library/Developer/Xcode/DerivedData/JarvisApp-*/Build/Products/Debug/JarvisApp.app
```

Or open `JarvisApp/JarvisApp.xcodeproj` in Xcode and press Run.

The app appears as a menu bar icon (brain icon). Press **Cmd+Shift+J** to toggle the floating chat panel.

### Try it out

```
You: What time is it?
You: List my Desktop files
You: Create a file /tmp/hello.txt with "Hello, World!"
You: Open Safari
You: What Shortcuts do I have?
You: Find all .ts files in this project and count them
```

Type `new` to start a fresh conversation, or `quit` to exit (CLI only).

## Development

### Project Structure

```
jarvis.ts                  # CLI entry point
jarvis-server.ts           # JSON-over-stdio server (IPC for native app)
config/                    # Configuration (API keys, DB, system prompt)
models/                    # TypeScript type definitions
services/                  # Core services (agent loop, OpenRouter, DB, tools)
tools/                     # Tool implementations
helpers/                   # Native helpers (Swift STT)
data/                      # SQLite database (auto-created, gitignored)

JarvisApp/                 # Native macOS SwiftUI app
  JarvisApp.xcodeproj/     # Xcode project
  JarvisApp/
    App/                   # App entry, delegate, state machine
    Views/                 # SwiftUI views (chat, input, waveform, menu)
    Services/              # Node bridge, speech, hotkey manager
    Models/                # IPC protocol, message model
    Resources/             # Assets, entitlements, Info.plist
```

### Tech Stack

| Layer          | Choice              | Why                                      |
|----------------|---------------------|------------------------------------------|
| Language       | TypeScript (strict) | Type safety, best MCP SDK support        |
| Runtime        | Node.js + tsx       | Fast dev cycle, no compile step          |
| LLM API        | OpenRouter          | 400+ models via single API               |
| Agent Pattern  | Custom ReAct loop   | Simple, debuggable, no framework bloat   |
| Database       | better-sqlite3      | Synchronous, fast, no server             |
| Mac Automation | osascript           | Built into every Mac                     |
| Native App     | Swift/SwiftUI       | First-class macOS APIs, NSPanel, Carbon hotkeys |
| IPC            | NDJSON over stdio   | Simplest, no sockets/ports needed        |
| Voice (STT)    | SFSpeechRecognizer  | On-device, privacy-friendly              |
| Voice (TTS)    | AVSpeechSynthesizer | Built-in callbacks, no subprocess        |

### Key Commands

```bash
# Run the CLI agent
npx tsx jarvis.ts

# Run the IPC server (used by native app, also useful for testing)
npx tsx jarvis-server.ts

# Type-check without running
npx tsc --noEmit

# Build native app
cd JarvisApp && xcodebuild -scheme JarvisApp -configuration Debug build

# Reset the database
rm -f data/jarvis.db

# Test IPC server directly
echo '{"id":"1","type":"query","text":"hello"}' | npx tsx jarvis-server.ts
```

### Adding a New Tool

1. Create `tools/my-tool.ts` implementing the `Tool` interface:

```ts
import type { Tool } from '../models/ToolTypes.js';

export const myTool: Tool = {
  definition: {
    name: 'my_tool',
    description: 'What this tool does',
    parameters: {
      type: 'object',
      properties: {
        arg1: { type: 'string', description: 'Description of arg1' },
      },
      required: ['arg1'],
    },
  },
  async execute(args: Record<string, unknown>): Promise<string> {
    const arg1 = args.arg1 as string;
    return 'result';
  },
};
```

2. Register it in **both** `jarvis.ts` and `jarvis-server.ts`:

```ts
import { myTool } from './tools/my-tool.js';
// in registerTools():
toolRegistry.register(myTool);
```

The tool is automatically available to the LLM in both CLI and native app modes.

### Architecture

**Agent loop** (`services/agent-loop.ts`):

1. User message is added to conversation history
2. Full history + tool definitions are sent to OpenRouter
3. If the LLM returns `tool_calls` → execute each tool → add results → go to step 2
4. If the LLM returns text (no tool calls) → return the response to the user
5. Safety limit: max 25 steps per request

**IPC protocol** (NDJSON over stdin/stdout):

```
Swift → Node.js:  {"id":"uuid","type":"query","text":"What time is it?"}
Node.js → Swift:  {"id":"uuid","type":"tool_start","toolName":"shell","step":1}
Node.js → Swift:  {"id":"uuid","type":"tool_result","toolName":"shell","step":1,"success":true}
Node.js → Swift:  {"id":"uuid","type":"response","text":"It's 3:42 PM.","totalSteps":2}
```

**Native app architecture**:

- `NodeBridge.swift` spawns `jarvis-server.ts` as a subprocess, manages stdin/stdout pipes
- `AppState.swift` is the central `ObservableObject` state machine (idle/listening/thinking/speaking/error)
- `AppDelegate.swift` creates the floating `NSPanel` (borderless, .ultraThinMaterial)
- `HotkeyManager.swift` registers Cmd+Shift+J via Carbon `RegisterEventHotKey`
- The menu bar icon (SF Symbols) changes per state: brain/mic/ellipsis/speaker/warning

### Models

Configured in `config/openrouter.ts`:

- **Default**: `google/gemini-2.0-flash-001` — fast and cheap for most tasks
- **Complex**: `anthropic/claude-sonnet-4` — auto-escalated after 10 reasoning steps

Change models by editing the constants, or add new task complexity tiers in `getModelForTask()`.

## Roadmap

- [x] **Phase 1**: CLI agent + basic tools (shell, files, AppleScript, Shortcuts, web search)
- [ ] **Phase 2**: MCP client + Claude Code CLI integration + Chrome browser automation
- [ ] **Phase 3**: Memory system (episodic/semantic/procedural) + vector search + RAG
- [x] **Native App**: SwiftUI floating panel, menu bar, Cmd+Shift+J hotkey, voice I/O
- [ ] **Phase 6**: Background daemon + scheduled tasks + self-learning

## License

Private project.
