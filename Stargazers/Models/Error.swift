//
//  Created by Matteo Crespi on 25/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Foundation

struct Error: LocalizedError, Equatable {
    
    let errorDescription: String
    let failureReason: String
    let recoverySuggestion: String
    
    static func ==(lhs: Error, rhs: Error) -> Bool {
        return (
            lhs.failureReason == rhs.failureReason &&
                lhs.errorDescription == rhs.errorDescription &&
                lhs.recoverySuggestion == rhs.recoverySuggestion
        )
    }
}
