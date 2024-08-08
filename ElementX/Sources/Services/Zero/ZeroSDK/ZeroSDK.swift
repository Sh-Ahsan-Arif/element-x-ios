import Foundation

public class ZeroSDK: NSObject {
    public static var accessToken: String?
    public static var chatAccessToken: String?

    // MARK: - Properties

    let session: URLSession
    let host: URL
    let callbackQueue: DispatchQueue = .main
    let authProvider: AuthProvider
    var pendingRequests: [(AuthResult) -> Void] = []

    // MARK: - Initializer

    public init(sessionConfiguration: URLSessionConfiguration = .ephemeral, host: URL, authProvider: AuthProvider) {
        sessionConfiguration.timeoutIntervalForRequest = 15
        sessionConfiguration.timeoutIntervalForResource = 15
        session = URLSession(configuration: sessionConfiguration)
        self.host = host
        self.authProvider = authProvider

        super.init()
    }

    // MARK: - Private methods

    /// Enqueues a pending request that will be performed once authentication is complete.
    func enqueuePendingRequest<A>(_ request: ZeroRequest<A>,
                                  completion: @escaping (Result<A, ZError>) -> Void) {
        let typeErased: (AuthResult) -> Void = { authenticationResult in
            switch authenticationResult {
            case let .authenticated(token):
                var authorizedRequest = request
                self.authProvider.authorize(&authorizedRequest.urlRequest, with: token)
                self.perform(request: authorizedRequest, completion: completion)
            case .cancelled:
                self.callbackQueue.async {
                    completion(.failure(.authenticationCancelled))
                }
            case let .failed(error):
                self.callbackQueue.async {
                    completion(.failure(error))
                }
            }
        }

        pendingRequests.append(typeErased)
    }

    /// Notifies pending requests of the result of authentication, starting them if necessary.
    func notifyPendingRequests(with authenticationResult: AuthResult) {
        let requests = pendingRequests
        pendingRequests.removeAll()
        requests.forEach { completionHandler in
            completionHandler(authenticationResult)
        }
    }

    /// Entry point for performing authorized requests, reauthenticating if
    /// necessary. Uses the current `CurrentAuthState` to determine whether
    /// to perform the request, authenticate first, or wait for authentication
    /// to complete before performing the request.
    func perform<A>(authorizedRequest: ZeroRequest<A>,
                    completion: @escaping (Result<A, ZError>) -> Void) {
        switch authProvider.fetchToken() {
        case .unauthenticated:
            enqueuePendingRequest(authorizedRequest, completion: completion)
            authProvider.authenticate { authenticationResult in
                self.notifyPendingRequests(with: authenticationResult)
            }
        case .authenticating:
            enqueuePendingRequest(authorizedRequest, completion: completion)
        case let .authenticated(token):
            var endpoint = authorizedRequest

//            #if DEBUG
//                if let url = endpoint.urlRequest.url {
//                    print("*** endpoint: \(url.path)")
//                }
//            #endif

            authProvider.authorize(&endpoint.urlRequest, with: token)
            perform(request: endpoint, completion: completion)
        }
    }

    func perform<A>(request: ZeroRequest<A>,
                    completion: @escaping (Result<A, ZError>) -> Void,
                    decoder: JSONDecoder = .init()) {
        session.dataTask(with: request.urlRequest, completionHandler: { data, response, error in

            let result: Result<A, ZError>
            defer {
                DispatchQueue.main.async {
                    completion(result)
                }
            }

            if let error = error {
                result = .failure(.networkError(error)); return
            }

            guard let res = response as? HTTPURLResponse, res.statusCode != 401 else {
                NotificationCenter.default.post(name: Notification.Name.unauthorizedRequest, object: nil)
                result = .failure(.unauthorizedRequest); return
            }

            guard let httpResponse = response as? HTTPURLResponse, 200...204 ~= httpResponse.statusCode else {
                let errorResponse = try? decoder.decode(ZErrorResponse.self, from: data ?? Data())
                result = .failure(.requestError(errorResponse)); return
            }

            guard let data = data else {
                result = .failure(.invalidResponse); return
            }

            // #if DEBUG
            //  Commenting this out to clean up some of the noise in the console
            // if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            //    print(json, "\n\n\n")
            // } else if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            //    print(json, "\n\n\n")
            // }
            // #endif

            result = request.parse(data)
        }).resume()
    }

    func future<A>(
        resource: ZeroRequest<A>
    ) -> Future<A> {
        Future<A> { callback in
            self.perform(request: resource, completion: callback)
        }
    }

    func future<A>(
        authorizedResource resource: ZeroRequest<A>
    ) -> Future<A> {
        Future<A> { callback in
            self.perform(authorizedRequest: resource, completion: callback)
        }
    }

    func zeroDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

        return dateFormatter
    }

    func zeroDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(zeroDateFormatter())

        return decoder
    }
}

public extension Notification.Name {
    static let unauthorizedRequest = Notification.Name("kUnauthorizedRequest")
}
