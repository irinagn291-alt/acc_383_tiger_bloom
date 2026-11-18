// Tiger Bloom — the entire application and its conditional UI tests live in this file.

#if BLOOM_UI_TESTS
import XCTest

final class TigerBloomTests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    func test01ColoringPersistenceAndExport() {
        let app = XCUIApplication()
        app.launch()
        capture(app, "01-Explore")
        app.buttons["featured"].tap()
        let canvas = app.descendants(matching: .any)["canvas"].firstMatch
        XCTAssertTrue(canvas.waitForExistence(timeout: 8))
        app.buttons["Tangerine"].tap()
        let blank = canvas.screenshot().pngRepresentation
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.51, dy: 0.50)).tap()
        XCTAssertEqual(app.staticTexts["editCount"].label, "1 edit")
        XCTAssertNotEqual(canvas.screenshot().pngRepresentation, blank)
        app.buttons["Undo"].tap()
        XCTAssertEqual(app.staticTexts["editCount"].label, "0 edits")
        XCTAssertEqual(canvas.screenshot().pngRepresentation, blank)
        app.buttons["Redo"].tap()
        app.buttons["Lagoon"].tap()
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.19, dy: 0.21)).tap()
        app.buttons["Zoom in"].tap()
        XCTAssertTrue(app.buttons["Fit page"].exists)
        app.buttons["Fit page"].tap()
        capture(app, "02-Coloring")
        app.terminate()
        app.launch()
        app.buttons["featured"].tap()
        XCTAssertEqual(app.staticTexts["editCount"].label, "2 edits")
        app.buttons["export"].tap()
        app.buttons["Save to Photos"].tap()
        XCTAssertTrue(app.staticTexts["Your artwork was saved to Photos."].waitForExistence(timeout: 12), app.debugDescription)
        app.buttons["OK"].tap()
        app.buttons["export"].tap()
        app.buttons["Save PNG to Files"].tap()
        let save = app.buttons["Save"]
        XCTAssertTrue(save.waitForExistence(timeout: 8), app.debugDescription)
        save.tap()
        XCTAssertTrue(save.waitForNonExistence(timeout: 8))
    }

    func test02BrushEraseAndUndoHistory() {
        let app = XCUIApplication()
        app.launch()
        search(app, "stained glass")
        app.buttons["page-artStainedGlassTiger"].tap()
        let canvas = app.descendants(matching: .any)["canvas"].firstMatch
        XCTAssertTrue(canvas.waitForExistence(timeout: 8))
        let blank = canvas.screenshot().pngRepresentation
        app.buttons["Brush"].tap()
        app.buttons["Coral"].tap()
        let start = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.35, dy: 0.45))
        let end = canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.65, dy: 0.55))
        start.press(forDuration: 0.08, thenDragTo: end)
        XCTAssertEqual(app.staticTexts["editCount"].label, "1 edit")
        let drawn = canvas.screenshot().pngRepresentation
        XCTAssertNotEqual(drawn, blank)
        app.buttons["Erase"].tap()
        start.press(forDuration: 0.08, thenDragTo: end)
        XCTAssertEqual(app.staticTexts["editCount"].label, "2 edits")
        XCTAssertNotEqual(canvas.screenshot().pngRepresentation, drawn)
        app.buttons["Undo"].tap()
        XCTAssertEqual(canvas.screenshot().pngRepresentation, drawn)
        app.buttons["Undo"].tap()
        XCTAssertEqual(canvas.screenshot().pngRepresentation, blank)
        app.buttons["Fill"].tap()
        app.buttons["Lagoon"].tap()
        start.tap()
        XCTAssertFalse(app.buttons["Redo"].isEnabled)
        app.buttons["Reset artwork"].tap()
        app.buttons["Clear artwork"].tap()
        XCTAssertEqual(canvas.screenshot().pngRepresentation, blank)
        app.buttons["Undo"].tap()
        XCTAssertNotEqual(canvas.screenshot().pngRepresentation, blank)
    }

    func test03CollectionSearchAndFavorites() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertEqual(app.staticTexts["collectionCount"].label, "100 pages")
        app.buttons["Tigers"].tap()
        XCTAssertEqual(app.staticTexts["collectionCount"].label, "70 pages")
        app.buttons["Wildlife"].tap()
        XCTAssertEqual(app.staticTexts["collectionCount"].label, "30 pages")
        app.buttons["All 100"].tap()
        search(app, "poppy")
        app.buttons["page-artPoppyTiger"].tap()
        if app.buttons["favorite"].label == "Add favorite" { app.buttons["favorite"].tap() }
        app.terminate()
        app.launch()
        app.buttons["Favorites"].tap()
        XCTAssertEqual(app.staticTexts["collectionCount"].label, "1 page")
        XCTAssertTrue(app.buttons["page-artPoppyTiger"].exists)
        search(app, "penguin from mars")
        XCTAssertTrue(app.staticTexts["No matching pages"].exists)
        app.buttons["tab-My Art"].tap()
        XCTAssertTrue(app.buttons["page-artPoppyTiger"].exists)
        capture(app, "03-My-Art")
    }

    func test04CameraFallbackAndPhotoImport() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["tab-Photo Lab"].tap()
        capture(app, "04-Photo-Lab")
        app.buttons["camera"].tap()
        XCTAssertTrue(app.alerts["Camera and photos"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["A camera is unavailable on this device. Choose a picture from your photo library."].exists)
        app.buttons["OK"].tap()
        app.buttons["photoLibrary"].tap()
        let thumbnail = app.images.matching(NSPredicate(format: "label BEGINSWITH[c] %@", "Photo,")).firstMatch
        XCTAssertTrue(thumbnail.waitForExistence(timeout: 12), app.debugDescription)
        thumbnail.tap()
        let canvas = app.descendants(matching: .any)["canvas"].firstMatch
        XCTAssertTrue(canvas.waitForExistence(timeout: 12), app.debugDescription)
        app.buttons["Tangerine"].tap()
        let blank = canvas.screenshot().pngRepresentation
        canvas.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertNotEqual(canvas.screenshot().pngRepresentation, blank)
        XCTAssertEqual(app.staticTexts["editCount"].label, "1 edit")
        capture(app, "05-Photo-Coloring")
        app.terminate()
        app.launch()
        app.buttons["tab-My Art"].tap()
        app.scrollViews.firstMatch.swipeUp()
        let photo = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Photo study 1")).firstMatch
        XCTAssertTrue(photo.waitForExistence(timeout: 8), app.debugDescription)
        photo.tap()
        XCTAssertTrue(app.staticTexts["editCount"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["editCount"].label, "1 edit")
    }

    private func search(_ app: XCUIApplication, _ value: String) {
        let search = app.textFields["search"]
        search.tap()
        search.typeText(value + "\n")
    }
    private func capture(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
}

#else
import SwiftUI
import Photos
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers
import ImageIO


struct AnimalPage: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    init(_ id: String, _ title: String, _ subtitle: String) { self.id = id; self.title = title; self.subtitle = subtitle }
}

struct PenLine: Codable, Equatable {
    var points: [CGPoint]
    let width: CGFloat
    let ink: Int?
    let region: Int?
}

enum ArtEdit: Codable, Equatable {
    case fill(Int, Int)
    case line(PenLine)
    case clear
}

struct Painting: Codable, Equatable {
    var edits: [ArtEdit] = []
    var cursor = 0
    var active: ArraySlice<ArtEdit> {
        let visible = edits.prefix(min(max(0, cursor), edits.count))
        guard let clear = visible.lastIndex(of: .clear) else { return visible }
        return visible.suffix(from: clear + 1)
    }
    var fills: [Int: Int] {
        var result: [Int: Int] = [:]
        for case let .fill(region, ink) in active {
            result[region] = ink == 0xffffff ? nil : ink
        }
        return result
    }
    mutating func append(_ edit: ArtEdit) {
        edits = Array(edits.prefix(cursor))
        edits.append(edit)
        cursor = edits.count
    }
}

