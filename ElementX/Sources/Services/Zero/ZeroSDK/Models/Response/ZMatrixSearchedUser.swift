import Foundation
import Tagged

public struct ZMatrixSearchedUser: Codable, Identifiable, Hashable {
    public let id: Tagged<Self, String>
    public let name: String
    public let matrixId: String
    public let profileImage: String?
    public let primaryZID: String?
    public let primaryWalletAddress: String?
}

extension ZMatrixSearchedUser: Equatable {
    public static func == (lhs: ZMatrixSearchedUser, rhs: ZMatrixSearchedUser) -> Bool {
        lhs.id == rhs.id
    }
}

extension ZMatrixSearchedUser {
    public var primaryZIdOrWalletAddress: String? {
        primaryZID ?? formattedPrimaryWalletAddress(address: primaryWalletAddress)
    }
    
    private func formattedPrimaryWalletAddress(address: String?) -> String? {
        if let walletAddress = address {
            let firstSix = String(walletAddress.prefix(6))
            let lastFour = String(walletAddress.suffix(4))
            return "\(firstSix)...\(lastFour)"
        }
        return nil
    }
}

public extension ZMatrixSearchedUser {
    static let frederickGuerrero = ZMatrixSearchedUser(id: ID("0"),
                                                       name: "Frederick Guerrero",
                                                       matrixId: "@9033a034-0e4d-425f-b400-0230c7a473e7:zero-synapse-development.zer0.io",
                                                       profileImage: "https://gravatar.com/avatar/97c92c9e527e2950efa4dad69b0e6458?s=400&d=robohash&r=x",
                                                       primaryZID: nil,
                                                       primaryWalletAddress: nil)
}
