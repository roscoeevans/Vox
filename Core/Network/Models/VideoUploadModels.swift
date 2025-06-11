import Foundation

// MARK: - Service Auth Models

struct ServiceAuthRequest: Codable {
    let aud: String
    let lxm: String
    let exp: Int?
    
    init(aud: String, lxm: String = "app.bsky.video.uploadVideo", exp: Int? = nil) {
        self.aud = aud
        self.lxm = lxm
        self.exp = exp
    }
}

struct ServiceAuthResponse: Codable {
    let token: String
}

// MARK: - Video Upload Models

struct VideoUploadResponse: Codable {
    let jobId: String
}

struct VideoJobStatus: Codable {
    let jobId: String
    let did: String
    let state: VideoJobState
    let progress: Int?
    let blob: BSImage?
    let error: VideoJobError?
    let message: String?
}

enum VideoJobState: String, Codable {
    case jobStateQueued = "JOB_STATE_QUEUED"
    case jobStateProcessing = "JOB_STATE_PROCESSING"
    case jobStateCompleted = "JOB_STATE_COMPLETED"
    case jobStateFailed = "JOB_STATE_FAILED"
}

struct VideoJobError: Codable {
    let code: String
    let message: String
}

// MARK: - Video Limits

struct VideoLimits {
    static let maxDuration: TimeInterval = 180 // 3 minutes as of March 2025
    static let maxFileSize: Int64 = 500_000_000 // 500MB
    static let supportedFormats = ["mp4", "mpeg", "webm", "mov"]
    static let dailyUploadLimit = 25
    static let dailyUploadSizeLimit: Int64 = 10_737_418_240 // 10GB
} 