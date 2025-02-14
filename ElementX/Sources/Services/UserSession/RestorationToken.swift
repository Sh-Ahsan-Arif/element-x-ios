//
// Copyright 2022 New Vector Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import MatrixRustSDK

struct RestorationToken: Equatable {
    let session: MatrixRustSDK.Session
    let sessionDirectory: URL
    let passphrase: String?
    let pusherNotificationClientIdentifier: String?
}

extension RestorationToken: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let session = try container.decode(MatrixRustSDK.Session.self, forKey: .session)
        let sessionDirectory = try container.decodeIfPresent(URL.self, forKey: .sessionDirectory)
        
        self = try .init(session: session,
                         sessionDirectory: sessionDirectory ?? .legacySessionDirectory(for: session.userId),
                         passphrase: container.decodeIfPresent(String.self, forKey: .passphrase),
                         pusherNotificationClientIdentifier: container.decodeIfPresent(String.self, forKey: .pusherNotificationClientIdentifier))
    }
}

extension MatrixRustSDK.Session: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self = try .init(accessToken: container.decode(String.self, forKey: .accessToken),
                         refreshToken: container.decodeIfPresent(String.self, forKey: .refreshToken),
                         userId: container.decode(String.self, forKey: .userId),
                         deviceId: container.decode(String.self, forKey: .deviceId),
                         homeserverUrl: container.decode(String.self, forKey: .homeserverUrl),
                         oidcData: container.decodeIfPresent(String.self, forKey: .oidcData),
                         // Note: the proxy is optional now that we support Simplified Sliding Sync.
                         slidingSyncProxy: container.decodeIfPresent(String.self, forKey: .slidingSyncProxy))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(userId, forKey: .userId)
        try container.encode(deviceId, forKey: .deviceId)
        try container.encode(homeserverUrl, forKey: .homeserverUrl)
        try container.encode(oidcData, forKey: .oidcData)
        try container.encode(slidingSyncProxy, forKey: .slidingSyncProxy)
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken, refreshToken, userId, deviceId, homeserverUrl, oidcData, slidingSyncProxy
    }
}

// MARK: Migrations

private extension URL {
    /// Gets the store directory of a legacy session that hasn't been migrated to the new token format.
    ///
    /// This should only be used to fill in the missing value when restoring a token as older versions of
    /// the SDK set the session directory for us, based on the user's ID. Newer sessions now use a UUID,
    /// which is generated app side during authentication.
    static func legacySessionDirectory(for userID: String) -> URL {
        // Rust sanitises the user ID replacing invalid characters with an _
        let sanitisedUserID = userID.replacingOccurrences(of: ":", with: "_")
        return .sessionsBaseDirectory.appendingPathComponent(sanitisedUserID)
    }
}
