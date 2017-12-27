//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Foundation

/// A lightweight wrapper for the GitHub API endpoints needed by the app:
///  1. user search
///  2. repositories for user
///  4. stargazers for repository
struct GitHubAPIClient {
    
    /// According to the documentation, the GitHub API pagination mechanism:
    ///  1. supports a maximum of 100 results per page,
    ///  2. all paginated queries start at page 1.
    /// You can find out more at https://developer.github.com/v3/#pagination).
    struct RequestBuilder {
        
        private let baseURL: URL = "https://api.github.com"
        
        private struct SearchUserResponse: Codable {
            let items: [User]
        }
        
        /// https://developer.github.com/v3/search/#search-users
        func users(for query: String) -> Webservice.Request<[User]>? {
            guard let url = baseURL.appendingPathComponent("search")
                .appendingPathComponent("users")
                .appendingQueryItem(name: "q", value: query) else {
                    return nil
            }
            
            return Webservice.Request(url: url, decode: { data in
                try JSONDecoder().decode(SearchUserResponse.self, from: data).items
            })
        }
        
        func repositories(for user: User, page: Int, perPage: Int) -> Webservice.Request<[Repository]>? {
            guard page > 0, perPage > 0, perPage <= 100 else { return nil }
            
            guard let url = user.repositoriesURL
                .appendingQueryItem(name: "page", value: page.description)?
                .appendingQueryItem(name: "per_page", value: "\(perPage)") else {
                    return nil
            }
            
            return Webservice.Request(url: url)
        }
        
        /// https://developer.github.com/v3/activity/starring/#list-stargazers
        func stargazers(for repository: Repository, page: Int, perPage: Int) -> Webservice.Request<[User]>? {
            guard page > 0, perPage > 0, perPage <= 100 else { return nil }
            
            guard let url = repository.stargazersURL
                .appendingQueryItem(name: "page", value: page.description)?
                .appendingQueryItem(name: "per_page", value: "\(perPage)") else {
                    return nil
            }
            
            return Webservice.Request(url: url)
        }
    }
    
    private let callbackQueue: DispatchQueue
    private let webservice: Webservice
    
    init(session: URLSessionType = URLSession.shared, callbackQueue: DispatchQueue = .main) {
        self.webservice = Webservice(session: session)
        self.callbackQueue = callbackQueue
    }
    
    func users(for query: String, completion: @escaping (Result<[User], Error>) -> Void) {
        performRequest(RequestBuilder().users(for: query), completion: completion)
    }
    
    func repositories(for user: User, page: Int = 1, perPage: Int, completion: @escaping (Result<[Repository], Error>) -> Void) {
        performRequest(RequestBuilder().repositories(for: user, page: page, perPage: perPage), completion: completion)
    }
    
    func stargazers(for repository: Repository, page: Int = 1, perPage: Int, completion: @escaping (Result<[User], Error>) -> Void) {
        performRequest(RequestBuilder().stargazers(for: repository, page: page, perPage: perPage), completion: completion)
    }
    
    private func performRequest<Value>(_ request: Webservice.Request<Value>?, completion: @escaping (Result<Value, Error>) -> Void) {
        // If no valid request can be instantiated from the client input,
        // signal to the client that the request is malformed via an
        // `invalidAPIRequest` error.
        guard let request = request else {
            return onCallbackQueue {
                completion(.failure(.invalidAPIRequest))
            }
        }
        
        // Otherwise perform the request and dispatch the result back to the
        // client specified callback queue.
        webservice.load(request) { result in
            self.onCallbackQueue { completion(result) }
        }
    }
    
    private func onCallbackQueue(_ block: @escaping () -> Void) {
        callbackQueue.async(execute: block)
    }
}

extension Error {
    static var invalidAPIRequest: Error {
        let errorDescription = NSLocalizedString("Invalid query", comment: "alert title")
        let failureReason = NSLocalizedString("Something went wrong while communicating with the GitHub API.", comment: "alert message")
        let recoverySuggestion = NSLocalizedString("Check that your query does not contain any invalid characters, then retry.", comment: "alert message")
        return Error(errorDescription: errorDescription, failureReason: failureReason, recoverySuggestion: recoverySuggestion)
    }
}
