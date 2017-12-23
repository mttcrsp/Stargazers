//
//  Created by Matteo Crespi on 23/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let stargazersController = StargazersController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = stargazersController.initialViewController
        window?.makeKeyAndVisible()
        return true
    }
}
