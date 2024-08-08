import Foundation

public enum ZError: Error {
    /// If we are unable to build the request
    case invalidRequest
    /// The request could not be made (due to a timeout, missing connectivity, offline, etc). The associated value provides the underlying reason.
    case networkError(Error)
    /// The request was made but the response indicated the request was invalid.
    case requestError(ZErrorResponse?)
    /// The response format could not be decoded into the expected type
    case decodingError(DecodingError)
    /// If our response is not an HTTPURLResponse
    case invalidResponse
    /// If jwt token has expired or not valid
    case unauthorizedRequest
    ///
    case authenticationCancelled
}

extension ZError: Equatable {
    public static func == (lhs: ZError, rhs: ZError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidRequest, .invalidRequest),
             (.networkError, .networkError),
             (.requestError, .requestError),
             (.decodingError, .decodingError),
             (.invalidResponse, .invalidResponse),
             (.unauthorizedRequest, .unauthorizedRequest),
             (.authenticationCancelled, .authenticationCancelled):
            return true

        default:
            return false
        }
    }
}

public struct ZErrorResponse: Decodable {
    public let code: String
    public let message: String
}
