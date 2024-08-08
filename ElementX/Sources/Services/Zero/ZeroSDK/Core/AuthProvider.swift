import Foundation

public enum AuthResult {
    case authenticated(String)
    case failed(ZError)
    case cancelled
}

public enum CurrentAuthState {
    case unauthenticated
    case authenticating
    case authenticated(String)
}

public protocol AuthProvider {
    func authenticate(_ completionHandler: @escaping (AuthResult) -> Void)
    func authorize(_ request: inout URLRequest, with token: String)
    func fetchToken() -> CurrentAuthState
}
