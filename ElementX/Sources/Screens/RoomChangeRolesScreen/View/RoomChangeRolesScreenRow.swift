//
// Copyright 2023 New Vector Ltd
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

import Compound
import MatrixRustSDK
import SwiftUI

struct RoomChangeRolesScreenRow: View {
    let member: RoomMemberDetails
    let mediaProvider: MediaProviderProtocol?
    
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        ListRow(label: .avatar(title: member.name ?? member.id,
                               status: member.isInvited ? L10n.screenRoomMemberListPendingHeaderTitle : nil,
                               description: member.name == nil ? nil : member.id,
                               icon: avatar),
                kind: .multiSelection(isSelected: isSelected, action: action))
    }
    
    var avatar: LoadableAvatarImage {
        LoadableAvatarImage(url: member.avatarURL,
                            name: member.name,
                            contentID: member.id,
                            avatarSize: .user(on: .startChat),
                            mediaProvider: mediaProvider)
    }
}

struct RoomChangeRolesScreenRow_Previews: PreviewProvider, TestablePreview {
    static let action: () -> Void = { }
    
    static var previews: some View {
        Form {
            RoomChangeRolesScreenRow(member: .init(withProxy: RoomMemberProxyMock.mockAlice),
                                     mediaProvider: MockMediaProvider(),
                                     isSelected: true,
                                     action: action)
            
            RoomChangeRolesScreenRow(member: .init(withProxy: RoomMemberProxyMock.mockBob),
                                     mediaProvider: MockMediaProvider(),
                                     isSelected: false,
                                     action: action)
            
            RoomChangeRolesScreenRow(member: .init(withProxy: RoomMemberProxyMock.mockInvited),
                                     mediaProvider: MockMediaProvider(),
                                     isSelected: false,
                                     action: action)
            
            RoomChangeRolesScreenRow(member: .init(withProxy: RoomMemberProxyMock.mockCharlie),
                                     mediaProvider: MockMediaProvider(),
                                     isSelected: true,
                                     action: action)
                .disabled(true)
            
            RoomChangeRolesScreenRow(member: .init(withProxy: RoomMemberProxyMock(with: .init(userID: "@someone:matrix.org", membership: .join))),
                                     mediaProvider: MockMediaProvider(),
                                     isSelected: false,
                                     action: action)
                .disabled(true)
            
            RoomChangeRolesScreenRow(member: .init(withProxy: RoomMemberProxyMock(with: .init(userID: "@someone:matrix.org", membership: .join))),
                                     mediaProvider: MockMediaProvider(),
                                     isSelected: false,
                                     action: action)
        }
        .compoundList()
    }
}
