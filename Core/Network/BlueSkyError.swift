import Foundation

enum BlueSkyError: LocalizedError {
    case authenticationFailed
    case noActiveSession
    case sessionExpired
    case refreshFailed
    case networkError
    case invalidResponse
    case rateLimited(TimeInterval)
    case keychainError(KeychainError)
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Authentication failed. Please check your credentials."
        case .noActiveSession:
            return "No active session. Please log in."
        case .sessionExpired:
            return "Your session has expired. Please log in again."
        case .refreshFailed:
            return "Failed to refresh your session. Please log in again."
        case .networkError:
            return "A network error occurred. Please check your connection."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .rateLimited(let retryAfter):
            return "Rate limit exceeded. Please try again in \(Int(retryAfter)) seconds."
        case .keychainError(let error):
            return "Failed to access secure storage: \(error.localizedDescription)"
        }
    }
} 