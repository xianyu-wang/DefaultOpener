import SwiftUI

@main
struct DefaultOpenerApp: App {
    @StateObject var appScanner = AppScanner()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(DutiManager.shared)
                .environmentObject(appScanner)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New File Type") {
                    NotificationCenter.default.post(name: Notification.Name("DefaultOpener.AddType"), object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandGroup(replacing: .saveItem) {
                Button("Import Config...") {
                    NotificationCenter.default.post(name: Notification.Name("DefaultOpener.ImportConfig"), object: nil)
                }
                .keyboardShortcut("i", modifiers: .command)
                
                Button("Export Config...") {
                    NotificationCenter.default.post(name: Notification.Name("DefaultOpener.SaveConfig"), object: nil)
                }
                .keyboardShortcut("s", modifiers: .command)
            }
            
            CommandGroup(after: .saveItem) {
                Divider()
                Button("Rescan Applications") {
                    appScanner.scan()
                }
                .keyboardShortcut("r", modifiers: .command)
                
                Button("Close Window") {
                    NSApp.keyWindow?.close()
                }
                .keyboardShortcut("w", modifiers: .command)
            }
        }
    }
}
