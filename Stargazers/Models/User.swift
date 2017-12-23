//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Foundation

struct User: Codable {
    
    enum Keys: String, CodingKey {
        case login
        case avatarURL = "avatar_url"
        case repositoriesURL = "repositories_url"
    }
    
    let login: String
    let avatarURL: URL
    let repositoriesURL: URL
}
