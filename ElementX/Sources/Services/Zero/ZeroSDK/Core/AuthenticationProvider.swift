import Foundation
import SimpleKeychain

struct AuthenticationProvider: AuthProvider {
    let secureStorage: ZeroSecureStorage
    
    func authenticate(_ completionHandler: @escaping (AuthResult) -> Void) {
        if let accessToken = try? secureStorage.string(forKey: Settings.accessTokenKey) {
            completionHandler(.authenticated(accessToken))
        }
    }

    func authorize(_ request: inout URLRequest, with token: String) {
        if let accessToken = ZeroSDK.accessToken {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

    func fetchToken() -> CurrentAuthState {
        if let accessToken = ZeroSDK.accessToken {
            return .authenticated(accessToken)
        }

        guard let bearerToken = try? secureStorage.string(forKey: Settings.accessTokenKey) else { return .unauthenticated }
        return .authenticated(bearerToken)
    }
}

public protocol SecureStorage {
    func string(forKey key: String) throws -> String
    func set(_ string: String, forKey key: String) throws
    func deleteItem(forKey key: String) throws
    func deleteAll() throws
    func keys() throws -> [String]
}

public class ZeroSecureStorage: SecureStorage {
    private let keychain = SimpleKeychain(service: "zer0",
                                          accessGroup: BuildSettings.applicationGroupIdentifier)

    public init() { }

    public func string(forKey key: String) throws -> String {
        try keychain.string(forKey: key)
    }

    public func set(_ string: String, forKey key: String) throws {
        try keychain.set(string, forKey: key)
    }

    public func deleteItem(forKey key: String) throws {
        try keychain.deleteItem(forKey: key)
    }

    public func deleteAll() throws {
        try keychain.deleteAll()
    }
    
    public func keys() throws -> [String] {
        try keychain.keys()
    }
}