extension Color {
    static func ink(_ hex: Int) -> Color {
        Color(red: Double((hex >> 16) & 255) / 255, green: Double((hex >> 8) & 255) / 255, blue: Double(hex & 255) / 255)
    }
}

final class ArtSheet {
    let outline: UIImage
    let pixels: Data
    let side: Int
    private let masks = NSCache<NSNumber, UIImage>()

    init?(outline: UIImage, pixels: Data) {
        let size = Int(Double(pixels.count).squareRoot())
        guard size > 0, size * size == pixels.count else { return nil }
        self.outline = outline; self.pixels = pixels; self.side = size
        masks.totalCostLimit = 24 * 1024 * 1024
    }
    func region(_ point: CGPoint) -> Int {
        let x = min(side - 1, max(0, Int(point.x * CGFloat(side))))
        let y = min(side - 1, max(0, Int(point.y * CGFloat(side))))
        return Int(pixels[y * side + x])
    }
    func painted(_ fills: [Int: Int]) -> UIImage? {
        guard !fills.isEmpty else { return nil }
        var colors = [UInt8](repeating: 255, count: 256 * 3)
        for (region, ink) in fills where (1...255).contains(region) {
            for channel in 0..<3 { colors[region * 3 + channel] = UInt8((ink >> ((2 - channel) * 8)) & 255) }
        }
        guard let space = CGColorSpace(indexedBaseSpace: CGColorSpaceCreateDeviceRGB(), last: 255, colorTable: colors),
              let provider = CGDataProvider(data: pixels as CFData),
              let image = CGImage(width: side, height: side, bitsPerComponent: 8, bitsPerPixel: 8, bytesPerRow: side,
                                  space: space, bitmapInfo: CGBitmapInfo(rawValue: 0), provider: provider, decode: nil,
                                  shouldInterpolate: false, intent: .defaultIntent) else { return nil }
        return UIImage(cgImage: image)
    }
    func mask(_ region: Int) -> UIImage? {
        let key = NSNumber(value: region)
        if let cached = masks.object(forKey: key) { return cached }
        var rgba = [UInt16](repeating: 0, count: pixels.count)
        pixels.withUnsafeBytes { (source: UnsafeRawBufferPointer) in
            for i in 0..<source.count where Int(source[i]) == region { rgba[i] = .max }
        }
        let data = rgba.withUnsafeBytes { Data($0) }
        guard let provider = CGDataProvider(data: data as CFData),
              let image = CGImage(width: side, height: side, bitsPerComponent: 8, bitsPerPixel: 16, bytesPerRow: side * 2,
                                  space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                                  provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent) else { return nil }
        let mask = UIImage(cgImage: image)
        masks.setObject(mask, forKey: key, cost: data.count)
        return mask
    }
}

private struct PhotoPage: Codable {
    let outline: Data
    let regions: Data

    static func create(from data: Data) throws -> PhotoPage {
        let side = 256
        let options: [CFString: Any] = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                         kCGImageSourceCreateThumbnailWithTransform: true, kCGImageSourceThumbnailMaxPixelSize: 640]
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let photo = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { throw CocoaError(.fileReadCorruptFile) }
        let count = side * side
        var gray = [UInt8](repeating: 255, count: count)
        let space = CGColorSpaceCreateDeviceGray()
        let rendered = gray.withUnsafeMutableBytes { bytes -> Bool in
            guard let ctx = CGContext(data: bytes.baseAddress, width: side, height: side, bitsPerComponent: 8,
                                      bytesPerRow: side, space: space, bitmapInfo: CGImageAlphaInfo.none.rawValue) else { return false }
            let scale = CGFloat(side) / CGFloat(max(photo.width, photo.height))
            let w = CGFloat(photo.width) * scale, h = CGFloat(photo.height) * scale
            ctx.interpolationQuality = .high
            ctx.draw(photo, in: CGRect(x: (CGFloat(side) - w)/2, y: (CGFloat(side) - h)/2, width: w, height: h))
            return true
        }
        guard rendered else { throw CocoaError(.fileReadCorruptFile) }
        var tone = gray
        for y in 1..<side-1 {
            for x in 1..<side-1 {
                let i = y * side + x
                let sum = Int(gray[i])*4 + Int(gray[i-1])+Int(gray[i+1])+Int(gray[i-side])+Int(gray[i+side])
                tone[i] = UInt8(sum / 8)
            }
        }
        let levels = tone.map { Int($0) / 30 }
        var labels = [Int](repeating: -1, count: count), sizes = [Int]()
        func adjacent(_ i: Int, _ visit: (Int) -> Void) {
            if i % side > 0 { visit(i-1) }; if i % side < side-1 { visit(i+1) }
            if i >= side { visit(i-side) }; if i < count-side { visit(i+side) }
        }
        var queue = [Int]()
        for start in 0..<count where labels[start] == -1 {
            let label = sizes.count
            queue.removeAll(keepingCapacity: true); queue.append(start); labels[start] = label
            var head = 0
            while head < queue.count {
                let i = queue[head]; head += 1
                adjacent(i) { j in
                    if labels[j] == -1 && levels[j] == levels[start] { labels[j] = label; queue.append(j) }
                }
            }
            sizes.append(queue.count)
        }
        let ranked = sizes.indices.sorted { sizes[$0] > sizes[$1] }
        let keep = ranked.prefix(200).filter { sizes[$0] >= 15 || $0 == ranked.first }
        let ids = Dictionary(uniqueKeysWithValues: keep.enumerated().map { ($1, UInt8($0+1)) })
        var map = labels.map { ids[$0] ?? 0 }
        queue = map.indices.filter { map[$0] != 0 }
        var head = 0
        while head < queue.count {
            let i = queue[head]; head += 1
            adjacent(i) { j in if map[j] == 0 { map[j] = map[i]; queue.append(j) } }
        }
        var ink = [UInt8](repeating: 255, count: count)
        for i in 0..<count {
            if (i % side > 0 && map[i-1] != map[i]) || (i >= side && map[i-side] != map[i]) { ink[i] = 48 }
        }
        guard let provider = CGDataProvider(data: Data(ink) as CFData),
              let image = CGImage(width: side, height: side, bitsPerComponent: 8, bitsPerPixel: 8, bytesPerRow: side,
                                  space: space, bitmapInfo: CGBitmapInfo(rawValue: 0), provider: provider, decode: nil,
                                  shouldInterpolate: true, intent: .defaultIntent),
              let png = UIImage(cgImage: image).pngData() else { throw CocoaError(.fileWriteUnknown) }
        return PhotoPage(outline: png, regions: Data(map))
    }
}

@MainActor final class AnimalBook: ObservableObject {
    let originals: [AnimalPage]
    private let defaults: UserDefaults
    private let directory: URL
    @Published private(set) var custom: [String]
    @Published private(set) var works: [String: Painting] = [:]
    @Published var errorMessage: String?
    @Published private(set) var favorites: Set<String>

    func toggleFavorite(_ id: String) {
        if favorites.contains(id) { favorites.remove(id) } else { favorites.insert(id) }
        defaults.set(Array(favorites), forKey: "bloom.favorites")
    }

    func deletePhoto(_ id: String) {
        guard custom.contains(id) else { return }
        do {
            for suffix in [".page", ".json"] {
                let url = directory.appendingPathComponent(id + suffix)
                if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
            }
            custom.removeAll { $0 == id }
            works[id] = nil
            cache.removeObject(forKey: id as NSString)
            favorites.remove(id)
            defaults.set(custom, forKey: "coloring.photoIDs")
            defaults.set(Array(favorites), forKey: "bloom.favorites")
        } catch { errorMessage = "This photo page could not be deleted. Please try again." }
    }
    private let cache = NSCache<NSString, ArtSheet>()
    var pages: [AnimalPage] {
        originals + custom.enumerated().map { AnimalPage($0.element, "Photo study " + String($0.offset + 1), "From your photos") }
    }

