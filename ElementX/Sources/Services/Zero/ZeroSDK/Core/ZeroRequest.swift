import Foundation

/// The HTTP Method
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// This describes a request returning `A` values.
/// It contains both a `URLRequest` and a way to parse the response.
struct ZeroRequest<A> {
    /// The request for this endpoint.
    var urlRequest: URLRequest

    /// This is used to (try to) parse a response into an `A`.
    var parse: (Data) -> Result<A, ZError>

    /// Transforms the result.
    func map<B>(_ transform: @escaping (A) -> B) -> ZeroRequest<B> {
        ZeroRequest<B>(request: urlRequest) { data in
            parse(data).map(transform)
        }
    }

    /// Transforms and returns a new result type.
    func compactMap<B>(_ transform: @escaping (A) -> Result<B, ZError>) -> ZeroRequest<B> {
        ZeroRequest<B>(request: urlRequest) { data in
            parse(data).flatMap(transform)
        }
    }

    // MARK: - Initializer

    /// Create a new Request.
    init(_ method: HTTPMethod,
         host: URL,
         path: String,
         body: Data? = nil,
         headers: [String: String] = [:],
         timeOutInterval: TimeInterval = 60,
         query: [String: String] = [:],
         parse: @escaping (Data) -> Result<A, ZError>) {
        var requestUrl = URL(string: path, relativeTo: host)!

        if !query.isEmpty {
            var components = URLComponents(url: requestUrl, resolvingAgainstBaseURL: true)!
            components.queryItems = components.queryItems ?? []
            components.queryItems!.append(contentsOf: query.map { URLQueryItem(name: $0.0, value: $0.1) })
            requestUrl = components.url!
        }

        urlRequest = URLRequest(url: requestUrl, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeOutInterval)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        for (key, value) in headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body

        self.parse = parse
    }

    /// Creates a new Endpoint from a request.
    ///
    /// - Parameters:
    ///   - request: a URL request object that provides request-specific information.
    ///   - parse: The completion handler to call when the load request is complete.
    public init(request: URLRequest, parse: @escaping (Data) -> Result<A, ZError>) {
        urlRequest = request
        self.parse = parse
    }
}

/// This describes a request returning `A` values with an empty response.
extension ZeroRequest where A == Void {
    init(_ method: HTTPMethod = .get,
         host: URL,
         path: String,
         headers: [String: String] = [:],
         query: [String: String] = [:]) {
        self.init(method, host: host, path: path, headers: headers, query: query) { _ in
            .success(())
        }
    }

    init<B: Encodable>(_ method: HTTPMethod = .get,
                       host: URL,
                       path: String,
                       body: B? = nil,
                       headers: [String: String] = [:],
                       query: [String: String] = [:],
                       encoder: JSONEncoder = JSONEncoder()) {
        let requestBody = try! encoder.encode(body)
        self.init(method, host: host, path: path, body: requestBody, headers: headers, query: query) { _ in
            .success(())
        }
    }
}

/// This describes a request returning `A` values with a decodable response.
extension ZeroRequest where A: Decodable {
    init(json method: HTTPMethod = .get,
         host: URL,
         path: String,
         headers: [String: String] = [:],
         query: [String: String] = [:],
         decoder: JSONDecoder = JSONDecoder()) {
        self.init(method, host: host, path: path, headers: headers, query: query) { data in

            do {
                return try .success(decoder.decode(A.self, from: data))
            } catch let error as DecodingError {
                return .failure(.decodingError(error))
            } catch {
                return .failure(.invalidResponse)
            }
        }
    }

    init<B: Encodable>(json method: HTTPMethod = .get,
                       host: URL,
                       path: String,
                       body: B,
                       headers: [String: String] = [:],
                       query: [String: String] = [:],
                       decoder: JSONDecoder = JSONDecoder(),
                       encoder: JSONEncoder = JSONEncoder()) {
        let requestBody = try! encoder.encode(body)
        self.init(method, host: host, path: path, body: requestBody, headers: headers, query: query) { data in

            do {
                return try .success(decoder.decode(A.self, from: data))
            } catch let error as DecodingError {
                return .failure(.decodingError(error))
            } catch {
                return .failure(.invalidResponse)
            }
        }
    }
}

struct Future<A> {
    let start: (@escaping (Result<A, ZError>) -> Void) -> Void

    func map<B>(_ transform: @escaping (A) -> B) -> Future<B> {
        Future<B> { completion in
            start { value in
                switch value {
                case .success:
                    completion(value.map(transform))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }

    func flatMap<B>(_ transform: @escaping (A) -> Future<B>) -> Future<B> {
        Future<B> { completion in
            start { value in
                switch value {
                case let .success(obj):
                    transform(obj).start(completion)
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }

    func zip<B>(_ other: Future<B>) -> Future<(A?, B?)> {
        // swiftlint:disable identifier_name
        Future<(A?, B?)> { cb in
            var resultA: A?
            var resultB: B?
            let group = DispatchGroup()
            group.enter()
            start { result_a in
                resultA = try? result_a.get()
                group.leave()
            }
            group.enter()
            other.start { result_b in
                resultB = try? result_b.get()
                group.leave()
            }
            group.notify(queue: .global()) {
                cb(.success((resultA, resultB)))
            }
        }
        // swiftlint:enable identifier_name
    }
}
