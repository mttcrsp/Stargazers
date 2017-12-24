//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

final class UserTableViewCell: UITableViewCell {
    
    func configure(with user: User) {
        imageView?.configure(with: user.avatarURL, size: avatarSize)
        textLabel?.text = user.login
    }
    
    private var avatarSize: CGSize {
        let padding: CGFloat = 8
        let height = bounds.height - (padding * 2)
        return CGSize(width: height, height: height)
    }
}
