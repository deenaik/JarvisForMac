---
name: debug-ipc
description: Debug IPC communication between the Swift app and Node.js backend. Use when the native app can't talk to the backend, messages aren't flowing, or tool calls aren't working.
allowed-tools: Read, Bash, Grep, Glob
---

# Debug IPC Communication

Diagnose issues in the NDJSON-over-stdio communication between the native SwiftUI app and the Node.js backend.

## Steps

### 1. Verify Node.js Backend Works Standalone

```bash
echo '{"id":"test","type":"query","text":"What is 2+2?"}' | timeout 30 npx tsx jarvis-server.ts 2>/dev/null
```

Expected: First line is `{"id":null,"type":"ready"}`, followed by tool_start/tool_result/response lines. If this fails, the issue is in the Node.js backend, not IPC.

### 2. Check stderr for Node.js Errors

```bash
echo '{"id":"test","type":"query","text":"hello"}' | timeout 10 npx tsx jarvis-server.ts 2>&1 1>/dev/null
```

This shows only stderr. Look for:
- Module resolution errors (missing `.js` extensions)
- Missing environment variables (OPENROUTER_API_KEY)
- Database errors
- Import/require errors

### 3. Verify NDJSON Protocol Compliance

Read `jarvis-server.ts` and check:
- `console.log` is redirected to stderr (not polluting stdout)
- All output to stdout uses `JSON.stringify(msg) + '\n'`
- No extraneous output on stdout (banners, debug prints)

Read `JarvisApp/JarvisApp/Services/NodeBridge.swift` and check:
- Requests are encoded as JSON + newline
- Responses are parsed by splitting on newlines first, then JSON-decoding each line
- The buffer correctly handles partial reads (data arriving in chunks)

### 4. Check Node.js Process Spawning

Read `NodeBridge.swift` and verify:
- `projectRoot` resolves correctly (check the fallback chain)
- `tsx` path exists at the resolved location
- Environment variables include PATH with Node.js binary locations
- `JARVIS_PROJECT_ROOT` env var override is documented for debugging

Test the path resolution:
```bash
# Check if tsx is available
ls -la node_modules/.bin/tsx
which npx
```

### 5. Check macOS Console Logs

```bash
log show --last 5m --predicate 'subsystem == "com.deenaik.JarvisApp"' --style compact
```

Look for:
- "Node.js process started (PID: ...)" — confirms spawn worked
- "Node.js backend is ready" — confirms IPC is flowing
- "Node.js exited with code ..." — backend crashed
- "Failed to decode response" — malformed JSON from backend

### 6. Verify Tool Registration Parity

Read both `jarvis.ts` and `jarvis-server.ts` and compare their `registerTools()` functions. Missing tools in the server means the native app won't have those capabilities.

### 7. Report

Summarize:
- Backend standalone: PASS/FAIL
- NDJSON compliance: PASS/FAIL
- Process spawning: PASS/FAIL (with path details)
- Console logs: any errors found
- Tool parity: PASS/FAIL

Provide specific fixes for each issue found.
