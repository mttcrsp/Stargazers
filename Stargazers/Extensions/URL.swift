//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Foundation

extension URL: ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = UnicodeScalarLiteralType
    public typealias UnicodeScalarLiteralType = ExtendedGraphemeClusterLiteralType
    public typealias ExtendedGraphemeClusterLiteralType = String
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(unicodeScalarLiteral: value)
    }
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(extendedGraphemeClusterLiteral: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        precondition(URL(string: value as String) != nil, "The manually typed URL \(value) is an invalid URL.")
        self.init(string: value)!
    }
    
    func appendingQueryItem(name: String, value: String?) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        let previousItems = components?.queryItems ?? []
        let newItem = URLQueryItem(name: name, value: value)
        components?.queryItems = previousItems + [newItem]
        return components?.url
    }
}
