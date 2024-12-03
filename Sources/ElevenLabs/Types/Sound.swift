import Foundation

public struct SoundRequest: Codable, Sendable {
    public var text: String
    public var duration_seconds: Int?
    public var prompt_influence: Int?

    public init(text: String, duration_seconds: Int? = nil, prompt_influence: Int? = nil) {
        self.text = text
        self.duration_seconds = duration_seconds
        self.prompt_influence = prompt_influence
    }
}
