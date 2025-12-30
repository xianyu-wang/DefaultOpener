import SwiftUI

struct AddFormatSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appScanner: AppScanner // Access appScanner directly
    // @Binding var knownTypes: Set<String> // No longer needed as binding, we act on the model
    
    @State private var newType: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add New File Format")
                .font(.headline)
            
            TextField("Extension or UTI (e.g. .txt, public.json)", text: $newType)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
            
            HStack {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                
                Button("Add") {
                    let cleaned = newType.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !cleaned.isEmpty {
                        appScanner.addCustomType(cleaned)
                        dismiss()
                    }
                }
                .disabled(newType.isEmpty)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 400, height: 150)
    }
}