    init(_ originals: [AnimalPage], defaults: UserDefaults = .standard,
         directory: URL = URL.applicationSupportDirectory.appendingPathComponent("TigerBloom", isDirectory: true)) {
        self.originals = originals
        self.defaults = defaults
        self.directory = directory
        favorites = Set(defaults.stringArray(forKey: "bloom.favorites") ?? [])
        custom = defaults.stringArray(forKey: "coloring.photoIDs") ?? []
        for id in originals.map(\.id) + custom {
            let url = directory.appendingPathComponent(id + ".json")
            if let data = try? Data(contentsOf: url), let saved = try? JSONDecoder().decode(Painting.self, from: data) { works[id] = saved }
        }
        cache.countLimit = 8
    }
    func sheet(_ id: String) -> ArtSheet? {
        if let sheet = cache.object(forKey: id as NSString) { return sheet }
        var result: ArtSheet?
        if let outline = UIImage(named: id), let map = NSDataAsset(name: id + "Map") {
            result = ArtSheet(outline: outline, pixels: map.data)
        } else if let data = try? Data(contentsOf: directory.appendingPathComponent(id + ".page")),
                  let page = try? PropertyListDecoder().decode(PhotoPage.self, from: data), let outline = UIImage(data: page.outline) {
            result = ArtSheet(outline: outline, pixels: page.regions)
        }
        if let result { cache.setObject(result, forKey: id as NSString) }
        return result
    }
    func importPhoto(_ data: Data) async throws -> AnimalPage {
        let directory = self.directory
        let id = UUID().uuidString
        try await Task.detached(priority: .userInitiated) {
            let page = try PhotoPage.create(from: data)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try PropertyListEncoder().encode(page).write(to: directory.appendingPathComponent(id + ".page"), options: .atomic)
        }.value
        custom.append(id)
        defaults.set(custom, forKey: "coloring.photoIDs")
        return AnimalPage(id, "Photo study " + String(custom.count), "From your photos")
    }
    func change(_ id: String, _ update: (inout Painting) -> Void) {
        var painting = works[id] ?? Painting()
        update(&painting)
        painting.cursor = min(max(0, painting.cursor), painting.edits.count)
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try JSONEncoder().encode(painting).write(to: directory.appendingPathComponent(id + ".json"), options: .atomic)
            works[id] = painting
        } catch { errorMessage = "Your changes could not be saved. Check the available space on this device." }
    }
}

struct AnimalCanvas: View {
    let sheet: ArtSheet
    let painting: Painting
    var live: PenLine? = nil

    var body: some View {
        ZStack {
            Color.white
            Canvas { context, size in
                for edit in painting.active {
                    switch edit {
                    case let .fill(region, ink):
                        if let mask = sheet.mask(region) {
                            var fill = context
                            let bounds = CGRect(origin: .zero, size: size)
                            fill.clipToLayer { $0.draw(Image(uiImage: mask), in: bounds) }
                            fill.fill(Path(bounds), with: .color(.ink(ink)))
                        }
                    case let .line(line): draw(line, in: context, size: size)
                    case .clear: break
                    }
                }
                if let live { draw(live, in: context, size: size) }
            }
            Image(uiImage: sheet.outline).resizable().blendMode(.multiply)
        }.compositingGroup().aspectRatio(1, contentMode: .fit)
    }
    private func draw(_ line: PenLine, in context: GraphicsContext, size: CGSize) {
        guard let first = line.points.first else { return }
        var ctx = context
        let bounds = CGRect(origin: .zero, size: size)
        if let region = line.region, let mask = sheet.mask(region) {
            ctx.clipToLayer { layer in layer.draw(Image(uiImage: mask), in: bounds) }
        }
        let shade = GraphicsContext.Shading.color(.ink(line.ink ?? 0xffffff))
        let width = size.width * line.width
        func pixel(_ p: CGPoint) -> CGPoint { CGPoint(x: p.x * size.width, y: p.y * size.height) }
        let origin = pixel(first)
        if line.points.count == 1 {
            ctx.fill(Path(ellipseIn: CGRect(x: origin.x-width/2, y: origin.y-width/2, width: width, height: width)), with: shade)
        } else {
            var path = Path(); path.move(to: origin)
            for point in line.points.dropFirst() { path.addLine(to: pixel(point)) }
            ctx.stroke(path, with: shade, style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
        }
    }
}

struct ColoringPNG: FileDocument {
    static var readableContentTypes: [UTType] { [.png] }
    let bytes: Data
    init(_ bytes: Data) { self.bytes = bytes }
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else { throw CocoaError(.fileReadCorruptFile) }; bytes = data
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents: bytes) }
}

struct ExportArt<Artwork: View>: View {
    let name: String
    @ViewBuilder var artwork: () -> Artwork
    @State private var file: ColoringPNG?
    @State private var exporting = false
    @State private var message: String?

    var body: some View {
        Menu {
            Button("Save PNG to Files", systemImage: "folder") {
                guard let data = png() else { message = "Couldn’t create the PNG."; return }
                file = ColoringPNG(data); exporting = true
            }
            Button("Save to Photos", systemImage: "photo") {
                Task { @MainActor in
                    #if DEBUG && targetEnvironment(simulator)
                    guard BloomScreenshot.current == nil else { return }
                    #endif
                    let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
                    guard status == .authorized || status == .limited else {
                        message = "Allow access in Settings or choose Save PNG to Files."; return
                    }
                    guard let data = png() else { message = "Couldn’t create the PNG."; return }
                    do {
                        try await PHPhotoLibrary.shared().performChanges {
                            let options = PHAssetResourceCreationOptions()
                            options.originalFilename = name + ".png"
                            PHAssetCreationRequest.forAsset().addResource(with: .photo, data: data, options: options)
                        }
                        message = "Your artwork was saved to Photos."
                    } catch { message = "Couldn’t save your artwork to Photos." }
                }
            }
        } label: { Label("Export", systemImage: "square.and.arrow.up") }
        .accessibilityIdentifier("export")
        .fileExporter(isPresented: $exporting, document: file, contentType: .png, defaultFilename: name) { result in
            if case .failure(let error) = result, (error as NSError).code != NSUserCancelledError { message = "Couldn’t save the PNG." }
        }
        .alert("Export artwork", isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })) {
            Button("OK", role: .cancel) {}
        } message: { Text(message ?? "") }
    }
    @MainActor private func png() -> Data? {
        let renderer = ImageRenderer(content: artwork().frame(width: 600))
        renderer.scale = 3; renderer.isOpaque = true
        return renderer.uiImage?.pngData()
    }
}


struct PhotoInput: View {
    let receive: (Data) async throws -> Void
    @State private var selection: PhotosPickerItem?
    @State private var busy = false
    @State private var camera = false
    @State private var issue: String?
    @State private var needsSettings = false
    @Environment(\.openURL) private var openURL

