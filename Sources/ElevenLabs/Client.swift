import Foundation
import SharedKit

public final class ElevenLabsClient {
    
    public struct Configuration {
        public let host: URL
        public let token: String
        
        public init(host: URL? = nil, token: String) {
            self.host = host ?? Defaults.apiHost
            self.token = token
        }
    }
    
    public let configuration: Configuration
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    public func textToSpeech(_ payload: TextToSpeechQuery, voice: String, optimizeStreamingLatency: Int? = nil, outputFormat: String? = nil) async throws -> Data {
        var req = makeRequest(path: "text-to-speech/\(voice)", method: "POST")
        req.httpBody = try JSONEncoder().encode(payload)
        if let outputFormat {
            req.queryParameters["output_format"] = outputFormat
        }
        if let optimizeStreamingLatency {
            req.queryParameters["optimize_streaming_latency"] = String(optimizeStreamingLatency)
        }
        let (data, resp) = try await URLSession.shared.data(for: req)
        if let httpResponse = resp as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        return data
    }
    
    public func textToSpeechStream(_ payload: TextToSpeechQuery, voice: String, optimizeStreamingLatency: Int? = nil, outputFormat: String? = nil, onResult: @escaping (Data) -> Void, completion: ((Error?) -> Void)?) async throws {
        var req = makeRequest(path: "text-to-speech/\(voice)/stream", method: "POST")
        req.httpBody = try JSONEncoder().encode(payload)
        if let outputFormat {
            req.queryParameters["output_format"] = outputFormat
        }
        if let optimizeStreamingLatency {
            req.queryParameters["optimize_streaming_latency"] = String(optimizeStreamingLatency)
        }
        for try await data in performSteamingDataRequest(from: req) {
            onResult(data)
        }
        completion?(nil)
    }
    
    public func models() async throws -> [ModelResponse] {
        let req = makeRequest(path: "models", method: "GET")
        let (data, resp) = try await URLSession.shared.data(for: req)
        if let httpResponse = resp as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode([ModelResponse].self, from: data)
    }
    
    // Private
    
    private func makeRequest(path: String, method: String) -> URLRequest {
        var req = URLRequest(url: configuration.host.appending(path: path))
        req.httpMethod = method
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.setValue(configuration.token, forHTTPHeaderField: "xi-api-key")
        return req
    }
    
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        return decoder
    }
    
    func performSteamingDataRequest(from request: URLRequest) -> AsyncThrowingStream<Data, Error> {
        AsyncThrowingStream { continuation in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    continuation.finish(throwing: URLError(.badServerResponse))
                    return
                }
                if let data = data {
                    continuation.yield(data)
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

}
