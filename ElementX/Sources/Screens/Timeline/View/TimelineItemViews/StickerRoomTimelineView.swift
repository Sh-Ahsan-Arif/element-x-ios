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

import Foundation
import SwiftUI

struct StickerRoomTimelineView: View {
    @EnvironmentObject private var context: TimelineViewModel.Context
    let timelineItem: StickerRoomTimelineItem
    
    var body: some View {
        TimelineStyler(timelineItem: timelineItem) {
            LoadableImage(url: timelineItem.imageURL,
                          blurhash: timelineItem.blurhash,
                          mediaProvider: context.mediaProvider) {
                placeholder
            }
            .timelineMediaFrame(height: timelineItem.height,
                                aspectRatio: timelineItem.aspectRatio)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(L10n.commonSticker), \(timelineItem.body)")
        }
    }
    
    private var placeholder: some View {
        ZStack {
            Rectangle()
                .foregroundColor(timelineItem.isOutgoing ? .compound._bgBubbleOutgoing : .compound._bgBubbleIncoming)
                .opacity(0.3)
            
            ProgressView(L10n.commonLoading)
                .frame(maxWidth: .infinity)
        }
    }
}

struct StickerRoomTimelineView_Previews: PreviewProvider, TestablePreview {
    static let viewModel = TimelineViewModel.mock
    
    static var previews: some View {
        body.environmentObject(viewModel.context)
    }
    
    static var body: some View {
        VStack(spacing: 20.0) {
            StickerRoomTimelineView(timelineItem: StickerRoomTimelineItem(id: .random,
                                                                          body: "Some image",
                                                                          timestamp: "Now",
                                                                          isOutgoing: false,
                                                                          isEditable: false,
                                                                          canBeRepliedTo: true,
                                                                          sender: .init(id: "Bob"),
                                                                          imageURL: URL.picturesDirectory))
            
            StickerRoomTimelineView(timelineItem: StickerRoomTimelineItem(id: .random,
                                                                          body: "Some other image",
                                                                          timestamp: "Now",
                                                                          isOutgoing: false,
                                                                          isEditable: false,
                                                                          canBeRepliedTo: true,
                                                                          sender: .init(id: "Bob"),
                                                                          imageURL: URL.picturesDirectory))
            
            StickerRoomTimelineView(timelineItem: StickerRoomTimelineItem(id: .random,
                                                                          body: "Blurhashed image",
                                                                          timestamp: "Now",
                                                                          isOutgoing: false,
                                                                          isEditable: false,
                                                                          canBeRepliedTo: true,
                                                                          sender: .init(id: "Bob"),
                                                                          imageURL: URL.picturesDirectory,
                                                                          aspectRatio: 0.7,
                                                                          blurhash: "L%KUc%kqS$RP?Ks,WEf8OlrqaekW"))
        }
    }
}
