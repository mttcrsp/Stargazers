//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Foundation

struct User: Codable {
    
    enum CodingKeys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
        case repositoriesURL = "repos_url"
    }
    
    let login: String
    let avatarURL: URL
    let repositoriesURL: URL
}

extension User: Equatable {
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.login == rhs.login
    }
}
