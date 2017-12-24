//
//  Created by Matteo Crespi on 24/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

@testable
import Stargazers
import XCTest

class GitHubAPIClientRequestsBuilderTests: XCTestCase {
    
    let subject = GitHubAPIClient.RequestBuilder()
    
    func testUsers() {
        // GIVEN: a valid query
        let query = "Subito-it"
        // WHEN: asked to build a request from it
        let request = subject.users(for: query)
        // THEN: it correctly produces the appropriate URL
        XCTAssertEqual(request?.url, "https://api.github.com/search/users?q=Subito-it")
    }
    
    func testRepositories() {
        // GIVEN: a valid input for a repositories request
        let user: User = .subito, page = 4, perPage = 50
        // WHEN: asked to build a request from it
        let request = subject.repositories(for: user, page: page, perPage: perPage)
        // THEN: it correctly produces the appropriate URL
        XCTAssertEqual(request?.url, "https://api.github.com/users/Subito-it/repos?page=4&per_page=50")
    }
    
    func testStargazers() {
        // GIVEN: a valid input for a stargazers request
        let repository: Repository = .sbtUITestTunnel, page = 1, perPage = 100
        // WHEN: asked to build a request from it
        let request = subject.stargazers(for: repository, page: page, perPage: perPage)
        // THEN: it correctly produces the appropriate URL
        XCTAssertEqual(request?.url, "https://api.github.com/repos/Subito-it/SBTUITestTunnel/stargazers?page=1&per_page=100")
    }
    
    func testInvalidPageCount() {
        // GIVEN: an input that requires the page at index 0
        let user: User = .subito, page = 0, perPage = 50
        // WHEN: asked to build a request from it
        let request = subject.repositories(for: user, page: page, perPage: perPage)
        // THEN: it does not produce a request from it
        XCTAssertNil(request)
    }
    
    func testPerPageCount() {
        // GIVEN: an input that requires more than 100 results per page
        let repository: Repository = .sbtUITestTunnel, page = 1, perPage = 110
        // WHEN: asked to build a request from it
        let request = subject.stargazers(for: repository, page: page, perPage: perPage)
        // THEN: it does not produce a request from it
        XCTAssertNil(request)
    }
}
