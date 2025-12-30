import SwiftUI

struct FileRowView: View {
    let fileType: String // UTI or Extension
    let currentApp: String? // Bundle ID
    let allApps: [AppInfo]
    
    var icon: Image {
       if UTIHelper.isImageType(fileType) { return Image(systemName: "photo") }
       if UTIHelper.isTextType(fileType) { return Image(systemName: "doc.text") }
       if UTIHelper.isCodeSource(fileType) { return Image(systemName: "chevron.left.forwardslash.chevron.right") }
       return Image(systemName: "doc")
    }
    
    var appName: String {
        guard let id = currentApp else { return "None" }
        return allApps.first(where: { $0.id == id })?.name ?? id
    }
    
    // Helper to get a nice description
    var typeDescription: String {
        let info = UTIHelper.getInfo(for: fileType)
        return info.description ?? fileType
    }
    
    var body: some View {
        HStack {
            icon
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                // Primary: Description or nicely formatted extension
                Text(typeDescription)
                    .font(.headline)
                
                // Secondary: The actual UTI or extension string
                Text(fileType)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // We removed the app name text here because it's in the picker on the right usually,
            // but the picker is passed into the ListView.
            // Wait, the previous design had the Picker AND the Text?
            // "FileRowView... AppPicker" in the VStack.
            // The previous FileRowView had `Text(appName)` as well.
            // If the user wants the picker to show the selection, we might not need the text redundantly.
            // But let's keep it if it's meant to be read-only status on the left of the picker.
            // Actually, usually the picker *is* the display.
            // Let's remove the redundant text if there is a picker next to it, 
            // BUT the FileRowView is used inside an HStack in TypeListView alongside AppPicker.
            // So removing `Text(appName)` is probably cleaner.
        }
        .padding(.vertical, 4)
    }
}
