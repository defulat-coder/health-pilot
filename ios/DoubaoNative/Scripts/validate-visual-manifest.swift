#!/usr/bin/env swift

import AppKit
import Foundation

struct Manifest: Decodable {
    struct Capture: Decodable {
        let width: Int
        let height: Int
    }

    struct Scenario: Decodable {
        let file: String
        let snapshot: String
        let description: String
    }

    let capture: Capture
    let scenarios: [Scenario]
}

func value(after flag: String) -> String? {
    let args = CommandLine.arguments
    guard let index = args.firstIndex(of: flag), args.indices.contains(index + 1) else {
        return nil
    }
    return args[index + 1]
}

func imageSize(_ url: URL) -> (width: Int, height: Int)? {
    guard let image = NSImage(contentsOf: url),
          let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        return nil
    }
    return (cgImage.width, cgImage.height)
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let manifestURL = URL(fileURLWithPath: value(after: "--manifest") ?? "design/reference/doubao-mobile/manifest.json", relativeTo: root).standardizedFileURL
let referenceDir = manifestURL.deletingLastPathComponent()
let modelsURL = URL(fileURLWithPath: value(after: "--models") ?? "ios/DoubaoNative/DoubaoNative/Models.swift", relativeTo: root).standardizedFileURL
let appStateURL = URL(fileURLWithPath: value(after: "--app-state") ?? "ios/DoubaoNative/DoubaoNative/AppState.swift", relativeTo: root).standardizedFileURL
let captureScriptURL = URL(fileURLWithPath: value(after: "--capture-script") ?? "ios/DoubaoNative/Scripts/capture-ios-screenshots.sh", relativeTo: root).standardizedFileURL
let listScriptURL = URL(fileURLWithPath: value(after: "--list-script") ?? "ios/DoubaoNative/Scripts/visual-manifest-list.swift", relativeTo: root).standardizedFileURL

func snapshotCaseMap(from models: String) -> [String: String] {
    var result: [String: String] = [:]
    for line in models.split(separator: "\n") {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("case "), trimmed.contains("=") else { continue }
        let parts = trimmed.split(separator: "=", maxSplits: 1).map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard parts.count == 2 else { continue }
        let caseName = parts[0].replacingOccurrences(of: "case ", with: "")
        let rawValue = parts[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        result[rawValue] = caseName
    }
    return result
}

do {
    let manifest = try JSONDecoder().decode(Manifest.self, from: Data(contentsOf: manifestURL))
    let models = try String(contentsOf: modelsURL, encoding: .utf8)
    let appState = try String(contentsOf: appStateURL, encoding: .utf8)
    let captureScript = try String(contentsOf: captureScriptURL, encoding: .utf8)
    let listScript = try String(contentsOf: listScriptURL, encoding: .utf8)
    var failures: [String] = []
    var seenSnapshots = Set<String>()
    var seenFiles = Set<String>()
    let snapshotCases = snapshotCaseMap(from: models)
    if !captureScript.contains("visual-manifest-list.swift") {
        failures.append("Capture script must read scenarios through visual-manifest-list.swift")
    }

    if !listScript.contains("print(\"\\(scenario.snapshot)\\t\\(scenario.file)\")") {
        failures.append("visual-manifest-list.swift must emit snapshot/file tab-separated rows")
    }

    let manifestFiles = Set(manifest.scenarios.map(\.file))
    let actualReferencePNGs = try FileManager.default.contentsOfDirectory(
        at: referenceDir,
        includingPropertiesForKeys: nil
    )
    .filter { $0.pathExtension.lowercased() == "png" }
    .map(\.lastPathComponent)

    for extra in actualReferencePNGs where !manifestFiles.contains(extra) {
        failures.append("Reference PNG is not declared in manifest: \(extra)")
    }

    for scenario in manifest.scenarios {
        if !seenSnapshots.insert(scenario.snapshot).inserted {
            failures.append("Duplicate snapshot in manifest: \(scenario.snapshot)")
        }

        if !seenFiles.insert(scenario.file).inserted {
            failures.append("Duplicate file in manifest: \(scenario.file)")
        }

        let referenceURL = referenceDir.appendingPathComponent(scenario.file)
        guard FileManager.default.fileExists(atPath: referenceURL.path) else {
            failures.append("Missing reference image: \(scenario.file)")
            continue
        }

        guard let size = imageSize(referenceURL) else {
            failures.append("Unreadable reference image: \(scenario.file)")
            continue
        }

        if size.width != manifest.capture.width || size.height != manifest.capture.height {
            failures.append("Image size mismatch for \(scenario.file): \(size.width)x\(size.height), expected \(manifest.capture.width)x\(manifest.capture.height)")
        }

        guard let caseName = snapshotCases[scenario.snapshot] else {
            failures.append("SnapshotScenario raw value missing in Models.swift: \(scenario.snapshot)")
            continue
        }

        if !appState.contains("case .\(caseName):") {
            failures.append("AppState.applySnapshotScenario missing case: .\(caseName)")
        }
    }

    if failures.isEmpty {
        print("Visual manifest valid: \(manifest.scenarios.count) scenarios, \(manifest.capture.width)x\(manifest.capture.height)")
    } else {
        for failure in failures {
            FileHandle.standardError.write(Data((failure + "\n").utf8))
        }
        exit(1)
    }
} catch {
    FileHandle.standardError.write(Data((error.localizedDescription + "\n").utf8))
    exit(2)
}
