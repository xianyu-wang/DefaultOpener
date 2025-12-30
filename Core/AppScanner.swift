import Foundation
import UniformTypeIdentifiers
import Combine

/// Represents a scannable application and its supported types
struct AppInfo: Identifiable, Hashable {
    let id: String // Bundle ID
    let name: String
    let url: URL
    let supportedTypes: [String] // List of UTIs or Extensions
}

class AppScanner: ObservableObject {
    @Published var installedApps: [AppInfo] = []
    @Published var knownUTIs: Set<String> = []
    @Published var customUTIs: Set<String> = []
    private var scannedUTIs: Set<String> = []
    
    func addCustomType(_ type: String) {
        customUTIs.insert(type)
        rebuildKnownUTIs()
    }
    
    func removeCustomType(_ type: String) {
        customUTIs.remove(type)
        rebuildKnownUTIs()
    }
    
    private func rebuildKnownUTIs() {
        knownUTIs = scannedUTIs.union(customUTIs)
    }
    
    func scan() {
        print("Starting scan...")
        DispatchQueue.global(qos: .userInitiated).async {
            let apps = self.findApplications()
            DispatchQueue.main.async {
                self.installedApps = apps
                self.extractKnownUTIs(from: apps)
            }
        }
    }
    
    private func findApplications() -> [AppInfo] {
        var results: [AppInfo] = []
        let fileManager = FileManager.default
        
        // Standard paths to search
        let searchPaths = [
            "/Applications",
            "/System/Applications",
            FileManager.default.homeDirectoryForCurrentUser.path + "/Applications"
        ]
        
        for path in searchPaths {
            guard let enumerator = fileManager.enumerator(at: URL(fileURLWithPath: path), includingPropertiesForKeys: [.isApplicationKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else { continue }
            
            for case let fileURL as URL in enumerator {
                if fileURL.pathExtension == "app" {
                    if let appInfo = processApp(at: fileURL) {
                        results.append(appInfo)
                    }
                }
            }
        }
        
        return results
    }
    
    private func processApp(at url: URL) -> AppInfo? {
        guard let bundle = Bundle(url: url),
              let bundleId = bundle.bundleIdentifier else { return nil }
        
        let name = bundle.infoDictionary?["CFBundleName"] as? String ?? url.deletingPathExtension().lastPathComponent
        
        var supported = Set<String>()
        
        // Read Info.plist for Document Types
        if let docTypes = bundle.infoDictionary?["CFBundleDocumentTypes"] as? [[String: Any]] {
            for type in docTypes {
                // UTIs
                if let contentTypes = type["LSItemContentTypes"] as? [String] {
                    contentTypes.forEach { supported.insert($0) }
                }
                // Extensions
                if let extensions = type["CFBundleTypeExtensions"] as? [String] {
                     extensions.forEach { supported.insert($0) }
                }
            }
        }
        
        return AppInfo(id: bundleId, name: name, url: url, supportedTypes: Array(supported))
    }
    
    private func extractKnownUTIs(from apps: [AppInfo]) {
        var utis = Set<String>()
        for app in apps {
            for type in app.supportedTypes {
                utis.insert(type)
            }
        }
        self.scannedUTIs = utis
        rebuildKnownUTIs()
    }
}
