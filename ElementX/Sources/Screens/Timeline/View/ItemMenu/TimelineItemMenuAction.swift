//
// Copyright 2024 New Vector Ltd
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

import SFSafeSymbols
import SwiftUI

struct TimelineItemMenuActions {
    let reactions: [TimelineItemMenuReaction]
    let actions: [TimelineItemMenuAction]
    let debugActions: [TimelineItemMenuAction]
    
    init?(isReactable: Bool, actions: [TimelineItemMenuAction], debugActions: [TimelineItemMenuAction]) {
        if !isReactable, actions.isEmpty, debugActions.isEmpty {
            return nil
        }
        
        self.actions = actions
        self.debugActions = debugActions
        reactions = if isReactable {
            [
                .init(key: "👍️", symbol: .handThumbsup),
                .init(key: "👎️", symbol: .handThumbsdown),
                .init(key: "🔥", symbol: .flame),
                .init(key: "❤️", symbol: .heart),
                .init(key: "👏", symbol: .handsClap)
            ]
        } else {
            []
        }
    }
}

struct TimelineItemMenuReaction {
    let key: String
    let symbol: SFSymbol
}

enum TimelineItemMenuAction: Identifiable, Hashable {
    case copy
    case edit
    case copyPermalink
    case redact
    case reply(isThread: Bool)
    case forward(itemID: TimelineItemIdentifier)
    case viewSource
    case retryDecryption(sessionID: String)
    case report
    case react
    case toggleReaction(key: String)
    case endPoll(pollStartID: String)
    case pin
    case unpin
    
    var id: Self { self }
    
    /// Whether the item should cancel a reply/edit occurring in the composer.
    var switchToDefaultComposer: Bool {
        switch self {
        case .reply, .edit:
            return false
        default:
            return true
        }
    }
    
    /// Whether the action should be shown for an item that failed to send.
    var canAppearInFailedEcho: Bool {
        switch self {
        case .copy, .edit, .redact, .viewSource:
            return true
        default:
            return false
        }
    }
    
    /// Whether the action should be shown for a redacted item.
    var canAppearInRedacted: Bool {
        switch self {
        case .viewSource:
            return true
        default:
            return false
        }
    }
    
    /// Whether or not the action is destructive.
    var isDestructive: Bool {
        switch self {
        case .redact, .report:
            return true
        default:
            return false
        }
    }
    
    /// The action's label.
    @ViewBuilder
    var label: some View {
        switch self {
        case .copy:
            Label(L10n.actionCopy, icon: \.copy)
        case .edit:
            Label(L10n.actionEdit, icon: \.edit)
        case .copyPermalink:
            Label(L10n.actionCopyLinkToMessage, icon: \.link)
        case .reply(let isThread):
            Label(isThread ? L10n.actionReplyInThread : L10n.actionReply, icon: \.reply)
        case .forward:
            Label(L10n.actionForward, icon: \.forward)
        case .redact:
            Label(L10n.actionRemove, icon: \.delete)
        case .viewSource:
            Label(L10n.actionViewSource, icon: \.code)
        case .retryDecryption:
            Label(L10n.actionRetryDecryption, systemImage: "arrow.down.message")
        case .report:
            Label(L10n.actionReportContent, icon: \.chatProblem)
        case .react:
            Label(L10n.actionReact, icon: \.reactionAdd)
        case .toggleReaction:
            // Unused label - manually created in TimelineItemMacContextMenu.
            Label(L10n.actionReact, icon: \.reactionAdd)
        case .endPoll:
            Label(L10n.actionEndPoll, icon: \.pollsEnd)
        case .pin:
            Label(L10n.actionPin, icon: \.pin)
        case .unpin:
            Label(L10n.actionUnpin, icon: \.unpin)
        }
    }
}
