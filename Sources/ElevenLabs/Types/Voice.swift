import Foundation

public struct VoicesResponse: Decodable, Sendable {
    public let voices: [Voice]
}

public struct Voice: Decodable, Sendable {
    public let voice_id: String
    public let name: String?
//    public let samples: [Sample]?
//    public let category: Category?
//    public let fine_tuning: FineTuning?
    public let labels: [String: String]?
    public let description: String?
    public let preview_url: String?
    public let available_for_tiers: [String]?
//    public let settings: Settings?
//    public let sharing: Sharing?
    public let high_quality_base_model_ids: [String]?
//    public let verified_languages: [VerifiedLanguage]?
//    public let safety_control: SafetyControl?
//    public let voice_verification: VoiceVerification?
    public let permission_on_resource: String?
    public let is_owner: Bool?
    public let is_legacy: Bool?
    public let is_mixed: Bool?
    public let created_at_unix: Int?
}
