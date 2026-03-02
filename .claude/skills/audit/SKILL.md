---
name: audit
description: Run a full project audit covering type checking, code quality, dead code, dependency security, duplicates, and structural issues. Use when asked to audit, lint, check quality, or clean up the project.
allowed-tools: Read, Bash, Grep, Glob, Edit
---

# Full Project Audit

Run all checks below in order. Collect all findings, then present a summary table at the end with pass/fail/warn status for each category and actionable fixes for any failures.

## 1. TypeScript Type Check

Run `npx tsc --noEmit` and report any type errors.

## 2. Swift Build Check

Run `cd JarvisApp && xcodebuild -scheme JarvisApp -configuration Debug build 2>&1 | grep -E "error:|BUILD"` and report any Swift compile errors.

## 3. Unused Exports & Dead Code (knip)

Run `npx knip --no-exit-code` to detect:
- Unused files
- Unused exports (functions, types, constants)
- Unused dependencies in package.json
- Unlisted dependencies (used in code but not in package.json)

If knip is not installed, run it via `npx knip` (zero-install). Review results and flag anything that should be cleaned up vs. intentional stubs (files with Phase 2+ TODOs are expected to have unused exports).

## 4. Dependency Security Audit

Run `npm audit` to check for known vulnerabilities. If fixable, run `npm audit fix` and report what changed. Do NOT run `npm audit fix --force` without listing the breaking changes first.

## 5. Duplicate Code Detection

Run `npx jscpd --pattern "**/*.ts" --ignore "node_modules,dist,data" --min-lines 5 --min-tokens 50 --reporters consoleFull` to find copy-pasted code blocks. Flag any duplicates that should be extracted into shared helpers.

## 6. Import Hygiene

Use Grep to check for common import issues:
- Missing `.js` extension on relative imports (required for ESM): search for `from '\./` and `from '\.\./` patterns missing `.js`
- Circular imports: trace import chains between services/ files
- Unused imports: look for imports not referenced in the file body

## 7. Tool Registration Parity

Compare the tool registrations in `jarvis.ts` and `jarvis-server.ts`. They must register the **exact same set of tools**. Any mismatch means the CLI and native app have different capabilities. Flag discrepancies.

## 8. Convention Compliance

Verify the project conventions from CLAUDE.md:
- All tool files export a const implementing `Tool` interface (not a class)
- All tools return error strings instead of throwing
- All services export a singleton instance
- All config reads from `process.env` via dotenv
- Database operations are synchronous (no `await` on better-sqlite3 calls)
- Tool names use snake_case, filenames use kebab-case
- Swift files use `@MainActor` on UI classes
- Swift uses `os.Logger` not `print()` for debug output

## 9. Package.json Health

Check for:
- Scripts that reference missing files
- Missing `engines` field (node version requirement)
- Dependencies that could be devDependencies or vice versa
- Outdated dependencies: run `npm outdated` and flag major version bumps

## 10. Git Hygiene

Check for:
- Files that should be gitignored but aren't (`.env`, `data/`, `.DS_Store`, `xcuserdata/`)
- Large files tracked in git (> 1MB)
- Sensitive data accidentally committed (API keys, tokens)

## 11. Security Patterns

Scan for common security issues:
- `child_process.exec()` usage (should be `execFile` to prevent shell injection)
- Unsanitized user input passed to shell commands
- Hardcoded secrets or API keys in source files (not .env)
- Eval or Function constructor usage

## Summary Format

Present results as:

```
| Check                    | Status | Details                           |
|--------------------------|--------|-----------------------------------|
| TypeScript               | PASS   |                                   |
| Swift Build              | PASS   |                                   |
| Dead Code (knip)         | WARN   | 3 unused exports (Phase 2 stubs)  |
| Dependency Security      | PASS   |                                   |
| Duplicate Code           | PASS   |                                   |
| Import Hygiene           | PASS   |                                   |
| Tool Registration Parity | PASS   |                                   |
| Convention Compliance    | PASS   |                                   |
| Package.json Health      | WARN   | 2 outdated deps                   |
| Git Hygiene              | PASS   |                                   |
| Security Patterns        | PASS   |                                   |
```

Then list actionable fixes grouped by severity (error > warning > info). Apply trivial fixes automatically (unused imports, missing .js extensions). Ask before making structural changes.
