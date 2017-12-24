//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Foundation

struct GitHubAPIClient {
    
    struct RequestBuilder {
        
        private let baseURL: URL = "https://api.github.com"
        
        private struct SearchUserResponse: Codable {
            let items: [User]
        }
        
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
        
        // WARNING: The GitHub API supports a maximum of 100 results per page (https://developer.github.com/v3/#pagination)
        
        func repositories(for user: User, page: Int, perPage: Int) -> Webservice.Request<[Repository]>? {
            guard page >= 0, perPage > 0, perPage <= 100 else { return nil }
            
            guard let url = user.repositoriesURL
                .appendingQueryItem(name: "page", value: page.description)?
                .appendingQueryItem(name: "per_page", value: "\(perPage)") else {
                    return nil
            }
            
            return Webservice.Request(url: url)
        }
        
        func stargazers(for repository: Repository, page: Int, perPage: Int) -> Webservice.Request<[User]>? {
            guard page >= 0, perPage > 0, perPage <= 100 else { return nil }
            
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
    
    init(webservice: Webservice = Webservice(), callbackQueue: DispatchQueue = .main) {
        self.webservice = webservice
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
        guard let request = request else {
            return onCallbackQueue {
                completion(.failure(.invalidAPIRequest))
            }
        }
        
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
        let errorDescription = NSLocalizedString("Network error", comment: "alert title")
        let failureReason = NSLocalizedString("Something went wrong while communicating with our servers.", comment: "alert message")
        let recoverySuggestion = NSLocalizedString("Please, try again later.", comment: "alert message")
        return Error(errorDescription: errorDescription, failureReason: failureReason, recoverySuggestion: recoverySuggestion)
    }
}
