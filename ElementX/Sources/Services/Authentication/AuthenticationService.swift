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

import Combine
import Foundation
import MatrixRustSDK

class AuthenticationService: AuthenticationServiceProtocol {
    private var client: Client?
    private let sessionDirectory: URL
    private let passphrase: String
    
    private let userSessionStore: UserSessionStoreProtocol
    private let appSettings: AppSettings
    private let appHooks: AppHooks
    
    private let homeserverSubject: CurrentValueSubject<LoginHomeserver, Never>
    var homeserver: CurrentValuePublisher<LoginHomeserver, Never> { homeserverSubject.asCurrentValuePublisher() }
    
    init(userSessionStore: UserSessionStoreProtocol, encryptionKeyProvider: EncryptionKeyProviderProtocol, appSettings: AppSettings, appHooks: AppHooks) {
        sessionDirectory = .sessionsBaseDirectory.appending(component: UUID().uuidString)
        passphrase = encryptionKeyProvider.generateKey().base64EncodedString()
        self.userSessionStore = userSessionStore
        self.appSettings = appSettings
        self.appHooks = appHooks
        
        homeserverSubject = .init(LoginHomeserver(address: appSettings.defaultHomeserverAddress,
                                                  loginMode: .unknown))
    }
    
    // MARK: - Public
    
    func configure(for homeserverAddress: String) async -> Result<Void, AuthenticationServiceError> {
        do {
            var homeserver = LoginHomeserver(address: homeserverAddress, loginMode: .unknown)
            
            let client = try await makeClientBuilder().serverNameOrHomeserverUrl(serverNameOrUrl: homeserverAddress).build()
            let loginDetails = await client.homeserverLoginDetails()
            
            if loginDetails.supportsOidcLogin() {
                homeserver.loginMode = .oidc
            } else if loginDetails.supportsPasswordLogin() {
                homeserver.loginMode = .password
            } else {
                homeserver.loginMode = .unsupported
            }
            
            self.client = client
            homeserverSubject.send(homeserver)
            return .success(())
        } catch ClientBuildError.WellKnownDeserializationError(let error) {
            MXLog.error("The user entered a server with an invalid well-known file: \(error)")
            return .failure(.invalidWellKnown(error))
        } catch ClientBuildError.SlidingSyncNotAvailable {
            MXLog.info("User entered a homeserver that isn't configured for sliding sync.")
            return .failure(.slidingSyncNotAvailable)
        } catch {
            MXLog.error("Failed configuring a server: \(error)")
            return .failure(.invalidHomeserverAddress)
        }
    }
    
    func urlForOIDCLogin() async -> Result<OIDCAuthorizationDataProxy, AuthenticationServiceError> {
        guard let client else { return .failure(.oidcError(.urlFailure)) }
        do {
            let oidcData = try await client.urlForOidcLogin(oidcConfiguration: appSettings.oidcConfiguration.rustValue)
            return .success(OIDCAuthorizationDataProxy(underlyingData: oidcData))
        } catch {
            MXLog.error("Failed to get URL for OIDC login: \(error)")
            return .failure(.oidcError(.urlFailure))
        }
    }
    
    func abortOIDCLogin(data: OIDCAuthorizationDataProxy) async {
        guard let client else { return }
        MXLog.info("Aborting OIDC login.")
        await client.abortOidcLogin(authorizationData: data.underlyingData)
    }
    
    func loginWithOIDCCallback(_ callbackURL: URL, data: OIDCAuthorizationDataProxy) async -> Result<UserSessionProtocol, AuthenticationServiceError> {
        guard let client else { return .failure(.failedLoggingIn) }
        do {
            try await client.loginWithOidcCallback(authorizationData: data.underlyingData, callbackUrl: callbackURL.absoluteString)
            return await userSession(for: client)
        } catch OidcError.Cancelled {
            return .failure(.oidcError(.userCancellation))
        } catch {
            MXLog.error("Login with OIDC failed: \(error)")
            return .failure(.failedLoggingIn)
        }
    }
    