    var body: some View {
        HStack(spacing: 10) {
            PhotosPicker(selection: $selection, matching: .images) {
                Label("Photo library", systemImage: "photo.on.rectangle")
            }.accessibilityIdentifier("photoLibrary")
            Button { Task { await openCamera() } } label: {
                Label("Camera", systemImage: "camera")
            }.accessibilityIdentifier("camera")
            if busy { ProgressView().accessibilityLabel("Loading photo") }
        }.buttonStyle(.borderedProminent).controlSize(.large).foregroundStyle(.white).disabled(busy)
        .onChange(of: selection) { _, item in
            guard let item else { return }
            busy = true
            Task { @MainActor in
                defer { busy = false; selection = nil }
                do {
                    guard let data = try await item.loadTransferable(type: Data.self) else { throw CocoaError(.fileReadCorruptFile) }
                    try await receive(data)
                } catch { issue = "This photo could not be opened. Try another image." }
            }
        }
        .fullScreenCover(isPresented: $camera) {
            CameraCapture { result in
                camera = false
                Task { @MainActor in
                    busy = true
                    defer { busy = false }
                    do { if let data = try result.get() { try await receive(data) } }
                    catch { issue = "The photo could not be saved. Please try again." }
                }
            }.ignoresSafeArea()
        }
        .alert("Camera and photos", isPresented: Binding(get: { issue != nil }, set: { if !$0 { issue = nil } })) {
            if needsSettings {
                Button("Open Settings") { if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) } }
            }
            Button("OK", role: .cancel) {}
        } message: { Text(issue ?? "") }
    }

    @MainActor private func openCamera() async {
        #if DEBUG && targetEnvironment(simulator)
        guard BloomScreenshot.current == nil else { return }
        #endif
        needsSettings = false
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            issue = "A camera is unavailable on this device. Choose a picture from your photo library."
            return
        }
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        let granted = status == .notDetermined ? await AVCaptureDevice.requestAccess(for: .video) : status == .authorized
        guard granted else {
            needsSettings = AVCaptureDevice.authorizationStatus(for: .video) == .denied
            issue = "Camera access is turned off. You can still choose a picture from your photo library."
            return
        }
        camera = true
    }
}

private struct CameraCapture: UIViewControllerRepresentable {
    let finish: (Result<Data?, Error>) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(finish: finish) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ picker: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let finish: (Result<Data?, Error>) -> Void
        init(finish: @escaping (Result<Data?, Error>) -> Void) { self.finish = finish }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { finish(.success(nil)) }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard let photo = info[.originalImage] as? UIImage, let data = photo.jpegData(compressionQuality: 0.92) else {
                finish(.failure(CocoaError(.fileReadCorruptFile)))
                return
            }
            finish(.success(data))
        }
    }
}

let bloomPages = [
    AnimalPage("artPoppyTiger", "Poppy tiger", "Wildflowers"),
    AnimalPage("monarch", "Tiger mask", "Portrait"),
    AnimalPage("bengal", "Bengal tiger", "Bamboo grove"),
    AnimalPage("artStainedGlassTiger", "Stained glass tiger", "Glasswork"),
    AnimalPage("artMangroveTiger", "Mangrove tiger", "Tidal channels"),
    AnimalPage("artSpiralTiger", "Spiral tiger", "Curved forms"),
    AnimalPage("artTigerCubChase", "Tiger cub chase", "Meadow play"),
    AnimalPage("artRockHoppingTiger", "Rock-hopping tiger", "Mountain stream"),
    AnimalPage("artPaperBoatTiger", "Paper boat tiger", "Cub adventures"),
    AnimalPage("artFrostWhiskeredTiger", "Frost-whiskered tiger", "Winter portrait"),
    AnimalPage("artConstellationTiger", "Constellation tiger", "Star map"),
    AnimalPage("artListeningTiger", "Listening tiger", "Forest sounds"),
    AnimalPage("artCheckerboardTiger", "Checkerboard tiger", "Graphic blocks"),
    AnimalPage("artTigerInTheGrasses", "Tiger in the grasses", "Golden savanna"),
    AnimalPage("leap", "Leaping tiger", "Motion"),
    AnimalPage("cub", "Tiger cub", "Lotus pond"),
    AnimalPage("artPapercutTiger", "Papercut tiger", "Cut paper"),
    AnimalPage("artLotusTiger", "Lotus tiger", "Floating garden"),
    AnimalPage("artCrescentTiger", "Crescent tiger", "Moon shape"),
    AnimalPage("artYawningTigerCub", "Yawning tiger cub", "Morning den"),
    AnimalPage("artBambooFanTiger", "Bamboo fan tiger", "Botanical print"),
    AnimalPage("artTigerScentMark", "Tiger scent mark", "Old sal tree"),
    AnimalPage("artLanternTiger", "Lantern tiger", "Festival night"),
    AnimalPage("artTigerInFreshSnow", "Tiger in fresh snow", "Snowdrifts"),
    AnimalPage("artEclipseTiger", "Eclipse tiger", "Celestial poster"),
    AnimalPage("artTigerPawWash", "Tiger paw wash", "Quiet clearing"),
    AnimalPage("artLighthouseTiger", "Lighthouse tiger", "Coastal emblem"),
    AnimalPage("artTigerInAFigTree", "Tiger in a fig tree", "Forest perch"),
    AnimalPage("profileTiger", "Roaring tiger", "Profile"),
    AnimalPage("riverTiger", "Riverside tiger", "Drinking pool"),
    AnimalPage("artQuiltBlockTiger", "Quilt block tiger", "Patchwork"),
    AnimalPage("artCascadeTiger", "Cascade tiger", "Waterfall ledge"),
    AnimalPage("artDiamondTiger", "Diamond tiger", "Geometric portrait"),
    AnimalPage("artTigerCubAndMoth", "Tiger cub and moth", "Night garden"),
    AnimalPage("artGinkgoTiger", "Ginkgo tiger", "Autumn botanicals"),
    AnimalPage("artClimbingTiger", "Climbing tiger", "Forked trunk"),
    AnimalPage("restingStripe", "Reclining tiger", "Silhouette"),
    AnimalPage("winterTiger", "Winter tiger", "Snowy pines"),
    AnimalPage("artTelescopeTiger", "Telescope tiger", "Stargazing cub"),
    AnimalPage("artTigerAtTheIceHole", "Tiger at the ice hole", "Frozen river"),
    AnimalPage("artCometTiger", "Comet tiger", "Motion poster"),
    AnimalPage("artSunbathingTiger", "Sunbathing tiger", "Warm boulder"),
    AnimalPage("artSnowGlobeTiger", "Snow globe tiger", "Winter ornament"),
    AnimalPage("artTigerOnBlackSand", "Tiger on black sand", "Coastal forest"),
    AnimalPage("artCeramicTiger", "Ceramic tiger", "Tilework"),
    AnimalPage("artPebbleBeachTiger", "Pebble beach tiger", "Rocky shore"),
    AnimalPage("artLoopingTiger", "Looping tiger", "Ribbon line"),
    AnimalPage("artTigerGroomingTime", "Tiger grooming time", "Family life"),
    AnimalPage("artVineSwingTiger", "Vine swing tiger", "Leaf and line"),
    AnimalPage("artTigerTracks", "Tiger tracks", "Sandy path"),
    AnimalPage("artBookNookTiger", "Book nook tiger", "Reading corner"),
    AnimalPage("artSnowCaveTiger", "Snow cave tiger", "Winter shelter"),
    AnimalPage("artMountainBadgeTiger", "Mountain badge tiger", "Travel print"),
    AnimalPage("artTigerScratchingBark", "Tiger scratching bark", "Claw marks"),
    AnimalPage("moonCub", "Moon tiger cub", "Moonlight"),
    AnimalPage("sumatranTiger", "Sumatran tiger", "Fern forest"),
    AnimalPage("artTigerBookends", "Tiger bookends", "Paired portraits"),
    AnimalPage("artTigerBesideOrchids", "Orchard tiger", "Fruit trees"),
    AnimalPage("curlTiger", "Curled tiger", "Silhouette"),
    AnimalPage("tigerFamily", "Tiger and cub", "Family portrait"),
    AnimalPage("artMosaicTiger", "Mosaic tiger", "Stone mosaic"),
    AnimalPage("artReedBedTiger", "Reed bed tiger", "Marsh edge"),
    AnimalPage("artTwinTigerCircle", "Twin tiger circle", "Balance"),
    AnimalPage("artTigerCubTug", "Tiger cub tug", "Fallen vine"),
    AnimalPage("artMapleTiger", "Maple tiger", "Autumn print"),
    AnimalPage("artRidgeTrailTiger", "Ridge trail tiger", "Open highlands"),
    AnimalPage("artRainBootTiger", "Rain boot tiger", "Rainy morning"),
    AnimalPage("artTigerOnTheBirchTrail", "Tiger on the birch trail", "Birch woodland"),
    AnimalPage("artWaveCrestTiger", "Wave crest tiger", "Ocean print"),
    AnimalPage("artTailChasingTiger", "Tail-chasing tiger", "Cub meadow"),
    AnimalPage("fox", "Fox in the brush", "Woodland"),
    AnimalPage("elephant", "Asian elephant", "River bend"),
    AnimalPage("crane", "Sunrise crane", "Flight"),
    AnimalPage("panda", "Red panda", "Forest canopy"),
    AnimalPage("chameleon", "Chameleon curl", "Canopy"),
    AnimalPage("owl", "Horned owl", "Moonlit pines"),
    AnimalPage("artMoonJelly", "Moon jelly", "Ocean drift"),
    AnimalPage("artCloudedLeopard", "Clouded leopard", "Rainforest branch"),
    AnimalPage("artMountainIbex", "Mountain ibex", "Alpine crest"),
    AnimalPage("artRaccoonAtTheCreek", "Raccoon at the creek", "Creek bank"),
    AnimalPage("butterfly", "Painted wings", "Insects"),
    AnimalPage("turtle", "Sea turtle", "Coral garden"),
    AnimalPage("bear", "Bloom bear", "Woodland"),
    AnimalPage("deer", "Woodland deer", "Wildflower meadow"),
    AnimalPage("artNautilusShell", "Nautilus shell", "Ocean spiral"),
    AnimalPage("artRedCrownedParakeet", "Red-crowned parakeet", "Forest fruit"),
    AnimalPage("seahorse", "Sea scroll", "Ocean"),
    AnimalPage("rabbit", "Forest rabbit", "Mushroom hollow"),
    AnimalPage("artCoralCuttlefish", "Coral cuttlefish", "Ocean camouflage"),
    AnimalPage("artArcticFox", "Arctic fox", "Tundra den"),
    AnimalPage("lion", "Sunburst lion", "Portrait"),
    AnimalPage("snowLeopard", "Snow leopard", "Alpine rocks"),
    AnimalPage("artLunaMoth", "Luna moth", "Night wings"),
    AnimalPage("artIndianGaur", "Indian gaur", "Woodland grazing"),
    AnimalPage("zebra", "Striped zebra", "Pattern"),
    AnimalPage("bison", "Prairie bison", "Tallgrass plains"),
    AnimalPage("artLemurRingtail", "Lemur ringtail", "Tree canopy"),
    AnimalPage("artBinturong", "Binturong", "Night canopy"),
    AnimalPage("koala", "Eucalyptus koala", "Woodland"),
    AnimalPage("giantPanda", "Giant panda", "Bamboo grove"),
]

