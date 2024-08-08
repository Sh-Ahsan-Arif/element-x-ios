import Foundation

public extension ZeroSDK {
    func users(in networkId: String,
               offset: Int = 0,
               limit: Int = 100,
               completionHandler: @escaping (Result<[ZUser], ZError>) -> Void) {
        let items = ["limit": limit, "offset": offset]
        let jsonData = try! JSONSerialization.data(withJSONObject: items)
        let json = String(data: jsonData, encoding: .utf8)!

        let req = ZeroRequest<[ZUser]>(host: host,
                                       path: "/api/networks/\(networkId)/activeUsers",
                                       query: ["filter": json],
                                       decoder: zeroDecoder()).map {
            $0.sorted { $0.isOnline && !$1.isOnline } // online then offline users
        }

        perform(authorizedRequest: req, completion: completionHandler)
    }

    func searchUsers(searchString: String,
                     offset: Int = 0,
                     limit: Int = 100) async throws -> [ZMatrixSearchedUser] {
        try await withCheckedThrowingContinuation { continuation in
            let items = [
                "filter": searchString,
                "isMatrixEnabled": true,
                "limit": limit,
                "offset": offset
            ]
            let jsonData = try! JSONSerialization.data(withJSONObject: items)
            let json = String(data: jsonData, encoding: .utf8)!

            let req = ZeroRequest<[ZMatrixSearchedUser]>(host: host,
                                                         path: "/api/v2/users/searchInNetworksByName",
                                                         query: ["filter": json],
                                                         decoder: zeroDecoder())

            perform(authorizedRequest: req) { result in
                switch result {
                case let .success(users):
                    continuation.resume(returning: users)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchUsersFromMatrixIDs(matrixIds: [String]) async throws -> [ZMatrixUser] {
        try await withCheckedThrowingContinuation { continuation in
            let req = ZeroRequest<[ZMatrixUser]>(json: .post,
                                                 host: host,
                                                 path: "/matrix/users/zero",
                                                 body: ["matrixIds": matrixIds],
                                                 decoder: zeroDecoder())
            
            perform(authorizedRequest: req) { result in
                switch result {
                case let .success(users):
                    continuation.resume(returning: users)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func currentUser(completionHandler: @escaping (Result<ZCurrentUser, ZError>) -> Void) {
        let req = ZeroRequest<ZCurrentUser>(host: host,
                                            path: "/api/users/current")

        perform(authorizedRequest: req, completion: completionHandler)
    }
}
