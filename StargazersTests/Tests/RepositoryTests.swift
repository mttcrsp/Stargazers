//
//  Created by Matteo Crespi on 25/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

@testable
import Stargazers
import XCTest

class RepositoryTests: XCTestCase {
    
    var bundle: Bundle {
        return Bundle(for: UserTests.self)
    }
    
    func testDecodingFromGitHubAPI() {
        // GIVEN: a valid GitHub json API response for a User object
        let data = Data(forResource: "Repository", withExtension: "json")
        // WHEN: attempting to decoding of it
        let repository = try? JSONDecoder().decode(Repository.self, from: data)
        // THEN: an appropriate Repository model is generated
        XCTAssertEqual(repository?.name, "SBTUITestTunnel")
        XCTAssertEqual(repository?.stargazersURL, "https://api.github.com/repos/Subito-it/SBTUITestTunnel/stargazers")
        XCTAssertEqual(repository?.stargazersCount, 73)
    }
}

