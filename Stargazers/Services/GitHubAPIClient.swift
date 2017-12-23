//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Foundation

final class GitHubAPIClient {
    
    enum Error: LocalizedError {
        case invalidQuery
        case networking
        case noInternet
        
        var errorDescription: String? {
            switch self {
            case .invalidQuery: return NSLocalizedString("Invalid query", comment: "alert title")
            case .networking: return NSLocalizedString("Network error", comment: "alert title")
            case .noInternet: return NSLocalizedString("No Internet", comment: "alert title")
            }
        }
        
        var failureReason: String? {
            switch self {
            case .invalidQuery: return NSLocalizedString("No search could be performed based on the query you entered.", comment: "alert message")
            case .networking: return NSLocalizedString("Something went wrong while communicating with the GitHub servers.", comment: "alert message")
            case .noInternet: return NSLocalizedString("Seems like you are currently offline.", comment: "alert message")
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .invalidQuery: return NSLocalizedString("Try removing special characters and performing another search.", comment: "alert message")
            case .networking, .noInternet: return NSLocalizedString("Check your internet connection, then try again.", comment: "alert message")
            }
        }
    }
    
    struct SearchUserResponse: Codable {
        let items: [User]
    }
    
    // WARNING: The GitHub API supports a maximum of 100 results per page (https://developer.github.com/v3/#pagination)
    var stargazersPerPage: UInt = 100 { didSet { assert(stargazersPerPage > 0 && stargazersPerPage <= 100) } }
    var repositoriesPerPage: UInt = 50  { didSet { assert(repositoriesPerPage > 0 && repositoriesPerPage <= 100) } }
    
    private let baseURL: URL = "https://api.github.com"
    private let callbackQueue: DispatchQueue
    private let session: URLSession
    
    init(session: URLSession = .shared, callbackQueue: DispatchQueue = .main) {
        self.session = session
        self.callbackQueue = callbackQueue
    }
    
    func users(for query: String, completion: @escaping (Result<SearchUserResponse, Error>) -> Void) {
        let searchURL = baseURL.appendingPathComponent("search")
        let searchUserURL = searchURL.appendingPathComponent("users")
        let url = searchUserURL.appendingQueryItem(name: "q", value: query)
        performRequest(with: url, completion: completion)
    }
    
    func repositories(for user: User, page: UInt = 0, completion: @escaping (Result<[Repository], Error>) -> Void) {
        let url = user.repositoriesURL
            .appendingQueryItem(name: "page", value: page.description)?
            .appendingQueryItem(name: "per_page", value: "\(repositoriesPerPage)")
        performRequest(with: url, completion: completion)
    }
    
    func stargazers(for repository: Repository, page: UInt = 0, completion: @escaping (Result<[User], Error>) -> Void) {
        let url = repository.stargazersURL
            .appendingQueryItem(name: "page", value: page.description)?
            .appendingQueryItem(name: "per_page", value: "\(stargazersPerPage)")
        performRequest(with: url, completion: completion)
    }
    
    private func performRequest<T: Codable>(with url: URL?, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url else {
            return onCallbackQueue { completion(.failure(.networking)) }
        }
        
        session.dataTask(with: url) { [weak self] data, _, error in
            guard let `self` = self else { return }
            
            let result: Result<T, Error>
            
            switch (data, error) {
            case (let data?, nil):
                do {
                    let value = try JSONDecoder().decode(T.self, from: data)
                    result = .success(value)
                } catch {
                    result = .failure(.networking)
                }
            case (nil, let error?) where error.isNoInternet:
                result = .failure(.noInternet)
            default:
                result = .failure(.networking)
            }
            
            self.onCallbackQueue { completion(result) }
        }.resume()
    }
    
    private func onCallbackQueue(_ block: @escaping () -> Void) {
        callbackQueue.async(execute: block)
    }
}