// MARK: - Visual language

enum BloomStyle {
    static let paper = Color.ink(0xFAF6EE)
    static let ink = Color.ink(0x243D3A)
    static let coral = Color.ink(0xC94A38)
    static let teal = Color.ink(0x18766F)
    static let peach = Color.ink(0xF7DBCC)
    static let mint = Color.ink(0xD8E9DD)
    static let line = Color.ink(0xDEDCD3)
}

struct BloomKicker: View {
    let text: String
    var body: some View {
        Text(text.uppercased()).font(.system(size: 10, weight: .bold, design: .monospaced)).tracking(1.8)
    }
}

#if DEBUG && targetEnvironment(simulator)
private struct BloomScreenshot {
    enum Screen: String, CaseIterable {
        case explore
        case studio = "coloring-studio"
        case gallery = "my-art"
        case photoLab = "photo-lab"
    }

    let screen: Screen
    let defaults: UserDefaults

    static let current: BloomScreenshot? = {
        let process = ProcessInfo.processInfo
        let arguments = process.arguments
        func value(after flag: String) -> String? {
            guard let flagIndex = arguments.firstIndex(of: flag),
                  arguments.indices.contains(flagIndex + 1) else { return nil }
            return arguments[flagIndex + 1]
        }

        let screen: Screen?
        if arguments.contains("-ReviewScreen") {
            screen = value(after: "-ReviewScreen").flatMap(Screen.init(rawValue:))
        } else {
            let indexValue: String?
            if arguments.contains("-AppStoreScreenshots") {
                indexValue = value(after: "-AppStoreScreenshotScreen")
            } else if let enabled = process.environment["APPSTORE_SCREENSHOTS"],
                      ["1", "true", "yes", "on"].contains(enabled.lowercased()) {
                indexValue = process.environment["APPSTORE_SCREENSHOT_SCREEN"]
            } else {
                return nil
            }
            let screens = Screen.allCases
            guard let indexValue, let index = Int(indexValue), screens.indices.contains(index) else { return nil }
            screen = screens[index]
        }

        let suite = "studio.tiger.bloom.screenshots"
        guard let screen, let defaults = UserDefaults(suiteName: suite) else { return nil }
        defaults.removePersistentDomain(forName: suite)
        return BloomScreenshot(screen: screen, defaults: defaults)
    }()

    @MainActor func makeBook() -> AnimalBook {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("TigerBloom-Screenshots", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let book = AnimalBook(bloomPages, defaults: defaults, directory: directory)
        let palette = Dictionary(uniqueKeysWithValues: BloomPalette.colors)
        func paint(_ pageID: String, _ fills: [(region: Int, color: String)]) {
            book.change(pageID) { painting in
                for (region, color) in fills {
                    if let ink = palette[color] { painting.append(.fill(region, ink)) }
                }
            }
        }

        if screen == .studio || screen == .gallery {
            paint("artPoppyTiger", [(2, "Tangerine"), (6, "Lagoon"), (7, "Leaf"),
                                    (8, "Lagoon"), (10, "Tangerine"), (14, "Leaf")])
        }
        if screen == .gallery {
            paint("artStainedGlassTiger", [(2, "Buttercup"), (3, "Blueberry"), (6, "Lilac"),
                                           (7, "Lilac"), (9, "Sky"), (11, "Sky")])
            paint("bengal", [(2, "Oat"), (4, "Tangerine"), (5, "Buttercup"),
                             (8, "Leaf"), (11, "Leaf"), (24, "Lime")])
        }
        return book
    }
}
#endif

@main struct TigerBloomApp: App {
    @StateObject private var book: AnimalBook

    @MainActor init() {
        #if DEBUG && targetEnvironment(simulator)
        if let capture = BloomScreenshot.current {
            _book = StateObject(wrappedValue: capture.makeBook())
            return
        }
        #endif
        _book = StateObject(wrappedValue: AnimalBook(bloomPages))
    }

    var body: some Scene {
        WindowGroup {
            #if DEBUG && targetEnvironment(simulator)
            if let capture = BloomScreenshot.current {
                home.defaultAppStorage(capture.defaults)
                    .transaction {
                        $0.animation = nil
                        $0.disablesAnimations = true
                    }
            } else {
                home
            }
            #else
            home
            #endif
        }
    }

