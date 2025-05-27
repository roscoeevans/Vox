import SwiftUI

private struct PostAuthorDIDKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var postAuthorDID: String? {
        get { self[PostAuthorDIDKey.self] }
        set { self[PostAuthorDIDKey.self] = newValue }
    }
} 