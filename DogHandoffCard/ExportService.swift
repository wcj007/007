import SwiftUI
import UIKit

enum ExportError: LocalizedError {
    case imageGenerationFailed

    var errorDescription: String? {
        switch self {
        case .imageGenerationFailed:
            return "Failed to generate the handoff card image. Please try again."
        }
    }
}

enum ExportService {
    @MainActor
    static func makeShareItems(snapshot: HandoffCardSnapshot) throws -> [Any] {
        let exportURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("DogHandoffCard-\(UUID().uuidString)", isDirectory: true)

        try FileManager.default.createDirectory(at: exportURL, withIntermediateDirectories: true)

        let image = try renderImage(snapshot: snapshot)

        let imageURL = exportURL.appendingPathComponent("dog-handoff-card.png")
        let pdfURL = exportURL.appendingPathComponent("dog-handoff-card.pdf")
        let textURL = exportURL.appendingPathComponent("dog-handoff-card.txt")

        guard let pngData = image.pngData() else {
            throw ExportError.imageGenerationFailed
        }

        try pngData.write(to: imageURL)
        try writePDF(from: image, to: pdfURL)
        try snapshot.plainText.write(to: textURL, atomically: true, encoding: .utf8)

        return [imageURL, pdfURL, textURL]
    }

    @MainActor
    private static func renderImage(snapshot: HandoffCardSnapshot) throws -> UIImage {
        let renderer = ImageRenderer(
            content: HandoffCardPrintView(snapshot: snapshot)
                .frame(width: 720)
                .padding(24)
                .background(Color(.systemGroupedBackground))
        )
        renderer.scale = UIScreen.main.scale

        guard let image = renderer.uiImage else {
            throw ExportError.imageGenerationFailed
        }

        return image
    }

    private static func writePDF(from image: UIImage, to url: URL) throws {
        let bounds = CGRect(x: 0, y: 0, width: image.size.width + 40, height: image.size.height + 40)
        let renderer = UIGraphicsPDFRenderer(bounds: bounds)

        let data = renderer.pdfData { context in
            context.beginPage()
            image.draw(in: CGRect(x: 20, y: 20, width: image.size.width, height: image.size.height))
        }

        try data.write(to: url)
    }
}
