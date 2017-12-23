//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Foundation

enum Result<Value, Error: LocalizedError> {
    case success(Value)
    case failure(Error)
}
