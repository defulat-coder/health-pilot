#!/usr/bin/env swift

import Foundation

struct Manifest: Decodable {
    struct Scenario: Decodable {
        let file: String
        let snapshot: String
    }

    let scenarios: [Scenario]
}

func value(after flag: String) -> String? {
    let args = CommandLine.arguments
    guard let index = args.firstIndex(of: flag), args.indices.contains(index + 1) else {
        return nil
    }
    return args[index + 1]
}

let manifestPath = value(after: "--manifest") ?? "design/reference/doubao-mobile/manifest.json"
let manifestURL = URL(fileURLWithPath: manifestPath)

do {
    let manifest = try JSONDecoder().decode(Manifest.self, from: Data(contentsOf: manifestURL))
    for scenario in manifest.scenarios {
        print("\(scenario.snapshot)\t\(scenario.file)")
    }
} catch {
    FileHandle.standardError.write(Data((error.localizedDescription + "\n").utf8))
    exit(2)
}