    private var home: some View {
        BloomHome(book: book)
            .preferredColorScheme(.light)
            .tint(BloomStyle.coral)
            .environment(\.locale, Locale(identifier: "en"))
            .alert("Tiger Bloom", isPresented: Binding(get: { book.errorMessage != nil }, set: { if !$0 { book.errorMessage = nil } })) {
                Button("OK", role: .cancel) {}
            } message: { Text(book.errorMessage ?? "") }
    }
}

// MARK: - Collection, personal gallery and photo lab

enum BloomSection: String, CaseIterable {
    case collection = "Explore", gallery = "My Art", photos = "Photo Lab"
    var symbol: String {
        switch self {
        case .collection: "square.grid.2x2.fill"
        case .gallery: "rectangle.stack.fill"
        case .photos: "camera.on.rectangle.fill"
        }
    }
}

struct BloomHome: View {
    @ObservedObject var book: AnimalBook
    @State private var section: BloomSection = .collection
    @State private var path: [AnimalPage] = []
    @State private var query = ""
    @State private var filter = "All 100"
    @State private var deleting: AnimalPage?
    @AppStorage("bloom.lastPage") private var lastPage = "artPoppyTiger"

    @MainActor init(book: AnimalBook) {
        self.book = book
        #if DEBUG && targetEnvironment(simulator)
        if let capture = BloomScreenshot.current {
            switch capture.screen {
            case .explore:
                break
            case .studio:
                _path = State(initialValue: book.originals.filter { $0.id == "artPoppyTiger" })
            case .gallery:
                _section = State(initialValue: .gallery)
            case .photoLab:
                _section = State(initialValue: .photos)
            }
        }
        #endif
    }

    private var visiblePages: [AnimalPage] {
        let source = section == .gallery ? book.pages.filter {
            book.custom.contains($0.id) || !(book.works[$0.id]?.active.isEmpty ?? true)
        } : book.originals
        return source.filter { page in
            let textMatches = query.isEmpty || (page.title + " " + page.subtitle).localizedCaseInsensitiveContains(query)
            let categoryMatches = section == .gallery || filter == "All 100"
                || (filter == "Tigers" && page.title.localizedCaseInsensitiveContains("tiger"))
                || (filter == "Wildlife" && !page.title.localizedCaseInsensitiveContains("tiger"))
                || (filter == "Favorites" && book.favorites.contains(page.id))
            return textMatches && categoryMatches
        }
    }
    private var featured: AnimalPage { book.pages.first { $0.id == lastPage } ?? book.originals[0] }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    switch section {
                    case .collection:
                        hero
                        collection
                    case .gallery:
                        galleryHeading
                        collection
                    case .photos:
                        photoLab
                    }
                }
                .padding(.horizontal, 22).padding(.top, 12).padding(.bottom, 24)
                .frame(maxWidth: 1120).frame(maxWidth: .infinity)
            }
            .background(BloomStyle.paper).foregroundStyle(BloomStyle.ink)
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) { navigation }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: AnimalPage.self) { page in
                BloomStudio(book: book, page: page).onAppear { lastPage = page.id }
            }
            .confirmationDialog("Delete this photo page and its artwork?", isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }), titleVisibility: .visible) {
                Button("Delete photo page", role: .destructive) {
                    if let page = deleting { book.deletePhoto(page.id) }
                    deleting = nil
                }
                Button("Cancel", role: .cancel) { deleting = nil }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image("BloomBadge").resizable().frame(width: 42, height: 42).clipShape(RoundedRectangle(cornerRadius: 13))
            VStack(alignment: .leading, spacing: 2) {
                Text("Tiger Bloom").font(.system(size: 24, weight: .heavy, design: .rounded)).tracking(-0.8)
                BloomKicker(text: "The color club").foregroundStyle(BloomStyle.teal)
            }
            Spacer(minLength: 4)
            Image(systemName: "sparkles").font(.title2).foregroundStyle(BloomStyle.coral)
                .padding(9).background(BloomStyle.peach, in: Circle()).accessibilityHidden(true)
        }
    }

    private var hero: some View {
        Button { path.append(featured) } label: {
            VStack(spacing: 0) {
                HStack(spacing: 6) {
                    VStack(alignment: .leading, spacing: 12) {
                        BloomKicker(text: "70 tigers. Endless color.").fixedSize(horizontal: false, vertical: true)
                        Text("Let your\ncolors\nrun wild.")
                            .font(.system(size: 39, weight: .black, design: .rounded)).tracking(-1.8)
                            .lineSpacing(-3).minimumScaleFactor(0.75)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    VStack(spacing: 8) {
                        if let sheet = book.sheet(featured.id) {
                            AnimalCanvas(sheet: sheet, painting: book.works[featured.id] ?? Painting())
                                .padding(8).background(.white)
                        }
                        BloomKicker(text: "Made to be yours").foregroundStyle(BloomStyle.teal)
                    }
                    .padding(10).background(.white)
                    .frame(maxWidth: 210).rotationEffect(.degrees(7))
                    .shadow(color: BloomStyle.coral.opacity(0.13), radius: 0, x: 7, y: 8)
                    .padding(.vertical, 15).padding(.trailing, 8)
                }.padding(20).background(BloomStyle.peach)
                HStack(spacing: 10) {
                    Image(systemName: "paintbrush.pointed.fill")
                    VStack(alignment: .leading, spacing: 3) {
                        Text(book.works[featured.id]?.active.isEmpty ?? true ? "Start something colorful" : "Keep your colors flowing")
                            .font(.system(size: 15, weight: .bold))
                        Text(featured.title).font(.caption).opacity(0.85)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right").font(.title3.bold())
                }.padding(17).foregroundStyle(.white).background(BloomStyle.coral)
            }.clipShape(RoundedRectangle(cornerRadius: 24))
        }.buttonStyle(.plain).accessibilityIdentifier("featured")
    }

    private var galleryHeading: some View {
        VStack(alignment: .leading, spacing: 9) {
            BloomKicker(text: "Your personal collection").foregroundStyle(BloomStyle.teal)
            Text("Look what\nyou made.").font(.system(size: 40, weight: .black, design: .rounded)).tracking(-1.3)
            Text("Every stroke is saved. Come back whenever inspiration strikes.")
                .font(.subheadline).foregroundStyle(.secondary)
        }.padding(.vertical, 8)
    }

    private var collection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text(section == .gallery ? "Your artwork" : "Find your next favorite")
                    .font(.system(size: 23, weight: .heavy, design: .rounded)).tracking(-0.7)
                Spacer()
                Text(visiblePages.count == 1 ? "1 page" : "\(visiblePages.count) pages").font(.caption.monospacedDigit()).foregroundStyle(BloomStyle.teal)
                    .accessibilityIdentifier("collectionCount")
            }
            if section == .collection {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(["All 100", "Tigers", "Wildlife", "Favorites"], id: \.self) { category in
                            Button { filter = category } label: {
                                Text(category).font(.subheadline.weight(.semibold)).padding(.horizontal, 16).padding(.vertical, 12)
                                    .background(filter == category ? BloomStyle.ink : .white, in: Capsule())
                                    .foregroundStyle(filter == category ? .white : BloomStyle.ink)
                            }.buttonStyle(.plain).accessibilityAddTraits(filter == category ? .isSelected : [])
                        }
                    }
                }.scrollIndicators(.hidden)
            }
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass").foregroundStyle(BloomStyle.teal)
                TextField("Find an animal or a scene", text: $query)
                    .font(.subheadline).autocorrectionDisabled().submitLabel(.search).accessibilityIdentifier("search")
                if !query.isEmpty {
                    Button { query = "" } label: { Image(systemName: "xmark.circle.fill") }
                        .accessibilityLabel("Clear search").frame(minWidth: 30, minHeight: 30)
                }
            }.padding(.horizontal, 15).padding(.vertical, 10).background(.white, in: RoundedRectangle(cornerRadius: 16))
            if visiblePages.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: section == .gallery ? "paintpalette" : "sparkle.magnifyingglass").font(.largeTitle)
                    Text(emptyTitle).font(.headline)
                    Text(emptyDescription).font(.subheadline).multilineTextAlignment(.center).foregroundStyle(.secondary)
                    if section == .gallery && query.isEmpty {
                        Button("Explore coloring pages") { section = .collection; filter = "All 100" }.buttonStyle(.borderedProminent)
                    }
                }.frame(maxWidth: .infinity).padding(.vertical, 40).accessibilityIdentifier("emptyCollection")
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 260), spacing: 14)], spacing: 18) {
                ForEach(visiblePages) { page in
                    Button { path.append(page) } label: { BloomCard(book: book, page: page) }
                        .buttonStyle(.plain).accessibilityIdentifier("page-" + page.id)
                        .contextMenu {
                            Button(book.favorites.contains(page.id) ? "Remove favorite" : "Add favorite", systemImage: "heart") { book.toggleFavorite(page.id) }
                            if book.custom.contains(page.id) {
                                Button("Delete photo page", systemImage: "trash", role: .destructive) { deleting = page }
                            }
                        }
                }
            }
        }
    }

    private var emptyTitle: String {
        if !query.isEmpty { return "No matching pages" }
        return section == .gallery ? "Your gallery starts here" : "Save the ones you love"
    }
    private var emptyDescription: String {
        if !query.isEmpty { return "Try another animal, scene or a different collection." }
        return section == .gallery ? "Color a page or import a photo to make it your own." : "Tap the heart in the studio to add a favorite."
    }

    private var photoLab: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    BloomKicker(text: "From real life to color").foregroundStyle(BloomStyle.teal)
                    Text("Your world.\nYour palette.").font(.system(size: 32, weight: .black, design: .rounded)).tracking(-1)
                }.frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "camera.macro").font(.system(size: 48, weight: .light))
                    .foregroundStyle(BloomStyle.teal).padding(16).background(.white, in: RoundedRectangle(cornerRadius: 20))
                    .rotationEffect(.degrees(8)).accessibilityHidden(true)
            }.padding(22).background(BloomStyle.mint, in: RoundedRectangle(cornerRadius: 24))
            VStack(alignment: .leading, spacing: 12) {
                Text("Make a photo page").font(.system(size: 25, weight: .heavy, design: .rounded))
                Text("Turn a photo into a mosaic of outlined shapes, then fill it with your favorite colors.")
                    .foregroundStyle(.secondary)
                PhotoInput { data in
                    let page = try await book.importPhoto(data)
                    path.append(page)
                }.padding(.top, 7)
            }
            VStack(alignment: .leading, spacing: 22) {
                photoTip("01", "Pick a clear subject", "Pets, plants and simple objects work beautifully.", "sun.max")
                photoTip("02", "Make it your own", "Fill a shape or switch to the brush for little details.", "paintbrush.pointed")
                photoTip("03", "Keep your creation", "Your page joins My Art. Export a PNG to Photos or Files.", "square.and.arrow.down")
            }.padding(22).background(.white, in: RoundedRectangle(cornerRadius: 22))
            Label("Photos are processed on your device.", systemImage: "lock.shield")
                .font(.footnote).foregroundStyle(BloomStyle.teal)
        }.frame(maxWidth: 740).frame(maxWidth: .infinity)
    }

    private func photoTip(_ number: String, _ title: String, _ detail: String, _ symbol: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(number).font(.system(.caption, design: .monospaced, weight: .bold)).foregroundStyle(BloomStyle.coral).padding(.top, 4)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Image(systemName: symbol).foregroundStyle(BloomStyle.teal)
        }
    }

    private var navigation: some View {
        HStack(spacing: 5) {
            ForEach(BloomSection.allCases, id: \.self) { item in
                Button {
                    section = item
                    query = ""
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: item.symbol).font(.system(size: 18, weight: .semibold))
                        Text(item.rawValue).font(.system(size: 11, weight: .bold))
                    }.frame(maxWidth: .infinity).padding(.vertical, 11)
                        .foregroundStyle(section == item ? BloomStyle.coral : BloomStyle.ink.opacity(0.62))
                        .background(section == item ? BloomStyle.peach.opacity(0.65) : .clear, in: RoundedRectangle(cornerRadius: 18))
                        .contentShape(Rectangle())
                }.buttonStyle(.plain).accessibilityLabel(item.rawValue)
                    .accessibilityIdentifier("tab-" + item.rawValue).accessibilityAddTraits(section == item ? .isSelected : [])
            }
        }.padding(7).background(.white, in: RoundedRectangle(cornerRadius: 25))
            .overlay(RoundedRectangle(cornerRadius: 25).strokeBorder(BloomStyle.line, lineWidth: 1))
            .padding(.horizontal, 22).padding(.top, 8).padding(.bottom, 5)
            .frame(maxWidth: 600).frame(maxWidth: .infinity).background(BloomStyle.paper.opacity(0.96))
    }
}

