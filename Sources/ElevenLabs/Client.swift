import Foundation

public final class Client {

    public static let defaultHost = URL(string: "https://api.elevenlabs.io/v1")!

    public let host: URL
    public let apiKey: String
    public let userAgent: String?

    internal(set) public var session: URLSession

    public init(session: URLSession = URLSession(configuration: .default), host: URL = defaultHost, apiKey: String, userAgent: String? = nil) {
        var host = host
        if !host.path.hasSuffix("/") {
            host = host.appendingPathComponent("")
        }
        self.host = host
        self.apiKey = apiKey
        self.userAgent = userAgent
        self.session = session
    }

    public enum Error: Swift.Error, CustomStringConvertible {
        case requestError(String)
        case responseError(response: HTTPURLResponse, detail: String)
        case decodingError(response: HTTPURLResponse, detail: String)
        case unexpectedError(String)

        public var description: String {
            switch self {
            case .requestError(let detail):
                return "Request error: \(detail)"
            case .responseError(let response, let detail):
                return "Response error (Status \(response.statusCode)): \(detail)"
            case .decodingError(let response, let detail):
                return "Decoding error (Status \(response.statusCode)): \(detail)"
            case .unexpectedError(let detail):
                return "Unexpected error: \(detail)"
            }
        }
    }

    private enum Method: String {
        case post = "POST"
        case get = "GET"
    }

    private struct ErrorResponse: Decodable {
        let detail: Detail

        struct Detail: Codable, Sendable {
            let loc: [String]?
            let msg: String?
            let type: String?
            let status: String?
            let message: String?
        }
    }
}

// MARK: - Models

extension Client {

    public func models() async throws -> [ModelResponse] {
        try await fetch(.get, "models")
    }
}

// MARK: - Voices

extension Client {

    public func voices() async throws -> VoicesResponse {
        try await fetch(.get, "voices")
    }
}

// MARK: - Speech

extension Client {

    public func textToSpeech(_ request: SpeechRequest) async throws -> Data {
        try await fetch(.post, "text-to-speech/\(request.voice_id)", body: request, params: request.params)
    }

    public func textToSpeechWithTimestamps(_ request: SpeechRequest) async throws -> SpeechResponse {
        try await fetch(.post, "text-to-speech/\(request.voice_id)/with-timestamps", body: request, params: request.params)
    }

    public func textToSpeechStream(_ request: SpeechRequest) async throws -> AsyncThrowingStream<Data, Swift.Error> {
        try fetchAsync(.post, "text-to-speech/\(request.voice_id)/stream", body: request, params: request.params)
    }

    public func textToSpeechStreamWithTimestamps(_ request: SpeechRequest) async throws -> AsyncThrowingStream<SpeechResponse, Swift.Error> {
        try fetchAsync(.post, "text-to-speech/\(request.voice_id)/stream/with-timestamps", body: request, params: request.params)
    }
}

// MARK: - Transcription

extension Client {

    public func speechToText(_ request: TranscriptionRequest) async throws -> TranscriptionResponse {
        try await fetch(.post, "speech-to-text", body: request, multipart: true)
    }
}

// MARK: - Sound Generation

extension Client {

    public func soundGeneration(_ request: SoundRequest) async throws -> Data {
        try await fetch(.post, "sound-generation", body: request)
    }
}

// MARK: - Private

extension Client {

    private func fetch<Response: Decodable>(_ method: Method, _ path: String, body: Encodable? = nil, params: [String: String]? = nil, multipart: Bool = false) async throws -> Response {
        try checkAuthentication()
        let request = try makeRequest(path: path, method: method, body: body, params: params, multipart: multipart)
        let (data, resp) = try await session.data(for: request)
        try checkResponse(resp, data)
        if Response.self == Data.self {
            return data as! Response
        } else {
            return try decoder.decode(Response.self, from: data)
        }
    }

    private func fetchAsync<Response: Decodable>(_ method: Method, _ path: String, body: Encodable, params: [String: String]? = nil, multipart: Bool = false) throws -> AsyncThrowingStream<Response, Swift.Error> {
        try checkAuthentication()
        let request = try makeRequest(path: path, method: method, body: body, params: params, multipart: multipart)
        return AsyncThrowingStream { continuation in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    continuation.finish(throwing: URLError(.badServerResponse))
                    return
                }
                if let data = data {
                    if Response.self == Data.self {
                        continuation.yield(data as! Response)
                    } else {
                        do {
                            let decoded = try JSONDecoder().decode(Response.self, from: data)
                            continuation.yield(decoded)
                        } catch {
                            continuation.finish(throwing: error)
                            return
                        }
                    }
                }
                continuation.finish()
            }
            task.resume()
            continuation.onTermination = { @Sendable termination in
                switch termination {
                case .cancelled:
                    task.cancel()
                default:
                    break
                }
            }
        }
    }

    private func checkAuthentication() throws {
        if apiKey.isEmpty {
            throw Error.requestError("Missing API key")
        }
    }

    private func checkResponse(_ resp: URLResponse?, _ data: Data) throws {
        if let response = resp as? HTTPURLResponse, response.statusCode != 200 {
            if let err = try? decoder.decode(ErrorResponse.self, from: data) {
                throw Error.responseError(response: response, detail: err.detail.msg ?? err.detail.message ?? "Unknown")
            } else {
                throw Error.responseError(response: response, detail: "Unknown response error")
            }
        }
    }

    private func makeRequest(path: String, method: Method, body: Encodable? = nil, params: [String: String]? = nil, multipart: Bool) throws -> URLRequest {
        var req = URLRequest(url: host.appending(path: path))
        req.httpMethod = method.rawValue
        req.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        if let params {
            for (key, value) in params {
                req.queryParameters[key] = value
            }
        }
        if let body {
            if multipart {
                let boundary = UUID().uuidString
                req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                req.httpBody = try encodeMultipartFormData(body, boundary: boundary)
            } else {
                req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                req.httpBody = try JSONEncoder().encode(body)
            }
        }
        return req
    }

    private func encodeMultipartFormData<T: Encodable>(_ body: T, boundary: String) throws -> Data {
        var data = Data()
        let mirror = Mirror(reflecting: body)
        for child in mirror.children {
            guard let name = child.label else { continue }

            if let fileURL = child.value as? URL {
                let filename = fileURL.lastPathComponent
                let fileData = try Data(contentsOf: fileURL)

                data.append("--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
                data.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
                data.append(fileData)
                data.append("\r\n".data(using: .utf8)!)
            } else {
                let value = String(describing: child.value)
                if value != "nil" {
                    data.append("--\(boundary)\r\n".data(using: .utf8)!)
                    data.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
                    data.append("\(value)\r\n".data(using: .utf8)!)
                }
            }
        }
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return data
    }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        return decoder
    }
}
