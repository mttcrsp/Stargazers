//
//  URLSessionFake.swift
//  StargazersTests
//
//  Created by Matteo Crespi on 25/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

@testable
import Stargazers
import XCTest

struct URLSessionDataTaskFake: URLSessionDataTaskType {
    
    let completionHandler: (() -> Void)
    
    func resume() {
        DispatchQueue.global().async { self.completionHandler() }
    }
}

struct URLSessionFake: URLSessionType {
    
    let responses: [URL: (Data?, Swift.Error?)]
    
    @discardableResult
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) -> URLSessionDataTaskType {
        if let (data, error) = responses[url] {
            return URLSessionDataTaskFake(completionHandler: { completionHandler(data, nil, error) })
        } else {
            XCTFail()
            return URLSessionDataTaskFake(completionHandler: { completionHandler(nil, nil, nil) })
        }
    }
}
