import Foundation
import os

/// Manages the Node.js subprocess and NDJSON IPC communication.
@MainActor
final class NodeBridge: ObservableObject {
    @Published private(set) var isReady = false
    @Published private(set) var isRunning = false

    private var process: Process?
    private var stdinPipe: Pipe?
    private var stdoutPipe: Pipe?
    private var stderrPipe: Pipe?
    private var buffer = ""
    private let logger = Logger(subsystem: "com.deenaik.JarvisApp", category: "NodeBridge")

    /// Called for each IPC response from Node.js
    var onResponse: ((IPCResponse) -> Void)?

    /// Path to the project root (parent of JarvisApp/).
    /// Resolution order:
    ///   1. JARVIS_PROJECT_ROOT env var (explicit override)
    ///   2. Xcode SOURCE_ROOT (set at build time via Info.plist, points to JarvisApp/ — parent is project root)
    ///   3. Walk up from bundle path looking for jarvis-server.ts
    ///   4. Hardcoded fallback for this workspace
    private var projectRoot: String {
        // 1. Explicit env override
        if let envPath = ProcessInfo.processInfo.environment["JARVIS_PROJECT_ROOT"] {
            return envPath
        }

        // 2. SOURCE_ROOT baked into Info.plist at build time (most reliable for Xcode builds)
        if let sourceRoot = Bundle.main.infoDictionary?["ProjectSourceRoot"] as? String {
            // sourceRoot points to JarvisApp/ (the Xcode project dir), parent is the repo root
            let repoRoot = (sourceRoot as NSString).deletingLastPathComponent
            let candidate = (repoRoot as NSString).appendingPathComponent("jarvis-server.ts")
            if FileManager.default.fileExists(atPath: candidate) {
                return repoRoot
            }
        }

        // 3. Walk up from the app bundle to find jarvis-server.ts
        let bundle = Bundle.main.bundlePath
        var dir = (bundle as NSString).deletingLastPathComponent
        for _ in 0..<10 {
            let candidate = (dir as NSString).appendingPathComponent("jarvis-server.ts")
            if FileManager.default.fileExists(atPath: candidate) {
                return dir
            }
            let parent = (dir as NSString).deletingLastPathComponent
            if parent == dir { break } // hit filesystem root
            dir = parent
        }

        // 4. Hardcoded fallback for this workspace
        let fallback = NSHomeDirectory() + "/Workspace/Experiment/my-clone/JarvisForMac"
        logger.warning("Could not resolve project root dynamically, using fallback: \(fallback)")
        return fallback
    }

    func start() {
        guard !isRunning else { return }

        let proc = Process()
        let stdin = Pipe()
        let stdout = Pipe()
        let stderr = Pipe()

        let root = projectRoot
        logger.info("Project root: \(root)")

        // Find tsx - try node_modules/.bin first, then npx
        let tsxPath = "\(root)/node_modules/.bin/tsx"
        let serverPath = "\(root)/jarvis-server.ts"

        if FileManager.default.fileExists(atPath: tsxPath) {
            proc.executableURL = URL(fileURLWithPath: tsxPath)
            proc.arguments = [serverPath]
        } else {
            proc.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            proc.arguments = ["npx", "tsx", serverPath]
        }

        proc.currentDirectoryURL = URL(fileURLWithPath: root)
        proc.standardInput = stdin
        proc.standardOutput = stdout
        proc.standardError = stderr

        // Pass through environment including PATH for node
        var env = ProcessInfo.processInfo.environment
        // Ensure common Node.js paths are in PATH
        let extraPaths = [
            "/opt/homebrew/bin",
            "/usr/local/bin",
            "\(NSHomeDirectory())/.nvm/versions/node/\(env["NODE_VERSION"] ?? "v22")/bin",
            "\(NSHomeDirectory())/.volta/bin",
        ]
        if let existingPath = env["PATH"] {
            env["PATH"] = extraPaths.joined(separator: ":") + ":" + existingPath
        }
        proc.environment = env

        proc.terminationHandler = { [weak self] process in
            Task { @MainActor in
                guard let self else { return }
                self.logger.warning("Node.js exited with code \(process.terminationStatus)")
                self.isRunning = false
                self.isReady = false

                // Auto-restart after a delay if unexpected exit
                if process.terminationStatus != 0 {
                    try? await Task.sleep(for: .seconds(2))
                    self.start()
                }
            }
        }

        self.process = proc
        self.stdinPipe = stdin
        self.stdoutPipe = stdout
        self.stderrPipe = stderr

        // Read stdout for NDJSON responses
        stdout.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return }
            Task { @MainActor in
                self?.handleOutput(text)
            }
        }

        // Read stderr for logging
        stderr.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            guard !data.isEmpty, let text = String(data: data, encoding: .utf8) else { return }
            self?.logger.debug("Node stderr: \(text.trimmingCharacters(in: .whitespacesAndNewlines))")
        }

        do {
            try proc.run()
            isRunning = true
            logger.info("Node.js process started (PID: \(proc.processIdentifier))")
        } catch {
            logger.error("Failed to start Node.js: \(error.localizedDescription)")
            isRunning = false
        }
    }

    func stop() {
        process?.terminate()
        process = nil
        isRunning = false
        isReady = false
    }

    func send(_ request: IPCRequest) {
        guard let stdinPipe, isRunning else {
            logger.warning("Cannot send: Node.js not running")
            return
        }

        do {
            let data = try JSONEncoder().encode(request)
            let handle = stdinPipe.fileHandleForWriting
            handle.write(data)
            handle.write("\n".data(using: .utf8)!)
            logger.debug("Sent: \(String(data: data, encoding: .utf8) ?? "?")")
        } catch {
            logger.error("Failed to encode request: \(error.localizedDescription)")
        }
    }

    // MARK: - Private

    private func handleOutput(_ text: String) {
        buffer += text
        // Split on newlines to handle NDJSON
        while let newlineRange = buffer.range(of: "\n") {
            let line = String(buffer[buffer.startIndex..<newlineRange.lowerBound])
            buffer = String(buffer[newlineRange.upperBound...])

            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            do {
                let response = try JSONDecoder().decode(IPCResponse.self, from: trimmed.data(using: .utf8)!)

                if response.type == .ready {
                    isReady = true
                    logger.info("Node.js backend is ready")
                }

                onResponse?(response)
            } catch {
                logger.warning("Failed to decode response: \(trimmed) — \(error.localizedDescription)")
            }
        }
    }
}
