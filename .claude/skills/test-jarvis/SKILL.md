---
name: test-jarvis
description: Test the Jarvis agent by running it and verifying tools work. Use when asked to test, verify, or check if Jarvis is working.
allowed-tools: Read, Bash, Grep, Glob
---

# Test Jarvis Agent

Run verification checks on both the CLI agent and the native app.

## Steps

### 1. TypeScript Compilation

Run `npx tsc --noEmit` and verify no type errors.

### 2. CLI Startup

Run `echo "quit" | npx tsx jarvis.ts` and verify:
- No TypeScript errors
- Banner prints with all expected tools listed
- Clean exit

### 3. IPC Server

Run `echo '{"id":"test","type":"query","text":"What is 2+2?"}' | timeout 30 npx tsx jarvis-server.ts 2>/dev/null | head -5` and verify:
- First line is `{"id":null,"type":"ready"}`
- Subsequent lines are valid JSON with tool_start/tool_result/response types

### 4. Database

Run `sqlite3 data/jarvis.db ".tables"` and verify tables exist:
- `conversations`, `messages`, `agent_state`, `schema_version`

### 5. Tool Registration Parity

Read both `jarvis.ts` and `jarvis-server.ts` and verify they register the **same set of tools**. Any mismatch means the CLI and native app have different capabilities.

### 6. Native App Build

Run `cd JarvisApp && xcodebuild -scheme JarvisApp -configuration Debug build 2>&1 | tail -3` and verify `BUILD SUCCEEDED`.

### 7. Common Issues Check

- All imports use `.js` extension
- `.env` has a valid `OPENROUTER_API_KEY` (not the placeholder)
- `data/` directory is gitignored
- No circular imports between services

### 8. Report

Summarize what passed and what failed. If there are issues, suggest fixes.
