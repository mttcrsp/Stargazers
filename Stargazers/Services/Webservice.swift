//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Foundation

struct Webservice {
    
    struct Request<Value> {
        let url: URL
        let decode: (Data) throws -> Value
    }
    
    let session: URLSessionType
    let callbackQueue: DispatchQueue
    
    init(session: URLSessionType = URLSession.shared, callbackQueue: DispatchQueue = .main) {
        self.session = session
        self.callbackQueue = callbackQueue
    }
    
    @discardableResult
    func load<Value>(_ request: Request<Value>, completion: @escaping (Result<Value, Error>) -> Void) -> URLSessionDataTaskType {
        let task = session.dataTask(with: request.url) { data, _, error in
            guard let data = data else {
                return self.onCallbackQueue { completion(error?.isNoInternet == true ? .failure(.noInternet) : .failure(.networking)) }
            }
            
            do {
                let value = try request.decode(data)
                self.onCallbackQueue { completion(.success(value)) }
            } catch {
                self.onCallbackQueue { completion(.failure(.networking)) }
            }
        }
        
        task.resume()
        return task
    }
    
    func onCallbackQueue(_ block: @escaping () -> Void) {
        callbackQueue.async(execute: block)
    }
}

extension Webservice.Request where Value: Codable {
    init(url: URL) {
        self.init(url: url, decode: { data in try JSONDecoder().decode(Value.self, from: data) })
    }
}

extension Error {
    static var networking: Error {
        let errorDescription = NSLocalizedString("Network error", comment: "alert title")
        let failureReason = NSLocalizedString("Something went wrong while communicating with our servers.", comment: "alert message")
        let recoverySuggestion = NSLocalizedString("Please, try again later.", comment: "alert message")
        return Error(errorDescription: errorDescription, failureReason: failureReason, recoverySuggestion: recoverySuggestion)
    }
    
    static var noInternet: Error {
        let errorDescription = NSLocalizedString("No Internet", comment: "alert title")
        let failureReason = NSLocalizedString("Seems like you are currently offline.", comment: "alert message")
        let recoverySuggestion = NSLocalizedString("Check your internet connection, then try again.", comment: "alert message")
        return Error(errorDescription: errorDescription, failureReason: failureReason, recoverySuggestion: recoverySuggestion)
    }
}
