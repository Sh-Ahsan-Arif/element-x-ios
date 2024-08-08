import Foundation
import Tagged

public struct ZUser: Decodable, Equatable, Identifiable {
    public let id: Tagged<Self, String>
    public let profileId: String
    public let type: String
    public let name: String
    public let summary: String?
    public let profileImage: URL
    public let isOnline: Bool
    public let lastActiveAt: Date?
    public let isAdmin: Bool
    public let isAssistantAdmin: Bool
    public let matrixId: String?
}
