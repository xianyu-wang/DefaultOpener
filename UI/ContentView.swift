import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var appScanner: AppScanner
    @EnvironmentObject var dutiManager: DutiManager
    
    @State private var sidebarSelection: String? = "All"
    @State private var showingAddSheet = false
    @State private var showingSaveAlert = false
    @State private var showingImportAlert = false
    
    // Categories
    let categories = ["All", "Text", "Image", "Code", "Audio", "Video", "Archive", "PDF", "Custom"]
    
    var body: some View {
        NavigationSplitView {
            List(selection: $sidebarSelection) {
                ForEach(categories, id: \.self) { category in
                    Label(category, systemImage: iconForCategory(category))
                        .tag(category)
                }
            }
            .navigationTitle("Categories")
            .navigationTitle("Categories")
            // ToolbarItem removed from here
        } detail: {
            if let selection = sidebarSelection {
                TypeListView(category: selection, knownTypes: $appScanner.knownUTIs)
            } else {
                Text("Select a category")
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    appScanner.scan()
                }) {
                    Label("Rescan", systemImage: "arrow.clockwise")
                }
                .help("Rescan Applications")
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddSheet = true }) {
                    Label("Add Type", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)
                .help("Add New File Type (Cmd+N)")
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                     importConfig()
                }) {
                    Label("Import Config", systemImage: "square.and.arrow.down")
                }
                .keyboardShortcut("i", modifiers: .command)
                .help("Import Configuration (Cmd+I)")
            }

            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                     saveConfig()
                }) {
                    Label("Save Config", systemImage: "square.and.arrow.up")
                }
                .keyboardShortcut("s", modifiers: .command)
                .help("Export Configuration (Cmd+S)")
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddFormatSheet()
        }
        .alert("Configuration Saved", isPresented: $showingSaveAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("Configuration Imported", isPresented: $showingImportAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The settings have been applied and the list refreshed.")
        }
        .onAppear {
            appScanner.scan()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DefaultOpener.AddType"))) { _ in
            showingAddSheet = true
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DefaultOpener.ImportConfig"))) { _ in
            importConfig()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DefaultOpener.SaveConfig"))) { _ in
            saveConfig()
        }
    }
    
    func saveConfig() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.text]
        panel.nameFieldStringValue = "config.duti"
        panel.begin { result in
            if result == .OK, let url = panel.url {
                var entries: [DutiConfigEntry] = []
                for type in appScanner.knownUTIs {
                    if let bundleId = dutiManager.getDefaultApp(for: type) {
                        entries.append(DutiConfigEntry(bundleId: bundleId, type: type, role: "all"))
                    }
                }
                
                let configManager = ConfigManager() // Create instance locally or add to env
                configManager.save(to: url, entries: entries)
                showingSaveAlert = true
            }
        }
    }
    
    func importConfig() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.text]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        panel.begin { result in
            if result == .OK, let url = panel.url {
                let configManager = ConfigManager()
                configManager.load(from: url)
                
                // Optimization: Maybe suspend updates to UI during this batch?
                for entry in configManager.entries {
                    _ = dutiManager.apply(bundleId: entry.bundleId, type: entry.type, role: entry.role)
                }
                
                // Rescan after a short delay to allow system to update
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    appScanner.scan()
                    showingImportAlert = true
                }
            }
        }
    }
    
    func iconForCategory(_ category: String) -> String {
        switch category {
        case "All": return "square.grid.2x2"
        case "Text": return "doc.text"
        case "Image": return "photo"
        case "Code": return "chevron.left.forwardslash.chevron.right"
        case "Audio": return "speaker.wave.2"
        case "Video": return "film"
        case "Archive": return "archivebox"
        case "PDF": return "doc.text.fill"
        case "Custom": return "pencil.and.outline"
        default: return "folder"
        }
    }
}
