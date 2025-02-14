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

import Foundation
import MatrixRustSDK

extension ClientBuilder {
    /// A helper method that applies the common builder modifiers needed for the app.
    static func baseBuilder(setupEncryption: Bool = true,
                            httpProxy: String? = nil,
                            slidingSync: ClientBuilderSlidingSync,
                            slidingSyncProxy: URL? = nil,
                            sessionDelegate: ClientSessionDelegate,
                            appHooks: AppHooks) -> ClientBuilder {
        var builder = ClientBuilder()
            .slidingSyncProxy(slidingSyncProxy: slidingSyncProxy?.absoluteString)
            .enableCrossProcessRefreshLock(processId: InfoPlistReader.main.bundleIdentifier, sessionDelegate: sessionDelegate)
            .userAgent(userAgent: UserAgentBuilder.makeASCIIUserAgent())
            .requestConfig(config: .init(retryLimit: 0, timeout: 15000, maxConcurrentRequests: nil, retryTimeout: nil))
        
        builder = switch slidingSync {
        case .restored: builder
        case .discovered: builder.requiresSlidingSync()
        case .simplified: builder.simplifiedSlidingSync(enable: true)
        }
        
        if setupEncryption {
            builder = builder
                .autoEnableCrossSigning(autoEnableCrossSigning: true)
                .backupDownloadStrategy(backupDownloadStrategy: .afterDecryptionFailure)
                .autoEnableBackups(autoEnableBackups: true)
        }
        
        if let httpProxy {
            builder = builder.proxy(url: httpProxy)
        }
        
        return appHooks.clientBuilderHook.configure(builder)
    }
}

enum ClientBuilderSlidingSync {
    /// The proxy will be supplied when restoring the Session.
    case restored
    /// A proxy must be discovered whilst building the session.
    case discovered
    /// Use Simplified Sliding Sync (discovery isn't a thing yet).
    case simplified
}
