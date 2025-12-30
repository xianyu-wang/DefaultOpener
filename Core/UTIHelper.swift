import Foundation
import UniformTypeIdentifiers

/// Structure to hold type info
struct FileType: Identifiable, Hashable {
    let id: String // UTI or Extension string
    let description: String?
    let conformsTo: [String]
    let iconName: String?
}

/// Helper to categorize and manage UTIs
class UTIHelper {
    
    static func getInfo(for typeIdentifier: String) -> FileType {
        if #available(macOS 11.0, *) {
            if let type = UTType(typeIdentifier) {
                return FileType(
                    id: type.identifier,
                    description: type.localizedDescription,
                    conformsTo: type.supertypes.map { $0.identifier },
                    iconName: nil // In a real app we might fetch NSImage
                )
            }
        }
        
        // Fallback or if it's just an extension
        return FileType(id: typeIdentifier, description: nil, conformsTo: [], iconName: nil)
    }
    
    static func isTextType(_ type: String) -> Bool {
        if #available(macOS 11.0, *) {
            guard let utType = UTType(type) else { return false }
            return utType.conforms(to: .text)
        }
        return false
    }
    
    static func isImageType(_ type: String) -> Bool {
        if #available(macOS 11.0, *) {
            guard let utType = UTType(type) else { return false }
            return utType.conforms(to: .image)
        }
        return false
    }
    
    static func isCodeSource(_ type: String) -> Bool {
        if #available(macOS 11.0, *) {
            guard let utType = UTType(type) else { return false }
            return utType.conforms(to: .sourceCode)
        }
        return false
    }
    
    static func isAudioType(_ type: String) -> Bool {
        if #available(macOS 11.0, *) {
            guard let utType = UTType(type) else { return false }
            return utType.conforms(to: .audio)
        }
        return false
    }
    
    static func isVideoType(_ type: String) -> Bool {
        if #available(macOS 11.0, *) {
            guard let utType = UTType(type) else { return false }
            return utType.conforms(to: .movie)
        }
        return false
    }
    
    static func isArchiveType(_ type: String) -> Bool {
        if #available(macOS 11.0, *) {
            guard let utType = UTType(type) else { return false }
            return utType.conforms(to: .archive)
        }
        return false
    }
    
    static func isPDFType(_ type: String) -> Bool {
        if #available(macOS 11.0, *) {
            guard let utType = UTType(type) else { return false }
            return utType.conforms(to: .pdf)
        }
        return false
    }
}
