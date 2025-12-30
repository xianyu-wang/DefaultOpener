import Foundation
import Combine

/// Manages interactions with the `duti` command line tool.
class DutiManager: ObservableObject {
    static let shared = DutiManager()
    
    private var dutiPath: String = "/opt/homebrew/bin/duti"
    
    // Cache for default application bundle IDs
    // Key: UTI/Extension, Value: Bundle ID
    @Published var defaultsCache: [String: String] = [:]
    
    init() {
        // Attempt to find duti if not in standard homebrew path
        if !FileManager.default.fileExists(atPath: dutiPath) {
            let result = shell("which duti")
            if !result.isEmpty {
                dutiPath = result.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
    
    /// Returns the cached default app if available
    func cachedDefault(for type: String) -> String? {
        return defaultsCache[type]
    }

    // Operation Queue for limiting concurrent duti processes
    private let opQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 10 // Limit to prevent resource exhaustion
        return queue
    }()
    
    /// Asynchronously fetches defaults for a list of types
    func fetchDefaults(for types: [String]) {
        // Cancel previous pending operations to prevent backlog when switching categories rapidly
        opQueue.cancelAllOperations()
        
        // Create new operations
        let operations = types.map { type -> BlockOperation in
            let op = BlockOperation()
            op.addExecutionBlock { [weak self, weak op] in
                guard let self = self, let op = op, !op.isCancelled else { return }
                
                // Check cache first to avoid unnecessary process spawn
                if self.defaultsCache[type] != nil { return }
                
                let output = self.shell("\(self.dutiPath) -d \(type)")
                
                if !op.isCancelled && !output.isEmpty && !output.contains("not found") {
                    let appId = output.trimmingCharacters(in: .whitespacesAndNewlines)
                    DispatchQueue.main.async {
                        self.defaultsCache[type] = appId
                    }
                }
            }
            return op
        }
        
        opQueue.addOperations(operations, waitUntilFinished: false)
    }
    
    /// Returns the current default application bundle ID for a given extension or UTI (Synchronous - deprecated for UI)
    func getDefaultApp(for type: String) -> String? {
        if let cached = defaultsCache[type] { return cached }
        
        let output = shell("\(dutiPath) -d \(type)")
        if !output.isEmpty && !output.contains("not found") {
            return output.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return nil
    }
    
    /// Sets the default application for a specific type (UTI or extension)
    func apply(bundleId: String, type: String, role: String = "all") -> Bool {
        // Update cache optimistically
        DispatchQueue.main.async {
            self.defaultsCache[type] = bundleId
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let command = "\(self.dutiPath) -s \(bundleId) \(type) \(role)"
            let _ = self.shell(command)
        }
        return true
    }
    
    /// Shell helper
    private func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/zsh"
        task.environment = ["PATH": "/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/homebrew/bin"]
        
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}
