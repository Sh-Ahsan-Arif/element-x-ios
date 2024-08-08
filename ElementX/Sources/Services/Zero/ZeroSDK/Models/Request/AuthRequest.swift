import Foundation

// MARK: - ZSignInRequest

public struct ZSignInRequest: Encodable {
    let email: String
    let password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

// MARK: - ZSignInRequest

public struct ZCustomHeader: Encodable {
    public enum ZHttpHeaderType: String, Encodable {
        case bearer = "Bearer"
        case nonce = "Nonce"
        case web3 = "Web3"
    }

    let type: ZHttpHeaderType
    let value: String?

    public init(type: ZHttpHeaderType, value: String?) {
        self.type = type
        self.value = value
    }
}

public struct ZMatrixSessionRequest: Encodable {
    let token: String
    let type = "org.matrix.login.jwt" // Set default login type to SSO
    
    public init(token: String) {
        self.token = token
    }
}

public struct ZMatrixAuthCredentials: Encodable {
    let userId: String
    let matrixAccessToken = "not-used"
    
    public init(userId: String) {
        self.userId = userId
    }
}
