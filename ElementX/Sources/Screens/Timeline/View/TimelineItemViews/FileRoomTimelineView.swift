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
import SwiftUI

struct FileRoomTimelineView: View {
    let timelineItem: FileRoomTimelineItem
    
    var body: some View {
        TimelineStyler(timelineItem: timelineItem) {
            Label(title: { Text(timelineItem.body) },
                  icon: { Image(systemName: "doc.text.fill")
                      .foregroundColor(.compound.iconPrimary)
                  })
                  .labelStyle(RoomTimelineViewLabelStyle())
                  .font(.compound.bodyLG)
                  .padding(.vertical, 12)
                  .padding(.horizontal, 6)
                  .accessibilityLabel(L10n.commonFile)
        }
    }
}

struct FileRoomTimelineView_Previews: PreviewProvider, TestablePreview {
    static let viewModel = TimelineViewModel.mock
    
    static var previews: some View {
        body.environmentObject(viewModel.context)
    }
    
    static var body: some View {
        VStack(spacing: 20.0) {
            FileRoomTimelineView(timelineItem: FileRoomTimelineItem(id: .random,
                                                                    timestamp: "Now",
                                                                    isOutgoing: false,
                                                                    isEditable: false,
                                                                    canBeRepliedTo: true,
                                                                    isThreaded: false,
                                                                    sender: .init(id: "Bob"),
                                                                    content: .init(body: "document.pdf", source: nil, thumbnailSource: nil, contentType: nil)))

            FileRoomTimelineView(timelineItem: FileRoomTimelineItem(id: .random,
                                                                    timestamp: "Now",
                                                                    isOutgoing: false,
                                                                    isEditable: false,
                                                                    canBeRepliedTo: true,
                                                                    isThreaded: false,
                                                                    sender: .init(id: "Bob"),
                                                                    content: .init(body: "document.docx", source: nil, thumbnailSource: nil, contentType: nil)))
            
            FileRoomTimelineView(timelineItem: FileRoomTimelineItem(id: .random,
                                                                    timestamp: "Now",
                                                                    isOutgoing: false,
                                                                    isEditable: false,
                                                                    canBeRepliedTo: true,
                                                                    isThreaded: false,
                                                                    sender: .init(id: "Bob"),
                                                                    content: .init(body: "document.txt", source: nil, thumbnailSource: nil, contentType: nil)))
        }
    }
}
