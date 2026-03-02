# Jarvis for Mac

A personal AI assistant for macOS that automates workflows via shell commands, AppleScript, Shortcuts, and more. Powered by OpenRouter with native tool calling.

Jarvis runs as a CLI agent that reasons step-by-step (ReAct pattern), calls tools to interact with your Mac, and chains operations to accomplish complex tasks.

## Features

- **Shell commands** — run any terminal command
- **File operations** — read, write, and manage files
- **AppleScript/JXA** — control any macOS application (Finder, Safari, Mail, etc.)
- **macOS Shortcuts** — list and run your Shortcuts
- **Web search** — search the web via DuckDuckGo
- **Multi-step reasoning** — chains multiple tools automatically
- **Conversation persistence** — chat history stored in SQLite
- **Model escalation** — uses fast models for simple tasks, stronger models for complex ones

## Getting Started

### Prerequisites

- **Node.js** v18+ (tested with v24)
- **macOS** (AppleScript/Shortcuts tools require macOS)
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

### Running

```bash
npx tsx jarvis.ts
```

Or use the npm script:

```bash
npm start
```

### Try it out

```
You: What time is it?
You: List my Desktop files
You: Create a file /tmp/hello.txt with "Hello, World!"
You: Open Safari
You: What Shortcuts do I have?
You: Find all .ts files in this project and count them
```

Type `new` to start a fresh conversation, or `quit` to exit.

## Development

### Project Structure

```
jarvis.ts                  # CLI entry point
config/                    # Configuration (API keys, DB, system prompt)
models/                    # TypeScript type definitions
services/                  # Core services (agent loop, OpenRouter, DB, tools)
tools/                     # Tool implementations
helpers/                   # Native helpers (Swift STT — Phase 4)
data/                      # SQLite database (auto-created, gitignored)
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

### Key Commands

```bash
# Run the agent
npx tsx jarvis.ts

# Type-check without running
npx tsc --noEmit

# Reset the database
rm -f data/jarvis.db
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

2. Register it in `jarvis.ts`:

```ts
import { myTool } from './tools/my-tool.js';
// in registerTools():
toolRegistry.register(myTool);
```

The tool is automatically converted to OpenRouter's function calling format and made available to the LLM.

### Architecture

The core loop in `services/agent-loop.ts`:

1. User message is added to conversation history
2. Full history + tool definitions are sent to OpenRouter
3. If the LLM returns `tool_calls` → execute each tool → add results → go to step 2
4. If the LLM returns text (no tool calls) → return the response to the user
5. Safety limit: max 25 steps per request

### Models

Configured in `config/openrouter.ts`:

- **Default**: `google/gemini-2.0-flash-001` — fast and cheap for most tasks
- **Complex**: `anthropic/claude-sonnet-4` — auto-escalated after 10 reasoning steps

Change models by editing the constants, or add new task complexity tiers in `getModelForTask()`.

## Roadmap

- [x] **Phase 1**: CLI agent + basic tools (shell, files, AppleScript, Shortcuts, web search)
- [ ] **Phase 2**: MCP client + Claude Code CLI integration + Chrome browser automation
- [ ] **Phase 3**: Memory system (episodic/semantic/procedural) + vector search + RAG
- [ ] **Phase 4**: Voice interface (STT via Swift + TTS via macOS `say`)
- [ ] **Phase 5**: Menu bar UI (Tauri v2)
- [ ] **Phase 6**: Background daemon + scheduled tasks + self-learning

## License

Private project.
