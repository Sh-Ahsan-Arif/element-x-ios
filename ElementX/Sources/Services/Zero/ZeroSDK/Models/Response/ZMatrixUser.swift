import Foundation
import Tagged

public struct ZMatrixUser: Codable, Identifiable {
    public let id: Tagged<Self, String>
    public let profileId: String
    public let handle: String
    public let lastActiveAt: Date?
    public let isOnline: Bool?
    public let isPending: Bool
    public let matrixId: String
    public let matrixAccessToken: String?
    // public let createdAt: Date
    // public let updatedAt: Date
    public let profileSummary: ZProfileSummary?
    public let primaryZID: String?
    public let primaryWalletAddress: String?

    public var profileImageURL: URL? {
        URL(string: profileSummary?.profileImage ?? "")
    }

    public var displayName: String {
        if let profile = profileSummary {
            if let firstName = profile.firstName {
                return firstName
            }
        }

        return handle
    }

    public var joinedString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, yyyy"
        return formatter.string(from: Date())
    }

    public var isBlocked: Bool {
//        let blockedUsers = UserDefaultsUtil.shared.getBlockedUsersFromDefaults()
//        return blockedUsers.contains(matrixId)
        false
    }
}

extension ZMatrixUser: Equatable {
    public static func == (lhs: ZMatrixUser, rhs: ZMatrixUser) -> Bool {
        lhs.id == rhs.id
    }
}

extension ZMatrixUser: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ZMatrixUser {
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

// Mock Users

// swiftlint:disable line_length
public extension ZMatrixUser {
    static let frederickGuerrero = ZMatrixUser(id: Tagged<ZMatrixUser, String>(rawValue: UUID().uuidString),
                                               profileId: UUID().uuidString,
                                               handle: "frederick",
                                               lastActiveAt: Date(),
                                               isOnline: true,
                                               isPending: false,
                                               matrixId: "@9033a034-0e4d-425f-b400-0230c7a473e7:zero-synapse-development.zer0.io",
                                               matrixAccessToken: "b2128fee7f039e7065f00d71358677e7",
                                               // createdAt: Date(),
                                               // updatedAt: Date(),
                                               profileSummary: .init(id: UUID().uuidString,
                                                                     firstName: "Frederick",
                                                                     lastName: "Guerrero",
                                                                     gender: "Male",
                                                                     summary: "Owner of vegan Burgerlords restaurants and founder of the independent art gallery Slow Culture, both of which are based in Los Angeles.",
                                                                     backgroundImage: "https://png.pngtree.com/thumb_back/fh260/back_pic/00/02/44/5056179b42b174f.jpg",
                                                                     profileImage: "https://gravatar.com/avatar/97c92c9e527e2950efa4dad69b0e6458?s=400&d=robohash&r=x",
                                                                     ssbPublicKey: "ssh-key"),
                                               primaryZID: nil,
                                               primaryWalletAddress: nil)

    static let nataliaBonifacci = ZMatrixUser(id: Tagged<ZMatrixUser, String>(rawValue: UUID().uuidString),
                                              profileId: UUID().uuidString,
                                              handle: "nataliabonifacci",
                                              lastActiveAt: Date(),
                                              isOnline: true,
                                              isPending: false,
                                              matrixId: "@c06f61e1-1116-4113-aa0f-0deb54a0e14e:zero-synapse-development.zer0.io",
                                              matrixAccessToken: "b2128fee7f039e7065f00d71358677e7",
                                              // createdAt: Date(),
                                              // updatedAt: Date(),
                                              profileSummary: .init(id: UUID().uuidString,
                                                                    firstName: "Natalia",
                                                                    lastName: "Bonifacci",
                                                                    gender: "Female",
                                                                    summary: "Italian and Costa Rican creative whose casual yet sophisticated style led her campaigns for Sportmax and FORWARD.",
                                                                    backgroundImage: "https://png.pngtree.com/thumb_back/fh260/back_pic/00/02/44/5056179b42b174f.jpg",
                                                                    profileImage: "https://gravatar.com/avatar/8b01c662419106d1bb45b6fc4ad669b3?s=400&d=robohash&r=x",
                                                                    ssbPublicKey: "ssh-key"),
                                              primaryZID: nil,
                                              primaryWalletAddress: nil)

    static let yanaYatsuk = ZMatrixUser(id: Tagged<ZMatrixUser, String>(rawValue: UUID().uuidString),
                                        profileId: UUID().uuidString,
                                        handle: "yanayatsuk",
                                        lastActiveAt: Date(),
                                        isOnline: false,
                                        isPending: false,
                                        matrixId: "@a7751f99-84d2-4012-998c-0b3556d38fda:zero-synapse-development.zer0.io",
                                        matrixAccessToken: "b2128fee7f039e7065f00d71358677e7",
                                        // createdAt: Date(),
                                        // updatedAt: Date(),
                                        profileSummary: .init(id: UUID().uuidString,
                                                              firstName: "Yana",
                                                              lastName: "Yatsuk",
                                                              gender: "Male",
                                                              summary: "Los Angeles-based photographer whose work has been featured in Rolling Stone and Playboy.",
                                                              backgroundImage: "https://png.pngtree.com/thumb_back/fh260/back_pic/00/02/44/5056179b42b174f.jpg",
                                                              profileImage: "https://robohash.org/1bacfb4011d2aa75b4898e86d52c4ee4?set=set4&bgset=&size=400x400",
                                                              ssbPublicKey: "ssh-key"),
                                        primaryZID: nil,
                                        primaryWalletAddress: nil)

    static var mockUsers: [ZMatrixUser] {
        [
            .frederickGuerrero,
            .nataliaBonifacci,
            .yanaYatsuk
        ]
    }
}

// swiftlint:enable line_length
