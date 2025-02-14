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

// MARK: - TimelineStyler

struct TimelineStyler<Content: View>: View {
    let timelineItem: EventBasedTimelineItemProtocol
    @ViewBuilder let content: () -> Content
    
    @State private var adjustedDeliveryStatus: TimelineItemDeliveryStatus?
    @State private var task: Task<Void, Never>?
    
    init(timelineItem: EventBasedTimelineItemProtocol, @ViewBuilder content: @escaping () -> Content) {
        self.timelineItem = timelineItem
        self.content = content
        _adjustedDeliveryStatus = State(initialValue: timelineItem.properties.deliveryStatus)
    }

    var body: some View {
        mainContent
            .onChange(of: timelineItem.properties.deliveryStatus) { newStatus in
                if newStatus == .sendingFailed {
                    guard task == nil else {
                        return
                    }
                    task = Task {
                        try? await Task.sleep(for: .milliseconds(700))
                        if !Task.isCancelled {
                            adjustedDeliveryStatus = newStatus
                        }
                        task = nil
                    }
                } else {
                    task?.cancel()
                    task = nil
                    adjustedDeliveryStatus = newStatus
                }
            }
            .animation(.elementDefault, value: adjustedDeliveryStatus)
    }
    
    @ViewBuilder
    var mainContent: some View {
        TimelineItemBubbledStylerView(timelineItem: timelineItem, adjustedDeliveryStatus: adjustedDeliveryStatus, content: content)
    }
}

struct TimelineItemStyler_Previews: PreviewProvider, TestablePreview {
    static let viewModel = TimelineViewModel.mock

    static let base = TextRoomTimelineItem(id: .random,
                                           timestamp: "Now",
                                           isOutgoing: true,
                                           isEditable: false,
                                           canBeRepliedTo: true,
                                           isThreaded: false,
                                           sender: .test,
                                           content: .init(body: "Test"))

    static let sentNonLast: TextRoomTimelineItem = {
        var result = base
        result.properties.deliveryStatus = .sent
        return result
    }()

    static let sendingNonLast: TextRoomTimelineItem = {
        var result = base
        result.properties.deliveryStatus = .sending
        return result
    }()

    static let sendingLast: TextRoomTimelineItem = {
        let id = viewModel.state.timelineViewState.timelineIDs.last ?? UUID().uuidString
        var result = TextRoomTimelineItem(id: .init(timelineID: id),
                                          timestamp: "Now",
                                          isOutgoing: true,
                                          isEditable: false,
                                          canBeRepliedTo: true,
                                          isThreaded: false,
                                          sender: .test,
                                          content: .init(body: "Test"))
        result.properties.deliveryStatus = .sending
        return result
    }()

    static let failed: TextRoomTimelineItem = {
        var result = base
        result.properties.deliveryStatus = .sendingFailed
        return result
    }()

    static let sentLast: TextRoomTimelineItem = {
        let id = viewModel.state.timelineViewState.timelineIDs.last ?? UUID().uuidString
        let result = TextRoomTimelineItem(id: .init(timelineID: id),
                                          timestamp: "Now",
                                          isOutgoing: true,
                                          isEditable: false,
                                          canBeRepliedTo: true,
                                          isThreaded: false,
                                          sender: .test,
                                          content: .init(body: "Test"))
        return result
    }()

    static let ltrString = TextRoomTimelineItem(id: .random,
                                                timestamp: "Now",
                                                isOutgoing: true,
                                                isEditable: false,
                                                canBeRepliedTo: true,
                                                isThreaded: false,
                                                sender: .test, content: .init(body: "house!"))

    static let rtlString = TextRoomTimelineItem(id: .random,
                                                timestamp: "Now",
                                                isOutgoing: true,
                                                isEditable: false,
                                                canBeRepliedTo: true,
                                                isThreaded: false,
                                                sender: .test, content: .init(body: "באמת!"))

    static let ltrStringThatContainsRtl = TextRoomTimelineItem(id: .random,
                                                               timestamp: "Now",
                                                               isOutgoing: true,
                                                               isEditable: false,
                                                               canBeRepliedTo: true,
                                                               isThreaded: false,
                                                               sender: .test,
                                                               content: .init(body: "house! -- באמת‏! -- house!"))

    static let rtlStringThatContainsLtr = TextRoomTimelineItem(id: .random,
                                                               timestamp: "Now",
                                                               isOutgoing: true,
                                                               isEditable: false,
                                                               canBeRepliedTo: true,
                                                               isThreaded: false,
                                                               sender: .test,
                                                               content: .init(body: "באמת‏! -- house! -- באמת!"))

    static let ltrStringThatFinishesInRtl = TextRoomTimelineItem(id: .random,
                                                                 timestamp: "Now",
                                                                 isOutgoing: true,
                                                                 isEditable: false,
                                                                 canBeRepliedTo: true,
                                                                 isThreaded: false,
                                                                 sender: .test,
                                                                 content: .init(body: "house! -- באמת!"))

    static let rtlStringThatFinishesInLtr = TextRoomTimelineItem(id: .random,
                                                                 timestamp: "Now",
                                                                 isOutgoing: true,
                                                                 isEditable: false,
                                                                 canBeRepliedTo: true,
                                                                 isThreaded: false,
                                                                 sender: .test,
                                                                 content: .init(body: "באמת‏! -- house!"))

    static var testView: some View {
        VStack(spacing: 0) {
            TextRoomTimelineView(timelineItem: base)
            TextRoomTimelineView(timelineItem: sentNonLast)
            TextRoomTimelineView(timelineItem: sentLast)
            TextRoomTimelineView(timelineItem: sendingNonLast)
            TextRoomTimelineView(timelineItem: sendingLast)
            TextRoomTimelineView(timelineItem: failed)
        }
    }

    static var languagesTestView: some View {
        VStack(spacing: 0) {
            TextRoomTimelineView(timelineItem: ltrString)
            TextRoomTimelineView(timelineItem: rtlString)
            TextRoomTimelineView(timelineItem: ltrStringThatContainsRtl)
            TextRoomTimelineView(timelineItem: rtlStringThatContainsLtr)
            TextRoomTimelineView(timelineItem: ltrStringThatFinishesInRtl)
            TextRoomTimelineView(timelineItem: rtlStringThatFinishesInLtr)
        }
    }

    static var previews: some View {
        testView
            .environmentObject(viewModel.context)
            .previewDisplayName("Bubbles")
        
        languagesTestView
            .environmentObject(viewModel.context)
            .previewDisplayName("Bubbles LTR with different layout languages")

        languagesTestView
            .environmentObject(viewModel.context)
            .environment(\.layoutDirection, .rightToLeft)
            .previewDisplayName("Bubbles RTL with different layout languages")
    }
}
