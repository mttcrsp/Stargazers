//
//  Created by Matteo Crespi on 24/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

extension UITableView {
    var visibleIndexPathsCount: Int {
        return indexPathsForVisibleRows?.count ?? 0
    }
}
