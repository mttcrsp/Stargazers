//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

final class UserTableViewCell: UITableViewCell {
    func configure(with user: User) {
        textLabel?.text = user.login
        imageView?.setImage(from: user.avatarURL, placeholder: nil)
    }
}
