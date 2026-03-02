---
name: build-app
description: Build both the TypeScript backend and native macOS app together. Use when asked to build, compile, or verify the full project compiles.
allowed-tools: Bash, Read, Grep
---

# Build Jarvis (Full Stack)

Build and verify both the TypeScript backend and the native macOS SwiftUI app.

## Steps

### 1. TypeScript Type Check

Run `npx tsc --noEmit` and report any type errors. If errors exist, stop and report them — Swift build depends on a working backend.

### 2. CLI Smoke Test

Run `echo "quit" | npx tsx jarvis.ts` and verify:
- No runtime errors
- Banner prints with all tools listed
- Clean exit

### 3. IPC Server Smoke Test

Run `echo '' | timeout 5 npx tsx jarvis-server.ts 2>/dev/null | head -1` and verify:
- First output line is `{"id":null,"type":"ready"}`

### 4. Native App Build

Run:
```bash
cd JarvisApp && xcodebuild -project JarvisApp.xcodeproj -scheme JarvisApp -configuration Debug build 2>&1 | tail -5
```

Check for `BUILD SUCCEEDED`. If it fails, extract errors with:
```bash
xcodebuild ... 2>&1 | grep "error:"
```

### 5. Tool Registration Parity

Read `jarvis.ts` and `jarvis-server.ts` — verify both register the exact same tools.

### 6. Report

Summarize:
- TypeScript: PASS/FAIL
- CLI: PASS/FAIL
- IPC Server: PASS/FAIL
- Swift Build: PASS/FAIL
- Tool Parity: PASS/FAIL

If anything failed, provide the error details and suggest fixes.
