import Foundation
import Tagged

// MARK: - ZCurrentUser

public struct ZCurrentUser: Codable {
    public let id: String
    public let profileID: String?
    public let handle: String?
    public let lastActiveAt: String?
    public let isOnline: Bool?
    public let createdAt: String?
    public let updatedAt: String?
    public let profileSummary: ZProfileSummary?
    public let role: String?
    public let isANetworkAdmin: Bool?
    public let isAMemberOfWorlds: Bool?
    public let matrixId: String?
    public let primaryZID: String?
    public let primaryWalletAddress: String?

    enum CodingKeys: String, CodingKey {
        case id
        case profileID = "profileId"
        case handle
        case lastActiveAt
        case isOnline
        case createdAt
        case updatedAt
        case profileSummary
        case role
        case isANetworkAdmin
        case isAMemberOfWorlds
        case matrixId
        case primaryZID
        case primaryWalletAddress
    }
}

public extension ZCurrentUser {
    var profileAvatarUrl: URL? {
        if let imageUrlString = profileSummary?.profileImage {
            return URL(string: imageUrlString)
        }

        return nil
    }

    var primaryZIdOrWalletAddress: String? {
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

// MARK: - Mock Users

// swiftlint:disable line_length
public extension ZCurrentUser {
    static let frederickGuerrero = ZCurrentUser(id: UUID().uuidString,
                                                profileID: UUID().uuidString,
                                                handle: "frederick",
                                                lastActiveAt: "2023-11-15 00:38:04 +0000",
                                                isOnline: true,
                                                createdAt: "2023-11-14 18:16:40 +0000",
                                                updatedAt: "2023-11-14 18:16:40 +0000",
                                                profileSummary: .init(id: UUID().uuidString,
                                                                      firstName: "Frederick",
                                                                      lastName: "Guerrero",
                                                                      gender: "Male",
                                                                      summary: "Owner of vegan Burgerlords restaurants and founder of the independent art gallery Slow Culture, both of which are based in Los Angeles.",
                                                                      backgroundImage: "https://png.pngtree.com/thumb_back/fh260/back_pic/00/02/44/5056179b42b174f.jpg",
                                                                      profileImage: "https://gravatar.com/avatar/97c92c9e527e2950efa4dad69b0e6458?s=400&d=robohash&r=x",
                                                                      ssbPublicKey: "ssh-key"),
                                                role: "admin",
                                                isANetworkAdmin: false,
                                                isAMemberOfWorlds: false,
                                                matrixId: "@9033a034-0e4d-425f-b400-0230c7a473e7:zero-synapse-development.zer0.io",
                                                primaryZID: nil,
                                                primaryWalletAddress: nil)

    static let nataliaBonifacci = ZCurrentUser(id: UUID().uuidString,
                                               profileID: UUID().uuidString,
                                               handle: "nataliabonifacci",
                                               lastActiveAt: "2023-11-15 00:38:04 +0000",
                                               isOnline: true,
                                               createdAt: "2023-11-14 18:16:40 +0000",
                                               updatedAt: "2023-11-14 18:16:40 +0000",
                                               profileSummary: .init(id: UUID().uuidString,
                                                                     firstName: "Natalia",
                                                                     lastName: "Bonifacci",
                                                                     gender: "Female",
                                                                     summary: "Italian and Costa Rican creative whose casual yet sophisticated style led her campaigns for Sportmax and FORWARD.",
                                                                     backgroundImage: "https://png.pngtree.com/thumb_back/fh260/back_pic/00/02/44/5056179b42b174f.jpg",
                                                                     profileImage: "https://gravatar.com/avatar/8b01c662419106d1bb45b6fc4ad669b3?s=400&d=robohash&r=x",
                                                                     ssbPublicKey: "ssh-key"),
                                               role: "admin",
                                               isANetworkAdmin: false,
                                               isAMemberOfWorlds: false,
                                               matrixId: "@c06f61e1-1116-4113-aa0f-0deb54a0e14e:zero-synapse-development.zer0.io",
                                               primaryZID: nil,
                                               primaryWalletAddress: nil)
}

public struct ZProfileSummary: Codable {
    public let id: String?
    public let firstName: String?
    public let lastName: String?
    public let gender: String?
    public let summary: String?
    public let backgroundImage: String?
    public let profileImage: String?
    public let ssbPublicKey: String?

    public func fullName() -> String {
        let formatter = PersonNameComponentsFormatter()

        var components = PersonNameComponents()
        components.givenName = firstName
        components.familyName = lastName

        return formatter.string(from: components)
    }
}

// swiftlint:enable line_length
