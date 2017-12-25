//
//  URLSessionType.swift
//  Stargazers
//
//  Created by Matteo Crespi on 25/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Foundation

protocol URLSessionDataTaskType {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskType {}

protocol URLSessionType {
    @discardableResult
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) -> URLSessionDataTaskType
}

extension URLSession: URLSessionType {
    @discardableResult
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) -> URLSessionDataTaskType {
        return dataTask(with: url, completionHandler: completionHandler) as URLSessionDataTask
    }
}
