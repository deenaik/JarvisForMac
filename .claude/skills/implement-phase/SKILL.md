---
name: implement-phase
description: Implement the next phase of the Jarvis project roadmap. Use when asked to build Phase 2, Phase 3, etc.
argument-hint: [phase-number]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Implement Phase $ARGUMENTS of Jarvis

## Before Starting

1. **Read `CLAUDE.md`** to understand the full project structure and conventions
2. **Read `README.md`** Roadmap section to see what's done and what's next
3. **Identify stub files** for this phase — they already exist with TODO comments explaining what to implement
4. **Read the stub files** to understand the expected interfaces and integration points

## Phase Reference

- **Phase 2**: MCP client (`@modelcontextprotocol/sdk`), Claude Code CLI (`tools/claude-code.ts`), Chrome browser (`tools/browser.ts`), dynamic MCP tools (`tools/mcp-tool.ts`), config in `config/mcp.ts`, service in `services/mcp-client.ts`
- **Phase 3**: Memory system — `models/MemoryTypes.ts`, `services/memory-service.ts`, `services/embedding-service.ts`, `services/vector-store.ts` (sqlite-vec), `tools/memory-query.ts`, `tools/memory-store.ts`. Needs `npm install sqlite-vec`
- **Phase 6**: Scheduler — `services/scheduler.ts`, launchd plist, memory consolidation, self-assessment

## Implementation Process

1. **Install new dependencies** if the phase requires them (check the plan)
2. **Implement service files** first (the core logic)
3. **Implement tool files** that use the services
4. **Update BOTH entry points** — register new tools in `jarvis.ts` AND `jarvis-server.ts`
5. **Update `config/`** if new configuration is needed
6. **Test CLI**: Run `npx tsx jarvis.ts` and exercise the new capabilities
7. **Test IPC**: Run `echo '{"id":"1","type":"query","text":"test the new tool"}' | npx tsx jarvis-server.ts` to verify server mode works
8. **Build native app**: Run `cd JarvisApp && xcodebuild -scheme JarvisApp -configuration Debug build` to ensure no regressions
9. **Update `README.md`** roadmap to mark the phase as complete

## Conventions

- All TypeScript imports use `.js` extension (ESM)
- Services export singleton instances
- Tools implement `Tool` interface and never throw
- Follow existing patterns in the codebase — read working code before writing new code
- Keep stub TODO comments for sub-features not yet implemented within a phase
- **Dual registration**: new tools go in both `jarvis.ts` and `jarvis-server.ts`
