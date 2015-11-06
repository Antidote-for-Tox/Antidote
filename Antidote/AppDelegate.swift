//
//  AppDelegate.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: CoordinatorProtocol?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame:UIScreen.mainScreen().bounds)

        configureLoggingStuff()

        coordinator = AppCoordinator(window: window!)
        coordinator?.start()

        window?.backgroundColor = UIColor.whiteColor()
        window?.makeKeyAndVisible()

        return true
    }

    func configureLoggingStuff() {
        DDLog.addLogger(DDASLLogger.sharedInstance())
        DDLog.addLogger(DDTTYLogger.sharedInstance())
    }
}
