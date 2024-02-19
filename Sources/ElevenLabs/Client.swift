import Foundation
import SharedKit

public final class ElevenLabsClient {
    
    public struct Configuration {
        public let host: URL
        public let token: String
        
        public init(host: URL = URL(string: "https://api.elevenlabs.io/v1")!, token: String) {
            self.host = host
            self.token = token
        }
    }
    
    public let configuration: Configuration
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    public convenience init(token: String) {
        self.init(configuration: .init(token: token))
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
}
