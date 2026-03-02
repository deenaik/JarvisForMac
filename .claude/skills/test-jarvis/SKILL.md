---
name: test-jarvis
description: Test the Jarvis agent by running it and verifying tools work. Use when asked to test, verify, or check if Jarvis is working.
allowed-tools: Read, Bash, Grep, Glob
---

# Test Jarvis Agent

Run verification checks on the Jarvis agent.

## Steps

1. **Check compilation**: Run `echo "quit" | npx tsx jarvis.ts` and verify:
   - No TypeScript errors
   - Banner prints with all expected tools listed
   - Clean exit

2. **Check database**: Run `sqlite3 data/jarvis.db ".tables"` and verify tables exist:
   - `conversations`, `messages`, `agent_state`, `schema_version`

3. **Check TypeScript types**: Run `npx tsc --noEmit` and verify no type errors

4. **Check tool registration**: Read `jarvis.ts` and verify all implemented tools are imported and registered in `registerTools()`

5. **Check for common issues**:
   - All imports use `.js` extension
   - `.env` has a valid `OPENROUTER_API_KEY` (not the placeholder)
   - `data/` directory is gitignored
   - No circular imports between services

6. **Report results**: Summarize what passed and what failed. If there are issues, suggest fixes.
