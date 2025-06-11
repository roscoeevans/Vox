import Foundation
import AVFoundation

enum VideoUploadError: LocalizedError {
    case invalidFormat
    case fileTooLarge
    case durationTooLong
    case uploadFailed(String)
    case processingFailed(String)
    case authFailed
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Video format not supported. Please use MP4, MPEG, WebM, or MOV."
        case .fileTooLarge:
            return "Video file is too large. Maximum size is 500MB."
        case .durationTooLong:
            return "Video is too long. Maximum duration is 3 minutes."
        case .uploadFailed(let message):
            return "Upload failed: \(message)"
        case .processingFailed(let message):
            return "Processing failed: \(message)"
        case .authFailed:
            return "Authentication failed. Please try again."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

class VideoUploadService {
    private let authService: BlueSkyAuthService
    private let baseURL = "https://video.bsky.app"
    private let session = URLSession.shared
    
    init(authService: BlueSkyAuthService) {
        self.authService = authService
    }
    
    // MARK: - Public Methods
    
    func uploadVideo(
        fileURL: URL,
        onProgress: @escaping (Double) -> Void
    ) async throws -> BSImage {
        // Validate video
        try await validateVideo(at: fileURL)
        
        // Get service auth token
        let serviceToken = try await getServiceAuthToken()
        
        // Upload video
        let jobId = try await uploadVideoFile(
            fileURL: fileURL,
            token: serviceToken,
            onProgress: onProgress
        )
        
        // Poll for job completion
        let blob = try await pollJobStatus(jobId: jobId, token: serviceToken)
        
        return blob
    }
    
    // MARK: - Private Methods
    
    private func validateVideo(at url: URL) async throws {
        // Check file extension
        let fileExtension = url.pathExtension.lowercased()
        guard VideoLimits.supportedFormats.contains(fileExtension) else {
            throw VideoUploadError.invalidFormat
        }
        
        // Check file size
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
        guard let fileSize = fileAttributes[.size] as? Int64,
              fileSize <= VideoLimits.maxFileSize else {
            throw VideoUploadError.fileTooLarge
        }
        
        // Check duration
        let asset = AVAsset(url: url)
        let duration = try await asset.load(.duration)
        let durationInSeconds = CMTimeGetSeconds(duration)
        
        guard durationInSeconds <= VideoLimits.maxDuration else {
            throw VideoUploadError.durationTooLong
        }
    }
    
    private func getServiceAuthToken() async throws -> String {
        guard let accessToken = await authService.currentSession?.accessJwt,
              let did = await authService.currentSession?.did else {
            throw VideoUploadError.authFailed
        }
        
        let url = URL(string: "https://bsky.social/xrpc/com.atproto.server.getServiceAuth")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let body = ServiceAuthRequest(
            aud: "did:web:video.bsky.app",
            lxm: "app.bsky.video.uploadVideo"
        )
        request.httpBody = try JSONEncoder().encode(body)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw VideoUploadError.authFailed
            }
            
            let authResponse = try JSONDecoder().decode(ServiceAuthResponse.self, from: data)
            return authResponse.token
        } catch {
            throw VideoUploadError.networkError(error)
        }
    }
    
    private func uploadVideoFile(
        fileURL: URL,
        token: String,
        onProgress: @escaping (Double) -> Void
    ) async throws -> String {
        guard let did = await authService.currentSession?.did else {
            throw VideoUploadError.authFailed
        }
        
        let fileName = fileURL.lastPathComponent
        var urlComponents = URLComponents(string: "\(baseURL)/xrpc/app.bsky.video.uploadVideo")!
        urlComponents.queryItems = [
            URLQueryItem(name: "did", value: did),
            URLQueryItem(name: "name", value: fileName)
        ]
        
        guard let url = urlComponents.url else {
            throw VideoUploadError.uploadFailed("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(mimeType(for: fileURL), forHTTPHeaderField: "Content-Type")
        
        // Get file data
        let videoData = try Data(contentsOf: fileURL)
        request.setValue("\(videoData.count)", forHTTPHeaderField: "Content-Length")
        
        // Create upload task with progress tracking
        let (data, response) = try await session.upload(for: request, from: videoData) { bytesSent, totalBytes in
            let progress = Double(bytesSent) / Double(totalBytes)
            Task { @MainActor in
                onProgress(progress)
            }
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw VideoUploadError.uploadFailed(errorMessage)
        }
        
        let uploadResponse = try JSONDecoder().decode(VideoUploadResponse.self, from: data)
        return uploadResponse.jobId
    }
    
    private func pollJobStatus(jobId: String, token: String) async throws -> BSImage {
        let url = URL(string: "\(baseURL)/xrpc/app.bsky.video.getJobStatus?jobId=\(jobId)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Poll every 2 seconds for up to 5 minutes
        let maxAttempts = 150
        let pollInterval: TimeInterval = 2.0
        
        for _ in 0..<maxAttempts {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw VideoUploadError.processingFailed("Failed to get job status")
            }
            
            let jobStatus = try JSONDecoder().decode(VideoJobStatus.self, from: data)
            
            switch jobStatus.state {
            case .jobStateCompleted:
                guard let blob = jobStatus.blob else {
                    throw VideoUploadError.processingFailed("No blob returned")
                }
                return blob
                
            case .jobStateFailed:
                let errorMessage = jobStatus.error?.message ?? jobStatus.message ?? "Unknown error"
                throw VideoUploadError.processingFailed(errorMessage)
                
            case .jobStateQueued, .jobStateProcessing:
                // Continue polling
                try await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
            }
        }
        
        throw VideoUploadError.processingFailed("Timeout waiting for video processing")
    }
    
    private func mimeType(for url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "mp4":
            return "video/mp4"
        case "mov":
            return "video/quicktime"
        case "webm":
            return "video/webm"
        case "mpeg", "mpg":
            return "video/mpeg"
        default:
            return "video/mp4"
        }
    }
}

// Extension to support upload with progress
extension URLSession {
    func upload(
        for request: URLRequest,
        from bodyData: Data,
        onProgress: @escaping (Int64, Int64) -> Void
    ) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = self.uploadTask(with: request, from: bodyData) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: URLError(.unknown))
                }
            }
            
            // Observe progress
            let observation = task.progress.observe(\.fractionCompleted) { progress, _ in
                onProgress(progress.completedUnitCount, progress.totalUnitCount)
            }
            
            task.resume()
            
            // Clean up observation when task completes
            Task {
                _ = await task.response
                observation.invalidate()
            }
        }
    }
} 