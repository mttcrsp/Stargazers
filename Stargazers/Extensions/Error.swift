//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import Foundation

extension Error {
    var isNoInternet: Bool {
        return (self as? URLError)?.code == .notConnectedToInternet
    }
}
