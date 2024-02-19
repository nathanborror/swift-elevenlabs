import Foundation

public struct ModelResponse: Codable {
    public let modelID: String
    public let name: String
    
    public let canBeFinetuned: Bool
    public let canDoTextToSpeech: Bool
    public let canDoVoiceConversion: Bool
    public let canUseSpeakerBoost: Bool
    public let canUseStyle: Bool
    public let description: String
    public let languages: [Language]
    public let maxCharactersRequestFreeUser: Int
    public let maxCharactersRequestSubscribedUser: Int
    public let requiresAlphaAccess: Bool
    public let servesProVoices: Bool
    public let tokenCostFactor: Int
    
    public struct Language: Codable {
        public let languageID: String
        public let name: String
        
        public enum CodingKeys: String, CodingKey {
            case languageID = "language_id"
            case name
        }
    }
    
    public enum CodingKeys: String, CodingKey {
        case modelID
        case name
        case canBeFinetuned = "can_be_finetuned"
        case canDoTextToSpeech = "can_do_text_to_speech"
        case canDoVoiceConversion = "can_do_voice_conversion"
        case canUseSpeakerBoost = "can_use_speaker_boost"
        case canUseStyle = "can_use_style"
        case description
        case languages
        case maxCharactersRequestFreeUser = "max_characters_request_free_user"
        case maxCharactersRequestSubscribedUser = "max_characters_request_subscribed_user"
        case requiresAlphaAccess = "requires_alpha_access"
        case servesProVoices = "serves_pro_voices"
        case tokenCostFactor = "token_cost_factor"
    }
}
