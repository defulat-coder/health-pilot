#!/usr/bin/env swift

import AppKit
import Foundation

struct Config {
    let referenceDir: URL
    let candidateDir: URL
    let manifestURL: URL?
    let failOnExtraCandidates: Bool
    let maxMeanDiff: Double
    let maxPixelDiff: Int
    let ignoreBottomPixels: Int
}

struct Manifest: Decodable {
    struct Scenario: Decodable {
        let file: String
    }

    let scenarios: [Scenario]
}

struct Result: Encodable {
    let name: String
    let status: String
    let width: Int?
    let height: Int?
    let meanDiff: Double?
    let maxDiff: Int?
    let reason: String?
}

func parseConfig() throws -> Config {
    let args = CommandLine.arguments
    func value(after flag: String) -> String? {
        guard let index = args.firstIndex(of: flag), args.indices.contains(index + 1) else {
            return nil
        }
        return args[index + 1]
    }

    guard let reference = value(after: "--reference"),
          let candidate = value(after: "--candidate") else {
        throw NSError(
            domain: "CompareScreenshots",
            code: 2,
            userInfo: [NSLocalizedDescriptionKey: "Usage: compare-screenshots.swift --reference <dir> --candidate <dir> [--max-mean-diff 12] [--max-pixel-diff 255]"]
        )
    }

    let maxMean = Double(value(after: "--max-mean-diff") ?? "12") ?? 12
    let maxPixel = Int(value(after: "--max-pixel-diff") ?? "255") ?? 255
    let ignoreBottomPixels = Int(value(after: "--ignore-bottom-pixels") ?? "18") ?? 18
    let failOnExtraCandidates = args.contains("--fail-on-extra-candidates")

    let manifest = value(after: "--manifest").map { URL(fileURLWithPath: $0) }

    return Config(
        referenceDir: URL(fileURLWithPath: reference),
        candidateDir: URL(fileURLWithPath: candidate),
        manifestURL: manifest,
        failOnExtraCandidates: failOnExtraCandidates,
        maxMeanDiff: maxMean,
        maxPixelDiff: maxPixel,
        ignoreBottomPixels: max(0, ignoreBottomPixels)
    )
}

func rgbaPixels(from url: URL) throws -> (width: Int, height: Int, data: [UInt8]) {
    guard let image = NSImage(contentsOf: url),
          let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        throw NSError(domain: "CompareScreenshots", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot read image \(url.path)"])
    }

    let width = cgImage.width
    let height = cgImage.height
    let bytesPerPixel = 4
    let bytesPerRow = width * bytesPerPixel
    var data = [UInt8](repeating: 0, count: height * bytesPerRow)

    guard let context = CGContext(
        data: &data,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw NSError(domain: "CompareScreenshots", code: 4, userInfo: [NSLocalizedDescriptionKey: "Cannot create bitmap context"])
    }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    return (width, height, data)
}

func compare(reference: URL, candidate: URL, config: Config) -> Result {
    do {
        if reference.standardizedFileURL.path == candidate.standardizedFileURL.path {
            return Result(
                name: reference.lastPathComponent,
                status: "pass",
                width: nil,
                height: nil,
                meanDiff: 0,
                maxDiff: 0,
                reason: "same file"
            )
        }

        let lhs = try rgbaPixels(from: reference)
        let rhs = try rgbaPixels(from: candidate)

        guard lhs.width == rhs.width, lhs.height == rhs.height else {
            return Result(
                name: reference.lastPathComponent,
                status: "fail",
                width: rhs.width,
                height: rhs.height,
                meanDiff: nil,
                maxDiff: nil,
                reason: "size mismatch: reference \(lhs.width)x\(lhs.height), candidate \(rhs.width)x\(rhs.height)"
            )
        }

        var total = 0
        var maxDiff = 0
        var samples = 0
        var index = 0
        let comparedHeight = max(0, lhs.height - config.ignoreBottomPixels)
        for y in 0..<comparedHeight {
            var x = 0
            while x < lhs.width {
                index = (y * lhs.width + x) * 4
                for channel in 0..<3 {
                    let diff = abs(Int(lhs.data[index + channel]) - Int(rhs.data[index + channel]))
                    total += diff
                    maxDiff = max(maxDiff, diff)
                    samples += 1
                }
                x += 1
            }
        }

        if samples == 0 {
            for index in stride(from: 0, to: lhs.data.count, by: 4) {
                for channel in 0..<3 {
                    let diff = abs(Int(lhs.data[index + channel]) - Int(rhs.data[index + channel]))
                    total += diff
                    maxDiff = max(maxDiff, diff)
                    samples += 1
                }
            }
        }

        let mean = Double(total) / Double(samples)
        let passed = mean <= config.maxMeanDiff && maxDiff <= config.maxPixelDiff
        return Result(
            name: reference.lastPathComponent,
            status: passed ? "pass" : "fail",
            width: lhs.width,
            height: lhs.height,
            meanDiff: mean,
            maxDiff: maxDiff,
            reason: passed ? nil : "diff exceeds thresholds"
        )
    } catch {
        return Result(
            name: reference.lastPathComponent,
            status: "fail",
            width: nil,
            height: nil,
            meanDiff: nil,
            maxDiff: nil,
            reason: error.localizedDescription
        )
    }
}

do {
    let config = try parseConfig()
    let fileManager = FileManager.default
    let references: [URL]
    var expectedCandidateFiles = Set<String>()
    if let manifestURL = config.manifestURL {
        let manifest = try JSONDecoder().decode(Manifest.self, from: Data(contentsOf: manifestURL))
        references = manifest.scenarios.map { config.referenceDir.appendingPathComponent($0.file) }
        expectedCandidateFiles = Set(manifest.scenarios.map(\.file))
    } else {
        references = try fileManager.contentsOfDirectory(
            at: config.referenceDir,
            includingPropertiesForKeys: nil
        )
        .filter { $0.pathExtension.lowercased() == "png" }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
        expectedCandidateFiles = Set(references.map(\.lastPathComponent))
    }

    var results: [Result] = references.map { reference in
        let candidate = config.candidateDir.appendingPathComponent(reference.lastPathComponent)
        guard fileManager.fileExists(atPath: candidate.path) else {
            return Result(
                name: reference.lastPathComponent,
                status: "missing",
                width: nil,
                height: nil,
                meanDiff: nil,
                maxDiff: nil,
                reason: "candidate missing"
            )
        }
        return compare(reference: reference, candidate: candidate, config: config)
    }

    if config.failOnExtraCandidates {
        let actualCandidatePNGs = try fileManager.contentsOfDirectory(
            at: config.candidateDir,
            includingPropertiesForKeys: nil
        )
        .filter { $0.pathExtension.lowercased() == "png" }
        .map(\.lastPathComponent)
        .sorted()

        for extra in actualCandidatePNGs where !expectedCandidateFiles.contains(extra) {
            results.append(Result(
                name: extra,
                status: "extra",
                width: nil,
                height: nil,
                meanDiff: nil,
                maxDiff: nil,
                reason: "candidate PNG is not declared in manifest"
            ))
        }
    }

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    print(String(data: try encoder.encode(results), encoding: .utf8)!)

    if results.contains(where: { $0.status != "pass" }) {
        exit(1)
    }
} catch {
    FileHandle.standardError.write(Data((error.localizedDescription + "\n").utf8))
    exit(2)
}
