//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Foundation

struct Repository: Codable {
    
    enum CodingKeys: String, CodingKey {
        case name
        case stargazersURL = "stargazers_url"
        case stargazersCount = "stargazers_count"
    }
    
    let name: String
    let stargazersURL: URL
    let stargazersCount: Int
}

extension Repository {
    var hasStargazers: Bool { return stargazersCount > 0 }
}

extension Repository: Equatable {
    static func ==(lhs: Repository, rhs: Repository) -> Bool {
        return lhs.stargazersURL == rhs.stargazersURL
    }
}
