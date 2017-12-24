//
//  Data.swift
//  StargazersTests
//
//  Created by Matteo Crespi on 25/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

@testable
import Stargazers
import XCTest

extension User {
    static var subito: User {
        return User(login: "Subito-it", avatarURL: "https://avatars0.githubusercontent.com/u/5539787?v=4", repositoriesURL: "https://api.github.com/users/Subito-it/repos")
    }
}

extension Repository {
    static var sbtUITestTunnel: Repository {
        return Repository(name: "SBTUITestTunnel", stargazersURL: "https://api.github.com/repos/Subito-it/SBTUITestTunnel/stargazers", stargazersCount: 73)
    }
}

extension Data {
    init(forResource resource: String, withExtension extension: String) {
        let bundle = Bundle(for: RepositoryTests.self)
        let url = bundle.url(forResource: resource, withExtension: `extension`)!
        try! self.init(contentsOf: url)
    }
}
