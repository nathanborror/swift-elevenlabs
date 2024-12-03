import Foundation

public struct TextToSpeechRequest: Codable, Sendable {
    public var text: String
    public var model_id: String
    public var language_code: String?
    public var voice_settings: VoiceSettings?
    public var pronunciation_dictionary_locators: PronunciationDictionaryLocators?
    public var seed: Int?
    public var previous_text: String?
    public var next_text: String?
    public var previous_request_ids: [String]?
    public var next_request_ids: [String]?
    public var apply_text_normalization: TextNormalization?

    public struct VoiceSettings: Codable, Sendable {
        public var stability: Int
        public var similarity_boost: Int
        public var style: Int?
        public var use_speaker_boost: Bool?

        public init(stability: Int, similarity_boost: Int, style: Int? = nil, use_speaker_boost: Bool? = nil) {
            self.stability = stability
            self.similarity_boost = similarity_boost
            self.style = style
            self.use_speaker_boost = use_speaker_boost
        }
    }

    public struct PronunciationDictionaryLocators: Codable, Sendable {
        public var pronunciation_dictionary_id: String
        public var version_id: String

        public init(pronunciation_dictionary_id: String, version_id: String) {
            self.pronunciation_dictionary_id = pronunciation_dictionary_id
            self.version_id = version_id
        }
    }

    public enum TextNormalization: Codable, Sendable {
        case auto, on, off
    }

    public init(text: String, model_id: String, language_code: String? = nil, voice_settings: VoiceSettings? = nil,
                pronunciation_dictionary_locators: PronunciationDictionaryLocators? = nil, seed: Int? = nil,
                previous_text: String? = nil, next_text: String? = nil, previous_request_ids: [String]? = nil,
                next_request_ids: [String]? = nil, apply_text_normalization: TextNormalization? = nil) {
        self.text = text
        self.model_id = model_id
        self.language_code = language_code
        self.voice_settings = voice_settings
        self.pronunciation_dictionary_locators = pronunciation_dictionary_locators
        self.seed = seed
        self.previous_text = previous_text
        self.next_text = next_text
        self.previous_request_ids = previous_request_ids
        self.next_request_ids = next_request_ids
        self.apply_text_normalization = apply_text_normalization
    }
}

public struct TextToSpeechResponse: Codable, Sendable {
    public let audio_base64: String
    public let alignment: Alignment
    public let normalized_alignment: Alignment

    public struct Alignment: Codable, Sendable {
        public let characters: [String]
        public let character_start_times_seconds: [Int]
        public let character_end_times_seconds: [Int]
    }
}
