import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    let zeroSDK: ZeroSDK

    private init() {
        guard let url = URL(string: API.zeroURLString) else {
            preconditionFailure("Enable to resolve Zer0 API URL")
        }
        let authProvider = AuthenticationProvider(secureStorage: ZeroSecureStorage())
        
        zeroSDK = ZeroSDK(sessionConfiguration: .default,
                          host: url,
                          authProvider: authProvider)
    }
}
