import Foundation

public struct SpeechRequest: Encodable, Sendable {
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

    // Excluded from serialized JSON
    public var voice_id: String
    public var enable_logging: Bool?
    public var output_format: OutputFormat?

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

    public enum OutputFormat: String, Codable, Sendable {
        case mp3_22050_32, mp3_44100_32, mp3_44100_64, mp3_44100_96, mp3_44100_128, mp3_44100_192
        case pcm_16000, pcm_22050, pcm_24000, pcm_44100
        case ulaw_8000
    }

    enum CodingKeys: String, CodingKey {
        case text
        case model_id
        case language_code
        case voice_settings
        case pronunciation_dictionary_locators
        case seed
        case previous_text
        case next_text
        case previous_request_ids
        case next_request_ids
        case apply_text_normalization
    }

    public init(text: String, voice_id: String, model_id: String, language_code: String? = nil, voice_settings: VoiceSettings? = nil,
                pronunciation_dictionary_locators: PronunciationDictionaryLocators? = nil, seed: Int? = nil,
                previous_text: String? = nil, next_text: String? = nil, previous_request_ids: [String]? = nil,
                next_request_ids: [String]? = nil, apply_text_normalization: TextNormalization? = nil,
                enable_logging: Bool? = nil, output_format: OutputFormat? = nil) {
        self.text = text
        self.voice_id = voice_id
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
        self.enable_logging = enable_logging
        self.output_format = output_format
    }

    var params: [String: String] {
        var params: [String: String] = [:]
        if let enable_logging {
            params["enable_logging"] = enable_logging ? "true" : "false"
        }
        if let output_format {
            params["output_format"] = output_format.rawValue
        }
        return params
    }
}

public struct SpeechResponse: Decodable, Sendable {
    public let audio_base64: String
    public let alignment: Alignment
    public let normalized_alignment: Alignment

    public struct Alignment: Codable, Sendable {
        public let characters: [String]
        public let character_start_times_seconds: [Double]
        public let character_end_times_seconds: [Double]
    }
}
