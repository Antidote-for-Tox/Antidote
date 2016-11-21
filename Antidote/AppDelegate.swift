// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var coordinator: AppCoordinator!
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame:UIScreen.main.bounds)

        if ProcessInfo.processInfo.arguments.contains("UI_TESTING") {
            // Speeding up animations for UI tests.
            window!.layer.speed = 1000
        }

        configureLoggingStuff()

        coordinator = AppCoordinator(window: window!)
        coordinator.startWithOptions(nil)

        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
            coordinator.handleLocalNotification(notification)
        }

        window?.backgroundColor = UIColor.white
        window?.makeKeyAndVisible()

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        backgroundTask = UIApplication.shared.beginBackgroundTask (expirationHandler: { [unowned self] in
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskInvalid
        })
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        coordinator.handleLocalNotification(notification)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        coordinator.handleInboxURL(url)

        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        coordinator.handleInboxURL(url)

        return true
    }
}

private extension AppDelegate {
    func configureLoggingStuff() {
        DDLog.add(DDASLLogger.sharedInstance())
        DDLog.add(DDTTYLogger.sharedInstance())
    }
}
