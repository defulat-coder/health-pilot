import Foundation

struct HTTPStreamingAssistantService: AssistantServicing {
    let baseURL: URL
    var session: URLSession = .shared

    init(baseURL: URL = URL(string: "http://127.0.0.1:7777")!, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func chatStream(for prompt: String) -> AsyncStream<String> {
        AsyncStream { continuation in
            Task {
                do {
                    var request = URLRequest(url: baseURL.appending(path: "agents/health-coach/runs"))
                    let boundary = "Boundary-\(UUID().uuidString)"
                    request.httpMethod = "POST"
                    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    request.httpBody = multipartBody(
                        boundary: boundary,
                        fields: [
                            "message": prompt,
                            "stream": "true",
                            "user_id": "default"
                        ]
                    )

                    let (bytes, response) = try await session.bytes(for: request)
                    if let http = response as? HTTPURLResponse,
                       !(200..<300).contains(http.statusCode) {
                        continuation.finish()
                        return
                    }

                    for try await line in bytes.lines {
                        guard let chunk = parseServerSentEventLine(line) else { continue }
                        continuation.yield(chunk)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish()
                }
            }
        }
    }

    func healthSummary(userID: String) async throws -> HealthSummary {
        var components = URLComponents(url: baseURL.appending(path: "api/v1/health-summary"), resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "user_id", value: userID)]
        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await session.data(from: url)
        if let http = response as? HTTPURLResponse,
           !(200..<300).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(HealthSummary.self, from: data)
    }

    func syncAppleHealthSamples(userID: String, samples: [AppleHealthSamplePayload]) async throws -> AppleHealthSyncResult {
        var request = URLRequest(url: baseURL.appending(path: "api/v1/apple-health/samples"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(AppleHealthSyncPayload(userID: userID, samples: samples))
        let (data, response) = try await session.data(for: request)
        try validate(response)
        return try JSONDecoder().decode(AppleHealthSyncResult.self, from: data)
    }

    func healthDashboard(userID: String) async throws -> HealthDataDashboard {
        let data = try await getJSON(path: "api/v1/apple-health/dashboard", userID: userID)
        return try JSONDecoder().decode(HealthDataDashboard.self, from: data)
    }

    func healthReports(userID: String) async throws -> [HealthAnalysisReport] {
        let data = try await getJSON(path: "api/v1/apple-health/reports", userID: userID)
        return try JSONDecoder().decode([HealthAnalysisReport].self, from: data)
    }

    func generateHealthReport(userID: String, kind: String) async throws -> HealthAnalysisReport {
        var request = URLRequest(url: baseURL.appending(path: "api/v1/apple-health/reports"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let today = ISO8601DateFormatter().string(from: Date()).prefix(10)
        request.httpBody = try JSONEncoder().encode(HealthReportPayload(userID: userID, kind: kind, periodStart: String(today), periodEnd: String(today)))
        let (data, response) = try await session.data(for: request)
        try validate(response)
        return try JSONDecoder().decode(HealthAnalysisReport.self, from: data)
    }

    func create(mode: CreationMode, prompt: String) async -> CreationResult {
        CreationResult(
            mode: mode,
            prompt: prompt,
            title: mode == .image ? "已提交图像生成" : "已提交视频生成"
        )
    }

    private func parseServerSentEventLine(_ line: String) -> String? {
        guard line.hasPrefix("data:") else { return nil }
        let payload = line.dropFirst(5).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !payload.isEmpty, payload != "[DONE]" else { return nil }

        if let data = payload.data(using: .utf8),
           let event = try? JSONDecoder().decode(ChatCompletionEvent.self, from: data) {
            return event.text ?? event.content
        }

        return payload
    }

    private func multipartBody(boundary: String, fields: [String: String]) -> Data {
        var body = Data()

        for (name, value) in fields {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }

        body.appendString("--\(boundary)--\r\n")
        return body
    }

    private func getJSON(path: String, userID: String) async throws -> Data {
        var components = URLComponents(url: baseURL.appending(path: path), resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "user_id", value: userID)]
        guard let url = components?.url else { throw URLError(.badURL) }
        let (data, response) = try await session.data(from: url)
        try validate(response)
        return data
    }

    private func validate(_ response: URLResponse) throws {
        if let http = response as? HTTPURLResponse,
           !(200..<300).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
    }
}

private struct ChatCompletionEvent: Decodable {
    let text: String?
    let content: String?
}

private struct AppleHealthSyncPayload: Encodable {
    let userID: String
    let samples: [AppleHealthSamplePayload]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case samples
    }
}

private struct HealthReportPayload: Encodable {
    let userID: String
    let kind: String
    let periodStart: String
    let periodEnd: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case kind
        case periodStart = "period_start"
        case periodEnd = "period_end"
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        append(Data(string.utf8))
    }
}