struct BloomCard: View {
    @ObservedObject var book: AnimalBook
    let page: AnimalPage
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let sheet = book.sheet(page.id) {
                AnimalCanvas(sheet: sheet, painting: book.works[page.id] ?? Painting())
                    .padding(10).background(.white)
                    .overlay(alignment: .topTrailing) {
                        if book.favorites.contains(page.id) {
                            Image(systemName: "heart.fill").font(.caption).foregroundStyle(BloomStyle.coral)
                                .padding(8).background(.white, in: Circle()).padding(5)
                        }
                    }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(page.title).font(.system(size: 15, weight: .bold, design: .rounded)).lineLimit(2)
                Text(page.subtitle).font(.system(size: 11)).foregroundStyle(.secondary).lineLimit(1)
            }.padding(12).frame(maxWidth: .infinity, alignment: .leading).background(.white)
        }.clipShape(RoundedRectangle(cornerRadius: 17))
            .overlay(RoundedRectangle(cornerRadius: 17).strokeBorder(BloomStyle.line, lineWidth: 1))
    }
}

// MARK: - The coloring studio

enum BloomTool: String, CaseIterable {
    case fill = "Fill", brush = "Brush", erase = "Erase", move = "Move"
    var symbol: String {
        switch self {
        case .fill: "drop.fill"
        case .brush: "paintbrush.pointed.fill"
        case .erase: "eraser.fill"
        case .move: "hand.draw.fill"
        }
    }
}

