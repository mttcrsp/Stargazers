//
//  Created by Matteo Crespi on 26/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

final class MessageViewController: UIViewController {
    
    var message: String? {
        get { return messageLabel.text }
        set { messageLabel.text = newValue }
    }
    
    private let messageLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(messageLabel)
        
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .lightGray
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            messageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            messageLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            messageLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            messageLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        } else {
            let topConstraint = NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: messageLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: 0)
            let leadingConstraint = NSLayoutConstraint(item: messageLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leadingMargin, multiplier: 1, constant: 0)
            let trailingConstraint = NSLayoutConstraint(item: messageLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailingMargin, multiplier: 1, constant: 0)
            NSLayoutConstraint.activate([topConstraint, bottomConstraint, leadingConstraint, trailingConstraint])
        }
    }
}