    func login(username: String, password: String, initialDeviceName: String?, deviceID: String?) async -> Result<UserSessionProtocol, AuthenticationServiceError> {
        guard let client else { return .failure(.failedLoggingIn) }
        do {
            try await loginWithZero(email: username, password: password)
            let zeroSession = try await handleSuccessLogin()
            // create the matrix session from zero session values
            let matrixSession = Session(accessToken: zeroSession.accessToken,
                                        refreshToken: nil,
                                        userId: zeroSession.userID,
                                        deviceId: zeroSession.deviceID,
                                        homeserverUrl: zeroSession.homeServer,
                                        oidcData: nil, slidingSyncProxy: nil)
            try await client.restoreSession(session: matrixSession)
            return await userSession(for: client)
            
//            try await client.login(username: username, password: password, initialDeviceName: initialDeviceName, deviceId: deviceID)
//
//            let refreshToken = try? client.session().refreshToken
//            if refreshToken != nil {
//                MXLog.warning("Refresh token found for a non oidc session, can't restore session, logging out")
//                _ = try? await client.logout()
//                return .failure(.sessionTokenRefreshNotSupported)
//            }
//
//            return await userSession(for: client)
            
        } catch {
            MXLog.error("Failed logging in with error: \(error)")
            // FIXME: How about we make a proper type in the FFI? 😅
            guard let error = error as? ClientError else { return .failure(.failedLoggingIn) }
            
            if error.isElementWaitlist {
                return .failure(.isOnWaitlist)
            }
            
            switch error.code {
            case .forbidden:
                return .failure(.invalidCredentials)
            case .userDeactivated:
                return .failure(.accountDeactivated)
            default:
                return .failure(.failedLoggingIn)
            }
        }
    }
    
    // MARK: - Private
    
    private func makeClientBuilder() -> ClientBuilder {
        ClientBuilder
            .baseBuilder(httpProxy: appSettings.websiteURL.globalProxy,
                         slidingSync: appSettings.simplifiedSlidingSyncEnabled ? .simplified : .discovered,
                         slidingSyncProxy: appSettings.slidingSyncProxyURL,
                         sessionDelegate: userSessionStore.clientSessionDelegate,
                         appHooks: appHooks)
            .sessionPath(path: sessionDirectory.path(percentEncoded: false))
            .passphrase(passphrase: passphrase)
    }
    
    private func userSession(for client: Client) async -> Result<UserSessionProtocol, AuthenticationServiceError> {
        switch await userSessionStore.userSession(for: client, sessionDirectory: sessionDirectory, passphrase: passphrase) {
        case .success(let clientProxy):
            return .success(clientProxy)
        case .failure:
            return .failure(.failedLoggingIn)
        }
    }
    
    private func loginWithZero(email: String, password: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            let signInReq = ZSignInRequest(email: email, password: password)
            NetworkManager.shared.zeroSDK.signin(signInReq) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case let .success(authData):
                    ZeroSDK.accessToken = authData.accessToken
                    continuation.resume()
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func handleSuccessLogin() async throws -> MatrixSession {
        let token = try await fetchSSOToken()
        let session = try await fetchMatrixSession(token: token)
        let currentUser = try await fetchCurrentUser()
        
        if currentUser.matrixId == nil {
            try await NetworkManager.shared.zeroSDK.migrateUserToMatrix(userID: currentUser.id)
        }
        return session
    }
    
    private func fetchSSOToken() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            NetworkManager.shared.zeroSDK.fetchSSOToken { result in
                switch result {
                case let .success(data):
                    continuation.resume(returning: data.token)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func fetchMatrixSession(token: String) async throws -> MatrixSession {
        guard let url = URL(string: API.matrixURLString) else {
            preconditionFailure("Unable to resolve Matrix URL: \(API.matrixURLString)")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let body = ZMatrixSessionRequest(token: token)
            
            NetworkManager.shared.zeroSDK.fetchMatrixSessionData(body,
                                                                 matrixURL: url,
                                                                 completionHandler: { result in
                                                                     switch result {
                                                                     case let .success(data):
                                                                         continuation.resume(returning: MatrixSession(session: data))
                                                                     case let .failure(error):
                                                                         print(error)
                                                                         continuation.resume(throwing: error)
                                                                     }
                                                                 })
        }
    }
    
    private func fetchCurrentUser() async throws -> ZCurrentUser {
        try await withCheckedThrowingContinuation { continuation in
            NetworkManager.shared.zeroSDK.currentUser { result in
                switch result {
                case let .success(user):
                    continuation.resume(returning: user)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
