//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

final class RepositoryTableViewCell: UITableViewCell {
    func configure(with repository: Repository) {
        textLabel?.text = repository.name
        detailTextLabel?.text = "\(repository.stargazersCount) ✨"
    }
}
