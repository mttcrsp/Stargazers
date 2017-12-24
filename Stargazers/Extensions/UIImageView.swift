//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

extension UIImageView {
    func configure(with avatarURL: URL, size: CGSize) {
        image = UIImage.withSolidColor(.blue, size: size)
        layer.cornerRadius = 2
        layer.masksToBounds = true
    }
}
