import Foundation

public struct TranscriptionRequest: Encodable, Sendable {
    public var model_id: String
    public var language_code: String?
    public var tag_audio_events: Bool?
    public var num_speakers: Int?
    public var timestamps_granularity: TimestampsGranularity?
    public var diarize: Bool?

    public enum TimestampsGranularity: String, Encodable, Sendable {
        case none
        case word
        case character
    }
}

public struct TranscriptionResponse: Decodable, Sendable {
    public let language_code: String
    public let language_probability: Double
    public let text: String
    public let words: [Word]

    public struct Word: Decodable, Sendable {
        public let text: String
        public let type: WordType
        public let start: Double?
        public let end: Double?
        public let speaker_id: String?
        public let characters: [WordCharacter]?

        public enum WordType: String, Decodable, Sendable {
            case word
            case spacing
            case audio_event
        }

        public struct WordCharacter: Decodable, Sendable {
            public let text: String
            public let start: Double?
            public let end: Double?
        }
    }
}
