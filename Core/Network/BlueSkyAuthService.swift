import Foundation

actor BlueSkyAuthService {
    // MARK: - Properties
    private let baseURL = "https://bsky.social/xrpc/"
    private var session: BlueSkySession?
    private let keychainManager = KeychainManager.shared
    
    // MARK: - Types
    struct BlueSkySession: Codable {
        let accessJwt: String
        let refreshJwt: String
        let handle: String
        let did: String
        let email: String?
        let active: Bool?
        let status: String?
        
        var isExpired: Bool {
            // JWT tokens are typically valid for 1 hour
            // We'll refresh 5 minutes before expiration to be safe
            guard let expirationDate = getExpirationDate(from: accessJwt) else {
                return true
            }
            return Date().addingTimeInterval(300) >= expirationDate
        }
        
        private func getExpirationDate(from jwt: String) -> Date? {
            let parts = jwt.components(separatedBy: ".")
            guard parts.count == 3,
                  let payloadData = Data(base64Encoded: parts[1].padding(toLength: ((parts[1].count + 3) / 4) * 4, withPad: "=", startingAt: 0)),
                  let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
                  let exp = payload["exp"] as? TimeInterval else {
                return nil
            }
            return Date(timeIntervalSince1970: exp)
        }
    }
    
    struct SessionInfo: Codable {
        let handle: String
        let did: String
        let didDoc: DIDDoc
        let email: String?
        let emailConfirmed: Bool
        let emailAuthFactor: Bool
        let active: Bool
    }
    
    struct DIDDoc: Codable {
        let context: [String]
        let id: String
        let alsoKnownAs: [String]
        let verificationMethod: [VerificationMethod]
        let service: [Service]
        
        enum CodingKeys: String, CodingKey {
            case context = "@context"
            case id
            case alsoKnownAs
            case verificationMethod
            case service
        }
    }
    
    struct VerificationMethod: Codable {
        let id: String
        let type: String
        let controller: String
        let publicKeyMultibase: String
    }
    
    struct Service: Codable {
        let id: String
        let type: String
        let serviceEndpoint: String
    }
    
    // MARK: - Authentication
    func login(identifier: String, password: String) async throws -> BlueSkySession {
        print("[Auth] Attempting login for identifier: \(identifier)")
        let endpoint = "com.atproto.server.createSession"
        let url = URL(string: baseURL + endpoint)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "identifier": identifier,
            "password": password
        ]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("[Auth] Login failed: Invalid response or status code")
            throw BlueSkyError.authenticationFailed
        }
        
        let session = try JSONDecoder().decode(BlueSkySession.self, from: data)
        self.session = session
        
        // Save tokens to Keychain
        try await keychainManager.saveToken(session.accessJwt, forKey: "accessToken")
        try await keychainManager.saveToken(session.refreshJwt, forKey: "refreshToken")
        
        print("[Auth] Login successful. Handle: \(session.handle), DID: \(session.did)")
        return session
    }
    
    func refreshSession() async throws -> BlueSkySession {
        print("[Auth] Attempting to refresh session")
        guard let currentSession = session else {
            print("[Auth] No active session to refresh")
            throw BlueSkyError.noActiveSession
        }
        
        let endpoint = "com.atproto.server.refreshSession"
        let url = URL(string: baseURL + endpoint)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(currentSession.refreshJwt)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("[Auth] Session refresh failed: Invalid response or status code")
            throw BlueSkyError.refreshFailed
        }
        
        let newSession = try JSONDecoder().decode(BlueSkySession.self, from: data)
        self.session = newSession
        
        // Update tokens in Keychain
        try await keychainManager.saveToken(newSession.accessJwt, forKey: "accessToken")
        try await keychainManager.saveToken(newSession.refreshJwt, forKey: "refreshToken")
        
        print("[Auth] Session refreshed. Handle: \(newSession.handle), DID: \(newSession.did)")
        return newSession
    }
    
    func logout() async {
        session = nil
        try? await keychainManager.deleteToken(forKey: "accessToken")
        try? await keychainManager.deleteToken(forKey: "refreshToken")
    }
    
    var isAuthenticated: Bool {
        session != nil
    }
    
    var currentSession: BlueSkySession? {
        session
    }
    
    // MARK: - Token Management
    func getValidAccessToken() async throws -> String {
        if let session = session {
            if session.isExpired {
                let newSession = try await refreshSession()
                return newSession.accessJwt
            }
            return session.accessJwt
        }
        
        // Try to restore session from Keychain
        do {
            let accessToken = try await keychainManager.getToken(forKey: "accessToken")
            let refreshToken = try await keychainManager.getToken(forKey: "refreshToken")
            
            // Create a temporary session to check expiration
            let tempSession = BlueSkySession(
                accessJwt: accessToken,
                refreshJwt: refreshToken,
                handle: "", // These fields aren't needed for token validation
                did: "",
                email: nil,
                active: nil,
                status: nil
            )
            
            if tempSession.isExpired {
                // If expired, we need to refresh but we don't have enough info
                throw BlueSkyError.sessionExpired
            }
            
            return accessToken
        } catch {
            throw BlueSkyError.noActiveSession
        }
    }
    
    // MARK: - Session Restoration
    func restoreSession() async throws {
        print("[Auth] Attempting to restore session")
        do {
            let accessToken = try await keychainManager.getToken(forKey: "accessToken")
            let refreshToken = try await keychainManager.getToken(forKey: "refreshToken")
            
            print("[Auth] Retrieved tokens from Keychain")
            
            // Create a temporary session to check expiration
            let tempSession = BlueSkySession(
                accessJwt: accessToken,
                refreshJwt: refreshToken,
                handle: "", // These fields aren't needed for token validation
                did: "",
                email: nil,
                active: nil,
                status: nil
            )
            
            if tempSession.isExpired {
                print("[Auth] Access token expired, attempting to refresh")
                // If expired, try to refresh the session
                let endpoint = "com.atproto.server.refreshSession"
                let url = URL(string: baseURL + endpoint)!
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                // Log the raw response data
                if let responseString = String(data: data, encoding: .utf8) {
                    print("[Auth] Raw refresh response: \(responseString)")
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("[Auth] Invalid response type during refresh")
                    throw BlueSkyError.invalidResponse
                }
                
                print("[Auth] Refresh response status code: \(httpResponse.statusCode)")
                
                guard httpResponse.statusCode == 200 else {
                    print("[Auth] Refresh failed with status code: \(httpResponse.statusCode)")
                    throw BlueSkyError.sessionExpired
                }
                
                do {
                    let newSession = try JSONDecoder().decode(BlueSkySession.self, from: data)
                    self.session = newSession
                    
                    // Update tokens in Keychain
                    try await keychainManager.saveToken(newSession.accessJwt, forKey: "accessToken")
                    try await keychainManager.saveToken(newSession.refreshJwt, forKey: "refreshToken")
                    
                    print("[Auth] Successfully refreshed session")
                    return
                } catch {
                    print("[Auth] Failed to decode refresh response: \(error)")
                    throw BlueSkyError.invalidResponse
                }
            }
            
            print("[Auth] Access token valid, fetching full session info")
            // If not expired, fetch the full session info
            let endpoint = "com.atproto.server.getSession"
            let url = URL(string: baseURL + endpoint)!
            
            var request = URLRequest(url: url)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Log the raw response data
            if let responseString = String(data: data, encoding: .utf8) {
                print("[Auth] Raw session response: \(responseString)")
            } else {
                print("[Auth] Raw session response: <non-utf8 data>")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[Auth] Invalid response type during session fetch")
                throw BlueSkyError.invalidResponse
            }
            
            print("[Auth] Session fetch response status code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("[Auth] Session fetch failed with status code: \(httpResponse.statusCode)")
                throw BlueSkyError.sessionExpired
            }
            
            do {
                let sessionInfo = try JSONDecoder().decode(SessionInfo.self, from: data)
                // Create a session object with the tokens we already have
                let session = BlueSkySession(
                    accessJwt: accessToken,
                    refreshJwt: refreshToken,
                    handle: sessionInfo.handle,
                    did: sessionInfo.did,
                    email: sessionInfo.email,
                    active: sessionInfo.active,
                    status: nil
                )
                self.session = session
                print("[Auth] Successfully restored session")
            } catch {
                print("[Auth] Failed to decode session data: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("[Auth] Missing key: \(key.stringValue), context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("[Auth] Type mismatch: expected \(type), context: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("[Auth] Value not found: expected \(type), context: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("[Auth] Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        print("[Auth] Unknown decoding error: \(decodingError)")
                    }
                }
                throw BlueSkyError.invalidResponse
            }
            
        } catch KeychainError.itemNotFound {
            print("[Auth] No tokens found in Keychain")
            throw BlueSkyError.noActiveSession
        } catch {
            print("[Auth] Failed to restore session: \(error.localizedDescription)")
            throw BlueSkyError.noActiveSession
        }
    }
} 