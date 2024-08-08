import Foundation

public extension ZeroSDK {
    func signin(_ body: ZSignInRequest,
                completionHandler: @escaping (Result<ZSessionDataResponse, ZError>) -> Void) {
        let req = ZeroRequest<ZSessionDataResponse>(json: .post,
                                                    host: host,
                                                    path: "/api/v2/accounts/login",
                                                    body: body,
                                                    decoder: zeroDecoder())
        
        perform(request: req, completion: completionHandler)
    }
    
    func nonceOrAuthorize(customHeader: ZCustomHeader,
                          completionHandler: @escaping (Result<ZSessionDataResponse, ZError>) -> Void) {
        var req = ZeroRequest<ZSessionDataResponse>(json: .post,
                                                    host: host,
                                                    path: "/authentication/nonceOrAuthorize",
                                                    decoder: zeroDecoder())
        
        if let headerValue = customHeader.value {
            print("\(customHeader.type.rawValue) \(headerValue)")
            
            req.urlRequest.addValue("\(customHeader.type.rawValue) \(headerValue)", forHTTPHeaderField: "Authorization")
            req.urlRequest.addValue("zos", forHTTPHeaderField: "X-App-Platform")
            //:
        }
        print(req.urlRequest.url)
        perform(request: req, completion: completionHandler)
    }
    
    func fetchSSOToken(completionHandler: @escaping (Result<ZSSOToken, ZError>) -> Void) {
        let req = ZeroRequest<ZSSOToken>(host: host,
                                         path: "/accounts/ssoToken",
                                         decoder: zeroDecoder())
        
        perform(authorizedRequest: req, completion: completionHandler)
    }
    
    func fetchMatrixSessionData(_ body: ZMatrixSessionRequest,
                                matrixURL: URL,
                                completionHandler: @escaping (Result<ZMatrixSession, ZError>) -> Void) {
        let req = ZeroRequest<ZMatrixSession>(json: .post,
                                              host: matrixURL,
                                              path: "/_matrix/client/v3/login",
                                              body: body,
                                              headers: [
                                                  "Host": "zos-home-2-e24b9412096f.herokuapp.com",
                                                  "Origin": "https://zos.zero.tech"
                                              ],
                                              decoder: zeroDecoder())
        
        print(req.urlRequest.url ?? "Empty")
        perform(request: req, completion: completionHandler)
    }
    
    func callNonce(completionHandler: @escaping (Result<ZNonceResponse, ZError>) -> Void
    ) {
        let req = ZeroRequest<ZNonceResponse>(json: .post,
                                              host: host,
                                              path: "/authentication/nonce",
                                              decoder: zeroDecoder())
        
        perform(request: req, completion: completionHandler)
    }
    
    func migrateUserToMatrix(userID: String) async throws {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else { return }
            
            let req = ZeroRequest<[ZSSOToken]>(json: .post,
                                               host: host,
                                               path: "/matrix/link-zero-user",
                                               body: ZMatrixAuthCredentials(userId: userID),
                                               decoder: zeroDecoder())
            
            perform(authorizedRequest: req) { result in
                switch result {
                case .success:
                    continuation.resume()
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

public struct ZNonceResponse: Decodable {
    public let nonceToken: String?
    public let expiresIn: Int?
}