struct BloomStudio: View {
    @ObservedObject var book: AnimalBook
    let page: AnimalPage
    @AppStorage("bloom.ink") private var ink = 0xF59A3E
    @AppStorage("bloom.brushWidth") private var width = 0.035
    @AppStorage("bloom.stayInside") private var stayInside = true
    @State private var tool: BloomTool = .fill
    @State private var live: PenLine?
    @State private var zoom = false
    @State private var clearing = false
    private var work: Painting { book.works[page.id] ?? Painting() }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        BloomKicker(text: book.custom.contains(page.id) ? "Your photo page" : page.subtitle)
                        Spacer()
                        Label("Saved", systemImage: "checkmark.circle.fill").font(.caption.weight(.medium)).foregroundStyle(BloomStyle.teal)
                    }
                    if proxy.size.width > 760 {
                        HStack(alignment: .top, spacing: 24) {
                            paper.frame(maxWidth: .infinity)
                            controls.frame(width: 300)
                        }
                    } else {
                        #if DEBUG && targetEnvironment(simulator)
                        if BloomScreenshot.current != nil {
                            // Keep the palette in frame on short simulator displays.
                            paper.frame(maxWidth: max(1, proxy.size.height - 380))
                                .frame(maxWidth: .infinity)
                        } else {
                            paper
                        }
                        #else
                        paper
                        #endif
                        controls
                    }
                }.padding(18).frame(maxWidth: 1260).frame(maxWidth: .infinity)
            }
        }
        .background(BloomStyle.paper).foregroundStyle(BloomStyle.ink)
        .navigationTitle(page.title).navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { book.toggleFavorite(page.id) } label: {
                    Image(systemName: book.favorites.contains(page.id) ? "heart.fill" : "heart")
                }.accessibilityLabel(book.favorites.contains(page.id) ? "Remove favorite" : "Add favorite")
                    .accessibilityIdentifier("favorite")
            }
            ToolbarItem(placement: .topBarTrailing) {
                if let sheet = book.sheet(page.id) {
                    ExportArt(name: page.title) { AnimalCanvas(sheet: sheet, painting: work) }
                        .labelStyle(.iconOnly)
                }
            }
        }
        .confirmationDialog("Start this page again?", isPresented: $clearing, titleVisibility: .visible) {
            Button("Clear artwork", role: .destructive) { book.change(page.id) { $0.append(.clear) } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("You can undo this while your edit history is saved.") }
    }

    private var paper: some View {
        VStack(spacing: 10) {
            if let sheet = book.sheet(page.id) {
                GeometryReader { geo in
                    let side = geo.size.width * (zoom ? 2.4 : 1)
                    ScrollView([.horizontal, .vertical]) {
                        AnimalCanvas(sheet: sheet, painting: work, live: live)
                            .frame(width: side, height: side).contentShape(Rectangle())
                            .onTapGesture(coordinateSpace: .local) { location in
                                guard tool == .fill else { return }
                                let region = sheet.region(CGPoint(x: location.x / side, y: location.y / side))
                                book.change(page.id) { $0.append(.fill(region, ink)) }
                            }
                            .highPriorityGesture(DragGesture(minimumDistance: 0).onChanged { event in
                                let p = CGPoint(x: max(0, min(1, event.location.x / side)), y: max(0, min(1, event.location.y / side)))
                                if live == nil {
                                    live = PenLine(points: [p], width: width, ink: tool == .erase ? nil : ink, region: stayInside ? sheet.region(p) : nil)
                                } else if let previous = live?.points.last, hypot(previous.x - p.x, previous.y - p.y) > 0.002 {
                                    live?.points.append(p)
                                }
                            }.onEnded { _ in
                                if let stroke = live { book.change(page.id) { $0.append(.line(stroke)) } }
                                live = nil
                            }, including: tool == .brush || tool == .erase ? .all : .none)
                            .accessibilityElement(children: .ignore).accessibilityLabel("Coloring canvas").accessibilityIdentifier("canvas")
                    }.defaultScrollAnchor(.center).scrollIndicators(.hidden)
                        .scrollDisabled(!zoom || tool == .brush || tool == .erase)
                }.aspectRatio(1, contentMode: .fit).clipped()
            }
            HStack(spacing: 4) {
                Button { book.change(page.id) { $0.cursor -= 1 } } label: { Image(systemName: "arrow.uturn.backward").frame(width: 44, height: 44) }
                    .disabled(work.cursor == 0).accessibilityLabel("Undo")
                Button { book.change(page.id) { $0.cursor += 1 } } label: { Image(systemName: "arrow.uturn.forward").frame(width: 44, height: 44) }
                    .disabled(work.cursor >= work.edits.count).accessibilityLabel("Redo")
                Spacer(minLength: 0)
                Text(work.cursor == 1 ? "1 edit" : "\(work.cursor) edits").font(.caption.monospacedDigit()).foregroundStyle(.secondary).accessibilityIdentifier("editCount")
                Spacer(minLength: 0)
                Button { zoom.toggle(); if tool == .move && !zoom { tool = .fill } } label: {
                    Image(systemName: zoom ? "arrow.down.right.and.arrow.up.left" : "plus.magnifyingglass").frame(width: 44, height: 44)
                }.accessibilityLabel(zoom ? "Fit page" : "Zoom in")
                Button { clearing = true } label: { Image(systemName: "arrow.counterclockwise").frame(width: 44, height: 44) }
                    .disabled(work.active.isEmpty).accessibilityLabel("Reset artwork")
            }.font(.system(size: 17, weight: .medium))
        }.padding(10).background(.white, in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(BloomStyle.line, lineWidth: 1))
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                ForEach(BloomTool.allCases, id: \.self) { item in
                    Button {
                        live = nil
                        tool = item
                        if item == .move { zoom = true }
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: item.symbol).font(.system(size: 19))
                            Text(item.rawValue).font(.system(size: 11, weight: .bold))
                        }.frame(maxWidth: .infinity).padding(.vertical, 12)
                            .foregroundStyle(tool == item ? .white : BloomStyle.ink)
                            .background(tool == item ? BloomStyle.teal : .white, in: RoundedRectangle(cornerRadius: 16))
                    }.buttonStyle(.plain).accessibilityLabel(item.rawValue).accessibilityAddTraits(tool == item ? .isSelected : [])
                }
            }
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    BloomKicker(text: "The color box")
                    Spacer()
                    ColorPicker("Custom color", selection: Binding(get: { Color.ink(ink) }, set: { color in
                        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                        guard UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a) else { return }
                        ink = (Int(r * 255) << 16) | (Int(g * 255) << 8) | Int(b * 255)
                        if tool == .erase || tool == .move { tool = .fill }
                    }), supportsOpacity: false).labelsHidden().accessibilityLabel("Custom color")
                }
                BloomPalette(ink: Binding(get: { ink }, set: { ink = $0; if tool == .erase || tool == .move { tool = .fill } }))
            }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 20))
            if tool == .brush || tool == .erase {
                VStack(spacing: 8) {
                    HStack {
                        Text("Brush size").font(.caption.weight(.semibold))
                        Slider(value: $width, in: 0.008...0.14).accessibilityLabel("Brush size")
                    }
                    Toggle("Stay inside the lines", isOn: $stayInside).font(.subheadline)
                }.padding(.horizontal, 3)
            }
            Label(toolHint, systemImage: "lightbulb.min").font(.footnote).foregroundStyle(BloomStyle.teal)
                .fixedSize(horizontal: false, vertical: true).padding(.horizontal, 3)
        }
    }

    private var toolHint: String {
        switch tool {
        case .fill: "Pick a color, then tap a shape. Try Paper to clear a whole shape."
        case .brush: "Draw with your finger. Turn off Stay inside the lines for freehand strokes."
        case .erase: "Brush over color to erase it. Your printed outlines stay in place."
        case .move: "Drag to explore the enlarged page. Choose Fill or Brush to keep coloring."
        }
    }
}

struct BloomPalette: View {
    @Binding var ink: Int
    static let colors: [(String, Int)] = [
        ("Tangerine", 0xF59A3E), ("Coral", 0xEF674F), ("Buttercup", 0xF5CD57),
        ("Blush", 0xEDAFBA), ("Lilac", 0xA38BD1), ("Blueberry", 0x586EBC), ("Sky", 0x84CADF),
        ("Lagoon", 0x32ACA5), ("Leaf", 0x7CA566), ("Lime", 0xC1D776),
        ("Oat", 0xE5C7A0), ("Cocoa", 0x91654D), ("Charcoal", 0x283C39), ("Paper", 0xFFFFFF)
    ]
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 7) {
            ForEach(Self.colors, id: \.1) { color in
                Button { ink = color.1 } label: {
                    Circle().fill(Color.ink(color.1)).padding(5)
                        .overlay(Circle().strokeBorder(ink == color.1 ? BloomStyle.ink : BloomStyle.line, lineWidth: ink == color.1 ? 2 : 1))
                        .overlay {
                            if ink == color.1 {
                                Image(systemName: "checkmark").font(.system(size: 12, weight: .heavy))
                                    .foregroundStyle([0x283C39, 0x91654D, 0x586EBC].contains(color.1) ? .white : BloomStyle.ink)
                            }
                        }.aspectRatio(1, contentMode: .fit)
                }.buttonStyle(.plain).accessibilityLabel(color.0).accessibilityAddTraits(ink == color.1 ? .isSelected : [])
            }
        }
    }
}
#endif
