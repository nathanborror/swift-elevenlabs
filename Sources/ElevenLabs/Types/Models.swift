import Foundation

public struct ModelResponse: Codable, Sendable {
    public let model_id: String
    public let name: String
    public let can_be_finetuned: Bool
    public let can_do_text_to_speech: Bool
    public let can_do_voice_conversion: Bool
    public let can_use_speaker_boost: Bool
    public let can_use_style: Bool
    public let description: String
    public let languages: [Language]
    public let max_characters_request_free_user: Int
    public let max_characters_request_subscribed_user: Int
    public let requires_alpha_access: Bool
    public let serves_pro_voices: Bool
    public let token_cost_factor: Int

    public struct Language: Codable, Sendable {
        public let language_id: String
        public let name: String
    }
}
