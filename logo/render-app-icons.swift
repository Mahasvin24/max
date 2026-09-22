// Provenance: HAND-BUILT. Built from: SwiftUI ImageRenderer, Color, MaxVortex.
// Compile alongside MaxVortex.swift; pass the app's Assets.xcassets directory.
import SwiftUI
import ImageIO
import Foundation

private struct AppIconArtwork: View {
    var dark: Bool

    var body: some View {
        ZStack {
            // The system supplies the final icon mask. An inset rounded tile
            // leaves a visible frame when macOS places it on its own background.
            dark ? Color(.sRGB, white: 24.0 / 255, opacity: 1) : Color.white
            MaxVortex()
                .fill(dark ? Color(.sRGB, white: 233.0 / 255, opacity: 1) : Color.black)
                .frame(width: 778.24, height: 778.24)
        }
        .frame(width: 1024, height: 1024)
    }
}

@main
private struct RenderAppIcons {
    @MainActor
    static func main() throws {
        guard CommandLine.arguments.count == 2 else {
            throw failure("Pass the Assets.xcassets directory.")
        }
        let assets = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        var rendered: [String: Data] = [:]
        for (folder, baseSize) in [("AppIcon.appiconset", 0), ("Logo.imageset", 1024)] {
            let directory = assets.appendingPathComponent(folder)
            let catalog = try JSONDecoder().decode(Catalog.self, from: Data(contentsOf:
                directory.appendingPathComponent("Contents.json")))
            for entry in catalog.images {
                guard let filename = entry.filename else { continue }
                let points = entry.size?.split(separator: "x").first.flatMap { Int($0) } ?? baseSize
                let scale = Int(entry.scale.replacingOccurrences(of: "x", with: "")) ?? 1
                let pixels = points * scale
                let dark = entry.appearances?.contains { $0.appearance == "luminosity" && $0.value == "dark" } == true
                let key = "\(pixels)-\(dark)"
                guard pixels > 0 else { throw failure("Invalid icon dimensions for \(filename).") }
                if rendered[key] == nil {
                    let renderer = ImageRenderer(content: AppIconArtwork(dark: dark))
                    renderer.scale = CGFloat(pixels) / 1024
                    renderer.isOpaque = true
                    guard let image = renderer.cgImage,
                          image.width == pixels, image.height == pixels else {
                        throw failure("Could not render \(pixels) × \(pixels) icon.")
                    }
                    let data = NSMutableData()
                    guard let destination = CGImageDestinationCreateWithData(
                        data, "public.png" as CFString, 1, nil) else {
                        throw failure("Could not create PNG encoder.")
                    }
                    CGImageDestinationAddImage(destination, image, nil)
                    guard CGImageDestinationFinalize(destination) else {
                        throw failure("Could not encode PNG.")
                    }
                    rendered[key] = data as Data
                }
                try rendered[key]!.write(to: directory.appendingPathComponent(filename), options: .atomic)
                print("Rendered \(folder)/\(filename) (\(pixels) px)")
            }
        }
    }

    private struct Catalog: Decodable { let images: [Entry] }
    private struct Entry: Decodable {
        let filename: String?
        let scale: String
        let size: String?
        let appearances: [Appearance]?
    }
    private struct Appearance: Decodable { let appearance: String; let value: String }
    private static func failure(_ message: String) -> NSError {
        NSError(domain: "MaxVortexIconRenderer", code: 1,
                userInfo: [NSLocalizedDescriptionKey: message])
    }
}
