import Foundation

// MARK: - Voice Models
struct Voice: Codable, Identifiable {
    let id: String
    let name: String
    let category: String?
    let description: String?
    let labels: [String: String]?
    let samples: [Sample]?
    let settings: VoiceSettings?
    let sharing: Sharing?
    let high_quality_base_model_ids: [String]?
    let safety_control: String?
    let voice_verification: VoiceVerification?
    
    enum CodingKeys: String, CodingKey {
        case id = "voice_id"
        case name, category, description, labels, samples, settings, sharing
        case high_quality_base_model_ids, safety_control, voice_verification
    }
}

struct Sample: Codable {
    let sample_id: String
    let file_name: String
    let mime_type: String
    let size_bytes: Int
    let hash: String
}

struct VoiceSettings: Codable {
    let stability: Double?
    let similarity_boost: Double?
    let style: Double?
    let use_speaker_boost: Bool?
}

struct Sharing: Codable {
    let status: String?
    let history_item_sample_id: String?
    let original_voice_id: String?
    let public_owner_id: String?
    let liked_by_count: Int?
    let name: String?
    let description: String?
    let labels: [String: String]?
    let linked_user: LinkedUser?
    let name_locked: Bool?
    let description_locked: Bool?
    let labels_locked: Bool?
    let information_locked: Bool?
    let instagram_username: String?
    let twitter_username: String?
    let youtube_username: String?
    let tiktok_username: String?
}

struct LinkedUser: Codable {
    let user_id: String
    let name: String
    let email: String
    let profile_photo_url: String?
}

struct VoiceVerification: Codable {
    let requires_verification: Bool
    let is_verified: Bool
    let verification_failures: [String]
    let verification_attempts_count: Int
    let language: String
    let verification_attempts: [VerificationAttempt]
}

struct VerificationAttempt: Codable {
    let text: String
    let date_unix: Int
    let accepted: Bool
    let similarity: Double
    let levenshtein_distance: Int
    let recording: Recording
}

struct Recording: Codable {
    let recording_id: String
    let mime_type: String
    let size_bytes: Int
    let upload_date_unix: Int
    let transcription: String
}

// MARK: - Text-to-Speech Models
struct TTSRequest: Codable {
    let text: String
    let model_id: String
    let voice_settings: VoiceSettings?
}

struct TTSResponse: Codable {
    let audio: Data
}

// MARK: - API Response Models
struct VoicesResponse: Codable {
    let voices: [Voice]
}

// MARK: - App Configuration
struct AppConfiguration: Codable {
    var apiKey: String = ""
    var selectedVoiceId: String = ""
    var selectedVoiceName: String = ""
    var modelId: String = "eleven_monolingual_v1"
    var stability: Double = 0.5
    var similarityBoost: Double = 0.75
    var style: Double = 0.0
    var useSpeakerBoost: Bool = true
} 