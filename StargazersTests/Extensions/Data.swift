//
//  Data.swift
//  StargazersTests
//
//  Created by Matteo Crespi on 25/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Foundation

extension Data {
    init(forResource resource: String, withExtension extension: String) {
        let bundle = Bundle(for: RepositoryTests.self)
        let url = bundle.url(forResource: resource, withExtension: `extension`)!
        try! self.init(contentsOf: url)
    }
}
