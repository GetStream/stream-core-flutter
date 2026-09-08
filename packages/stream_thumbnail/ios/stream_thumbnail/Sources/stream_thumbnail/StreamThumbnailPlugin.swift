import AVFoundation
import Flutter
import UIKit
import libwebp

/// A generation failure that couldn't produce a frame/encode, or a failure
/// writing the encoded thumbnail to disk.
private enum ThumbnailError: Error {
  case generationFailed
  case writeFailed(NSError)
}

public class StreamThumbnailPlugin: NSObject, FlutterPlugin, StreamThumbnailHostApi {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = StreamThumbnailPlugin()
    StreamThumbnailHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
  }

  func thumbnailData(
    request: ThumbnailRequest, completion: @escaping (Result<FlutterStandardTypedData, Error>) -> Void
  ) {
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let data = try Self.generateThumbnailData(request: request)
        let result = FlutterStandardTypedData(bytes: data)
        DispatchQueue.main.async { completion(.success(result)) }
      } catch {
        DispatchQueue.main.async { completion(.failure(Self.pigeonError(for: error))) }
      }
    }
  }

  func thumbnailFile(
    request: ThumbnailRequest, completion: @escaping (Result<String, Error>) -> Void
  ) {
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let path = try Self.writeThumbnailFile(request: request)
        DispatchQueue.main.async { completion(.success(path)) }
      } catch {
        DispatchQueue.main.async { completion(.failure(Self.pigeonError(for: error))) }
      }
    }
  }

  private static func pigeonError(for error: Error) -> PigeonError {
    switch error {
    case ThumbnailError.generationFailed:
      return PigeonError(
        code: "THUMBNAIL_ERROR", message: "Failed to generate a thumbnail for the video.", details: nil)
    case ThumbnailError.writeFailed(let nsError):
      return PigeonError(code: "Error \(nsError.code)", message: nsError.domain, details: nsError.localizedDescription)
    default:
      return PigeonError(code: "THUMBNAIL_ERROR", message: (error as NSError).localizedDescription, details: nil)
    }
  }

  private static func videoURL(for video: String) throws -> URL {
    if video.hasPrefix("file://") {
      // Parsed as a URL first, so percent-encoding is decoded: `file:///tmp/a%20b.mp4`
      // names `a b.mp4`, not a literal `a%20b.mp4`. The raw path is the fallback for
      // every form URL parsing would get wrong or refuse:
      //
      // - `?` and `#` are legal in a file name but delimit a query/fragment here, so
      //   `file:///tmp/a#b.mp4` would otherwise parse to just `/tmp/a`.
      // - before iOS 17 / macOS 14 `URL(string:)` returns nil for a space or a
      //   non-ASCII byte, which is exactly what interpolating a bare path produces.
      // - a host other than `localhost` means the input wasn't really a URL, e.g.
      //   `file://clips/a.mp4`, where `clips` would be read as the host.
      if let url = URL(string: video), url.isFileURL,
        url.query == nil, url.fragment == nil,
        url.host.map({ $0.isEmpty || $0 == "localhost" }) ?? true
      {
        return url
      }
      return URL(fileURLWithPath: String(video.dropFirst(7)))
    } else if video.hasPrefix("/") {
      return URL(fileURLWithPath: video)
    } else if let url = URL(string: video) {
      return url
    }
    throw ThumbnailError.generationFailed
  }

  private static func writeThumbnailFile(request: ThumbnailRequest) throws -> String {
    let data = try generateThumbnailData(request: request)

    // The file name comes from the video, so a directory per request is what
    // keeps two same-named videos from different folders off each other.
    let outputDir = FileManager.default.temporaryDirectory
      .appendingPathComponent("stream_thumbnail", isDirectory: true)
      .appendingPathComponent(UUID().uuidString, isDirectory: true)

    let stem = try videoURL(for: request.video).deletingPathExtension().lastPathComponent
    let thumbnailURL = outputDir
      .appendingPathComponent(stem.isEmpty ? "thumbnail" : stem)
      .appendingPathExtension(fileExtension(for: request.format))

    do {
      try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
      try data.write(to: thumbnailURL, options: .atomic)
    } catch {
      throw ThumbnailError.writeFailed(error as NSError)
    }

    return thumbnailURL.path
  }

  private static func generateThumbnailData(request: ThumbnailRequest) throws -> Data {
    let url = try videoURL(for: request.video)

    var options: [String: Any]?
    if let headers = request.headers, !headers.isEmpty {
      options = ["AVURLAssetHTTPHeaderFieldsKey": headers]
    }

    let asset = AVURLAsset(url: url, options: options)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    generator.maximumSize = CGSize(width: CGFloat(request.maxWidth), height: CGFloat(request.maxHeight))
    generator.requestedTimeToleranceBefore = .zero
    generator.requestedTimeToleranceAfter = CMTime(value: 100, timescale: 1000)

    guard
      let cgImage = try? generator.copyCGImage(
        at: CMTime(value: request.timeMs, timescale: 1000), actualTime: nil)
    else {
      throw ThumbnailError.generationFailed
    }

    switch request.format {
    case .jpeg:
      guard let data = UIImage(cgImage: cgImage).jpegData(compressionQuality: CGFloat(request.quality) * 0.01)
      else {
        throw ThumbnailError.generationFailed
      }
      return data
    case .png:
      guard let data = UIImage(cgImage: cgImage).pngData() else {
        throw ThumbnailError.generationFailed
      }
      return data
    case .webp:
      return try encodeWebP(cgImage: cgImage, quality: Int(request.quality))
    }
  }

  private static func encodeWebP(cgImage: CGImage, quality: Int) throws -> Data {
    guard cgImage.colorSpace?.model == .rgb else {
      throw ThumbnailError.generationFailed
    }

    let alphaInfo = cgImage.alphaInfo
    guard alphaInfo == .premultipliedFirst || alphaInfo == .noneSkipFirst else {
      throw ThumbnailError.generationFailed
    }
    guard let cfData = cgImage.dataProvider?.data else {
      throw ThumbnailError.generationFailed
    }

    let width = Int32(cgImage.width)
    let height = Int32(cgImage.height)
    let stride = Int32(cgImage.bytesPerRow)
    let byteOrder = cgImage.bitmapInfo.intersection(.byteOrderMask)

    var bytes = [UInt8](repeating: 0, count: CFDataGetLength(cfData))
    bytes.withUnsafeMutableBufferPointer { buffer in
      CFDataGetBytes(cfData, CFRange(location: 0, length: buffer.count), buffer.baseAddress)
    }

    var output: UnsafeMutablePointer<UInt8>?
    var size = 0

    switch byteOrder {
    case .byteOrder32Little:
      // Little-endian (iPhone).
      bytes.withUnsafeMutableBufferPointer { buffer in
        if quality == 100 {
          size = WebPEncodeLosslessBGRA(buffer.baseAddress, width, height, stride, &output)
        } else {
          size = WebPEncodeBGRA(buffer.baseAddress, width, height, stride, Float(quality), &output)
        }
      }
    case .byteOrder32Big:
      // Big-endian (iPhone Simulator).
      bytes.withUnsafeMutableBufferPointer { buffer in
        let base = buffer.baseAddress!
        for y in 0..<Int(height) {
          (base + y * Int(stride)).withMemoryRebound(to: UInt32.self, capacity: Int(width)) { row in
            for x in 0..<Int(width) {
              let u = row[x]
              row[x] = ((u << 24) & 0xFF00_0000) | ((u >> 8) & 0x00FF_FFFF)
            }
          }
        }
        if quality == 100 {
          size = WebPEncodeLosslessRGBA(base, width, height, stride, &output)
        } else {
          size = WebPEncodeRGBA(base, width, height, stride, Float(quality), &output)
        }
      }
    default:
      throw ThumbnailError.generationFailed
    }

    guard size > 0, let output else {
      throw ThumbnailError.generationFailed
    }

    let data = Data(bytes: output, count: size)
    WebPFree(output)
    return data
  }

  private static func fileExtension(for format: ThumbnailFormat) -> String {
    switch format {
    case .jpeg: return "jpg"
    case .png: return "png"
    case .webp: return "webp"
    }
  }
}
