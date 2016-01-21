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
    var coordinator: AppCoordinator!
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame:UIScreen.mainScreen().bounds)

        configureLoggingStuff()

        coordinator = AppCoordinator(window: window!)
        coordinator.start()

        if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            coordinator.handleLocalNotification(notification)
        }

        window?.backgroundColor = UIColor.whiteColor()
        window?.makeKeyAndVisible()

        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { [unowned self] in
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskInvalid
        }
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        coordinator.handleLocalNotification(notification)
    }
}

private extension AppDelegate {
    func configureLoggingStuff() {
        DDLog.addLogger(DDASLLogger.sharedInstance())
        DDLog.addLogger(DDTTYLogger.sharedInstance())
    }
}
