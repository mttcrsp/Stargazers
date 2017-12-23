//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var embeddedInNavigationController: UINavigationController {
        return UINavigationController(rootViewController: self)
    }
    
    func display(_ error: LocalizedError) {
        let errorDescription = error.errorDescription ?? NSLocalizedString("Ops!", comment: "default alert title for errors")
        let failureReason = error.failureReason ?? NSLocalizedString("An unknown error occurred.", comment: "default failure reason displayed in within alerts")
        let recoverySuggestion = error.recoverySuggestion ?? NSLocalizedString("Please try again later.", comment: "default recovery suggestion displayed in within alerts")
        let alertController = UIAlertController(title: errorDescription, message: "\(failureReason) \(recoverySuggestion)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "short generic action confirmation message"), style: .default))
        present(alertController, animated: true)
    }
}
