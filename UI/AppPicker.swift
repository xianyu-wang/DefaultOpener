import SwiftUI

struct AppPicker: View {
    @Binding var selection: String? // Bundle ID
    let apps: [AppInfo]
    let fileType: String
    var onSelect: ((String) -> Void)?
    
    var body: some View {
        Menu {
            ForEach(apps) { app in
                Button(action: {
                    selection = app.id
                    onSelect?(app.id)
                }) {
                    Text(app.name)
                    if selection == app.id {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Divider()
            
            Button("Other...") {
                // In a real app, this would open NSOpenPanel to find an app
                // For this scope, we might skip implementation or show a placeholder
            }
        } label: {
            HStack {
                if let id = selection, let app = apps.first(where: { $0.id == id }) {
                    Text(app.name)
                } else {
                    Text("Select App")
                }
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
            }
            .padding(5)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(5)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.3)))
        }
        .menuStyle(.borderlessButton)
    }
}
