import Foundation

enum EvidenceMediaStore {
    static let rootFolderName = "EvidenceMedia"

    static func appSupportRootURL() throws -> URL {
        let fm = FileManager.default
        let base = try fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let root = base.appendingPathComponent(rootFolderName, isDirectory: true)
        if !fm.fileExists(atPath: root.path) {
            try fm.createDirectory(at: root, withIntermediateDirectories: true)
        }
        return root
    }

    /// Guarda un JPEG/PNG como archivo dentro de Application Support/EvidenceMedia/<evidenceId>/
    /// Retorna el path relativo (EvidenceMedia/<evidenceId>/<filename>). Guardamos relativo para que el sandbox pueda moverse.
    static func savePhotoData(_ data: Data, evidenceId: UUID, preferredExtension ext: String = "jpg") throws -> String {
        let fm = FileManager.default
        let root = try appSupportRootURL()

        let evidenceDir = root.appendingPathComponent(evidenceId.uuidString, isDirectory: true)
        if !fm.fileExists(atPath: evidenceDir.path) {
            try fm.createDirectory(at: evidenceDir, withIntermediateDirectories: true)
        }

        let filename = "\(UUID().uuidString).\(ext)"
        let fileURL = evidenceDir.appendingPathComponent(filename)
        try data.write(to: fileURL, options: [.atomic])

        return "\(rootFolderName)/\(evidenceId.uuidString)/\(filename)"
    }

    static func resolveRelativePath(_ relativePath: String) throws -> URL {
        // relativePath empieza con EvidenceMedia/...
        let base = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return base.appendingPathComponent(relativePath)
    }

    static func deleteFileIfExists(relativePath: String) {
        do {
            let url = try resolveRelativePath(relativePath)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            // best-effort: si falla, no rompemos la app.
        }
    }
}
