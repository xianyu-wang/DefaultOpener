import SwiftUI

struct TypeListView: View {
    let category: String // "All", "Text", "Image", "Code", etc.
    @Binding var knownTypes: Set<String>
    @EnvironmentObject var dutiManager: DutiManager
    @EnvironmentObject var appScanner: AppScanner
    @State private var searchText = ""
    @State private var sortOrder = 0 // 0: Name, 1: Default App
    @State private var isSearchPresented = false
    
    var filteredTypes: [String] {
        let types = knownTypes.filter { type in
            if searchText.isEmpty { return true }
            return type.localizedCaseInsensitiveContains(searchText)
        }
        
        // Filter by category
        let categoryFiltered: [String] = types.filter { type in
            switch category {
            case "All": return true
            case "Text": return UTIHelper.isTextType(type)
            case "Image": return UTIHelper.isImageType(type)
            case "Code": return UTIHelper.isCodeSource(type)
            case "Audio": return UTIHelper.isAudioType(type)
            case "Video": return UTIHelper.isVideoType(type)
            case "Archive": return UTIHelper.isArchiveType(type)
            case "PDF": return UTIHelper.isPDFType(type)
            case "Custom": return appScanner.customUTIs.contains(type)
            default: return true
            }
        }
        
        return categoryFiltered.sorted {
            if sortOrder == 0 {
                return $0 < $1
            } else {
                return (dutiManager.cachedDefault(for: $0) ?? "") < (dutiManager.cachedDefault(for: $1) ?? "")
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredTypes, id: \.self) { type in
                HStack {
                    FileRowView(
                        fileType: type,
                        currentApp: dutiManager.cachedDefault(for: type),
                        allApps: appScanner.installedApps
                    )
                    
                    AppPicker(
                        selection: Binding(
                            get: { dutiManager.cachedDefault(for: type) },
                            set: { newValue in
                                if let id = newValue {
                                    _ = dutiManager.apply(bundleId: id, type: type)
                                }
                            }
                        ),
                        apps: appScanner.installedApps,
                        fileType: type
                    )
                    .frame(width: 150)
                    
                    if appScanner.customUTIs.contains(type) {
                        Button(action: {
                            appScanner.removeCustomType(type)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 8)
                    }
                }
                .onAppear {
                    // Trigger fetch for this item if needed, or rely on batch fetch
                    // Optimally, we fetch for the visible rows or the whole filtered list
                }
            }
        }
        .searchable(text: $searchText, isPresented: $isSearchPresented)
        .background(
            Button("Find") {
                isSearchPresented = true
            }
            .keyboardShortcut("f", modifiers: .command)
            .hidden()
        )
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Picker("Sort", selection: $sortOrder) {
                    Text("Name").tag(0)
                    Text("Current App").tag(1)
                }
            }
        }
        .navigationTitle(category)
        .onAppear {
            loadVisibleDefaults()
        }
        .onChange(of: category) {
            loadVisibleDefaults()
        }
    }
    
    private func loadVisibleDefaults() {
        // Fetch defaults for all filtered types in background to avoid stutter
        dutiManager.fetchDefaults(for: filteredTypes)
    }
}
