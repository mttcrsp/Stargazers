//
//  Created by Matteo Crespi on 25/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

@testable
import Stargazers
import XCTest

class UserTests: XCTestCase {

    var bundle: Bundle {
        return Bundle(for: UserTests.self)
    }
    
    func testDecodingFromGitHubAPI() {
        // GIVEN: a valid GitHub json API response for a User object
        let data = Data(forResource: "User", withExtension: "json")
        // WHEN: attempting to decoding of it
        let user = try? JSONDecoder().decode(User.self, from: data)
        // THEN: an appropriate User model is generated
        XCTAssertEqual(user?.login, "Subito-it")
        XCTAssertEqual(user?.avatarURL, "https://avatars0.githubusercontent.com/u/5539787?v=4")
        XCTAssertEqual(user?.repositoriesURL, "https://api.github.com/users/Subito-it/repos")
    }
}
