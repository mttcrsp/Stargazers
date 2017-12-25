//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit
import PINRemoteImage

final class UserTableViewCell: UITableViewCell {
    
    private let loginLabel = UILabel()
    private let avatarImageView = UIImageView()
    
    private var spacing: CGFloat { return 8 }
    private var padding: CGFloat { return 16 }
    private var avatarSize: CGSize { return CGSize(width: 44, height: 44) }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(loginLabel)
        avatarImageView.layer.cornerRadius = 2
        avatarImageView.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageView.frame.size = avatarSize
        avatarImageView.frame.origin.x = padding
        avatarImageView.center.y = contentView.frame.midY
        
        let targetWidth = (contentView.frame.width - padding) - avatarImageView.frame.maxX - (spacing * 2)
        let targetSize = CGSize(width: targetWidth, height: contentView.frame.height)
        loginLabel.frame.size = loginLabel.sizeThatFits(targetSize)
        loginLabel.frame.origin.x = avatarImageView.frame.maxX + spacing
        loginLabel.center.y = contentView.frame.midY
    }
    
    func configure(with user: User) {
        loginLabel.text = user.login
        let gitHubSize = Int(avatarSize.width * UIScreen.main.scale)
        let gitHubURL = user.avatarURL.appendingQueryItem(name: "size", value: "\(gitHubSize)")
        avatarImageView.pin_setImage(from: gitHubURL, placeholderImage: .withSolidColor(.lightGray, size: avatarSize))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loginLabel.text = nil
        avatarImageView.image = nil
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return CGSize(width: targetSize.width, height: 70)
    }
}
