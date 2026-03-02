---
name: add-tool
description: Add a new tool to the Jarvis agent. Use when asked to create a new tool, add a capability, or implement a tool for the agent.
argument-hint: [tool-name] [description]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Add a New Tool to Jarvis

Create a new tool called `$0` for the Jarvis agent.

Description: $ARGUMENTS

## Steps

1. **Read the Tool interface** from `models/ToolTypes.ts` to understand the contract
2. **Read an existing tool** (e.g., `tools/shell.ts`) as a reference for the pattern
3. **Create the tool file** at `tools/$0.ts`:
   - Export a named const implementing the `Tool` interface
   - Use `import type { Tool } from '../models/ToolTypes.js'` (note `.js` extension — ESM requirement)
   - Define `name` using snake_case (this is how the LLM calls it)
   - Write a clear `description` — the LLM uses this to decide when to call the tool
   - Define `parameters` as a JSON Schema object with `type`, `description`, and `required`
   - The `execute` method must return `Promise<string>` — never throw, return error strings instead
   - Import config values from `config/jarvis.js` if you need `TOOL_TIMEOUT_MS`
4. **Register the tool in BOTH entry points**:
   - `jarvis.ts`: Add import + `toolRegistry.register(myTool)` inside `registerTools()`
   - `jarvis-server.ts`: Add the same import + register (this file has its own `registerTools()`)
5. **Verify** by running `echo "quit" | npx tsx jarvis.ts` to confirm it compiles and the tool appears in the loaded tools list

## Conventions

- Tool files use kebab-case filenames (`my-tool.ts`) but snake_case tool names (`my_tool`)
- Tools are plain objects, not classes
- Tools never throw errors — always return an error string so the LLM can reason about it
- Import paths always use `.js` extension (tsx resolves to `.ts` at runtime)
- Use `execFile` from `node:child_process` for subprocess tools (not `exec`) for safety
- Respect `TOOL_TIMEOUT_MS` (30s) from `config/jarvis.js` for any subprocess calls
- **Dual registration is required** — tools must be in both `jarvis.ts` and `jarvis-server.ts` or the native app won't have access to them
