//
//  RunningCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

protocol RunningCoordinatorDelegate: class {
    func runningCoordinatorDidLogout(coordinator: RunningCoordinator)
    func runningCoordinatorDeleteProfile(coordinator: RunningCoordinator)
    func runningCoordinatorRecreateCoordinatorsStack(coordinator: RunningCoordinator, options: CoordinatorOptions)
}

private struct Options {
    static let ToShowKey = "ToShowKey"
    static let StoredOptions = "StoredOptions"

    enum Coordinator {
        case None
        case Settings
    }
}

private struct IpadObjects {
    let splitController: UISplitViewController

    let primaryController: PrimaryIpadController
}

private struct IphoneObjects {
    enum TabCoordinator: Int {
        case Friends = 0
        case Chats = 1
        case Settings = 2
        case Profile = 3

        static func allValues() -> [TabCoordinator]{
            return [Friends, Chats, Settings, Profile]
        }
    }

    let chatsCoordinator: ChatsTabCoordinator

    let tabBarController: TabBarController

    let friendsTabBarItem: TabBarBadgeItem
    let chatsTabBarItem: TabBarBadgeItem
    let profileTabBarItem: TabBarProfileItem
}

class RunningCoordinator: NSObject {
    weak var delegate: RunningCoordinatorDelegate?

    private let theme: Theme
    private let window: UIWindow

    // Tox manager is stored here
    private let toxManager: OCTManager

    private let friendsCoordinator: FriendsTabCoordinator
    private let settingsCoordinator: SettingsTabCoordinator
    private let profileCoordinator: ProfileTabCoordinator

    private let notificationCoordinator: NotificationCoordinator
    private let automationCoordinator: AutomationCoordinator
    private var callCoordinator: CallCoordinator!

    /**
        One of following properties will be non-empty, depending on running device.
     */
    private var iPhone: IphoneObjects!
    private var iPad: IpadObjects!

    init(theme: Theme, window: UIWindow, toxManager: OCTManager) {
        self.theme = theme
        self.window = window
        self.toxManager = toxManager

        self.friendsCoordinator = FriendsTabCoordinator(theme: theme, toxManager: toxManager)
        self.settingsCoordinator = SettingsTabCoordinator(theme: theme)
        self.profileCoordinator = ProfileTabCoordinator(theme: theme, toxManager: toxManager)
        self.notificationCoordinator = NotificationCoordinator(theme: theme, submanagerObjects: toxManager.objects)
        self.automationCoordinator = AutomationCoordinator(submanagerObjects: toxManager.objects, submanagerFiles: toxManager.files)

        super.init()

        // order matters
        createDeviceSpecificObjects()
        createCallCoordinator()

        toxManager.user.delegate = self

        friendsCoordinator.delegate = self
        settingsCoordinator.delegate = self
        profileCoordinator.delegate = self
        notificationCoordinator.delegate = self
    }
}

extension RunningCoordinator: TopCoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
        switch InterfaceIdiom.current() {
            case .iPhone:
                iPhone.tabBarController.selectedIndex = IphoneObjects.TabCoordinator.Chats.rawValue
                iPhone.chatsCoordinator.startWithOptions(nil)

                window.rootViewController = iPhone.tabBarController
            case .iPad:
                primaryIpadControllerShowFriends(iPad.primaryController)

                window.rootViewController = iPad.splitController
        }

        var settingsOptions: CoordinatorOptions?

        let toShow = options?[Options.ToShowKey] as? Options.Coordinator ?? .None
        switch toShow {
            case .None:
                break
            case .Settings:
                settingsOptions = options?[Options.StoredOptions] as? CoordinatorOptions
        }

        friendsCoordinator.startWithOptions(nil)
        settingsCoordinator.startWithOptions(settingsOptions)
        profileCoordinator.startWithOptions(nil)
        notificationCoordinator.startWithOptions(nil)
        automationCoordinator.startWithOptions(nil)
        callCoordinator.startWithOptions(nil)

        toxManager.bootstrap.addPredefinedNodes()
        toxManager.bootstrap.bootstrap()

        updateUserAvatar()
        updateUserName()

        switch toShow {
            case .None:
                break
            case .Settings:
                showSettings()
        }
    }

    func handleLocalNotification(notification: UILocalNotification) {
        notificationCoordinator.handleLocalNotification(notification)
    }

    func handleOpenURL(openURL: OpenURL, resultBlock: HandleURLResult -> Void) {
        guard openURL.url.isToxURL() else {
            resultBlock(.Success)
            return
        }

        guard let fileName = openURL.url.lastPathComponent else {
            resultBlock(.Success)
            return
        }

        let alert = UIAlertController(title: nil, message: fileName, preferredStyle: .ActionSheet)

        alert.addAction(UIAlertAction(title: String(localized: "create_profile"), style: .Default) { [unowned self] _ -> Void in
            let modifiedURL = OpenURL(url: openURL.url, askUser: false)

            resultBlock(.Failure(openURL: modifiedURL))
            self.logout()
        })

        alert.addAction(UIAlertAction(title: String(localized: "alert_cancel"), style: .Cancel) { _ -> Void in
            resultBlock(.Success)
        })

        switch InterfaceIdiom.current() {
            case .iPhone:
                iPhone.tabBarController.presentViewController(alert, animated: true, completion: nil)
            case .iPad:
                iPad.splitController.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

extension RunningCoordinator: OCTSubmanagerUserDelegate {
    func submanagerUser(submanager: OCTSubmanagerUser!, connectionStatusUpdate connectionStatus: OCTToxConnectionStatus) {
        updateUserStatusView()

        let show = (connectionStatus == .None)
        notificationCoordinator.toggleConnectingView(show: show, animated: true)
    }
}

extension RunningCoordinator: NotificationCoordinatorDelegate {
    func notificationCoordinator(coordinator: NotificationCoordinator, showChat chat: OCTChat) {
        showChat(chat)
    }

    func notificationCoordinatorShowFriendRequest(coordinator: NotificationCoordinator, showRequest request: OCTFriendRequest) {
        showFriendRequest(request)
    }

    func notificationCoordinatorAnswerIncomingCall(coordinator: NotificationCoordinator, userInfo: String) {
        callCoordinator.answerIncomingCallWithUserInfo(userInfo)
    }

    func notificationCoordinator(coordinator: NotificationCoordinator, updateFriendsBadge badge: Int) {
        let text: String? = (badge > 0) ? "\(badge)" : nil

        switch InterfaceIdiom.current() {
            case .iPhone:
                iPhone.friendsTabBarItem.badgeText = text
            case .iPad:
                iPad.primaryController.friendsBadgeText = text
                break
        }
    }

    func notificationCoordinator(coordinator: NotificationCoordinator, updateChatsBadge badge: Int) {
        switch InterfaceIdiom.current() {
            case .iPhone:
                iPhone.chatsTabBarItem.badgeText = (badge > 0) ? "\(badge)" : nil
            case .iPad:
                // none
                break
        }
    }
}

extension RunningCoordinator: CallCoordinatorDelegate {
    func callCoordinator(coordinator: CallCoordinator, notifyAboutBackgroundCallFrom caller: String, userInfo: String) {
        notificationCoordinator.showCallNotificationWithCaller(caller, userInfo: userInfo)
    }
}

extension RunningCoordinator: FriendsTabCoordinatorDelegate {
    func friendsTabCoordinatorOpenChat(coordinator: FriendsTabCoordinator, forFriend friend: OCTFriend) {
        let chat = toxManager.chats.getOrCreateChatWithFriend(friend)

        showChat(chat)
    }

    func friendsTabCoordinatorCall(coordinator: FriendsTabCoordinator, toFriend friend: OCTFriend) {
        let chat = toxManager.chats.getOrCreateChatWithFriend(friend)

        callCoordinator.callToChat(chat, enableVideo: false)
    }

    func friendsTabCoordinatorVideoCall(coordinator: FriendsTabCoordinator, toFriend friend: OCTFriend) {
        let chat = toxManager.chats.getOrCreateChatWithFriend(friend)

        callCoordinator.callToChat(chat, enableVideo: true)
    }
}

extension RunningCoordinator: ChatsTabCoordinatorDelegate {
    func chatsTabCoordinator(coordinator: ChatsTabCoordinator, chatWillAppear chat: OCTChat) {
        notificationCoordinator.banNotificationsForChat(chat)
    }

    func chatsTabCoordinator(coordinator: ChatsTabCoordinator, chatWillDisapper chat: OCTChat) {
        notificationCoordinator.unbanNotificationsForChat(chat)
    }

    func chatsTabCoordinator(coordinator: ChatsTabCoordinator, callToChat chat: OCTChat, enableVideo: Bool) {
        callCoordinator.callToChat(chat, enableVideo: enableVideo)
    }
}

extension RunningCoordinator: SettingsTabCoordinatorDelegate {
    func settingsTabCoordinatorRecreateCoordinatorsStack(coordinator: SettingsTabCoordinator, options settingsOptions: CoordinatorOptions) {
        delegate?.runningCoordinatorRecreateCoordinatorsStack(self, options: [
            Options.ToShowKey: Options.Coordinator.Settings,
            Options.StoredOptions: settingsOptions,
        ])
    }
}

extension RunningCoordinator: ProfileTabCoordinatorDelegate {
    func profileTabCoordinatorDelegateLogout(coordinator: ProfileTabCoordinator) {
        logout()
    }

    func profileTabCoordinatorDelegateDeleteProfile(coordinator: ProfileTabCoordinator) {
        UserDefaultsManager().isUserLoggedIn = false

        delegate?.runningCoordinatorDeleteProfile(self)
    }

    func profileTabCoordinatorDelegateDidChangeUserStatus(coordinator: ProfileTabCoordinator) {
        updateUserStatusView()
    }

    func profileTabCoordinatorDelegateDidChangeAvatar(coordinator: ProfileTabCoordinator) {
        updateUserAvatar()
    }

    func profileTabCoordinatorDelegateDidChangeUserName(coordinator: ProfileTabCoordinator) {
        updateUserName()
    }
}

extension RunningCoordinator: PrimaryIpadControllerDelegate {
    func primaryIpadController(controller: PrimaryIpadController, didSelectChat chat: OCTChat) {
        showChat(chat)
    }

    func primaryIpadControllerShowFriends(controller: PrimaryIpadController) {
        iPad.splitController.showDetailViewController(friendsCoordinator.navigationController, sender: nil)
    }

    func primaryIpadControllerShowSettings(controller: PrimaryIpadController) {
        iPad.splitController.showDetailViewController(settingsCoordinator.navigationController, sender: nil)
    }

    func primaryIpadControllerShowProfile(controller: PrimaryIpadController) {
        iPad.splitController.showDetailViewController(profileCoordinator.navigationController, sender: nil)
    }
}

extension RunningCoordinator: ChatPrivateControllerDelegate {
    func chatPrivateControllerWillAppear(controller: ChatPrivateController) {
        notificationCoordinator.banNotificationsForChat(controller.chat)
    }

    func chatPrivateControllerWillDisappear(controller: ChatPrivateController) {
        notificationCoordinator.unbanNotificationsForChat(controller.chat)
    }

    func chatPrivateControllerCallToChat(controller: ChatPrivateController, enableVideo: Bool) {
        callCoordinator.callToChat(controller.chat, enableVideo: enableVideo)
    }

    func chatPrivateControllerShowQuickLookController(
            controller: ChatPrivateController,
            dataSource: QuickLookPreviewControllerDataSource,
            selectedIndex: Int)
    {
        let controller = QuickLookPreviewController()
        controller.dataSource = dataSource
        controller.dataSourceStorage = dataSource
        controller.currentPreviewItemIndex = selectedIndex

        iPad.splitController.presentViewController(controller, animated: true, completion: nil)
    }
}

private extension RunningCoordinator {
    func createDeviceSpecificObjects() {
        switch InterfaceIdiom.current() {
            case .iPhone:
                let chatsCoordinator = ChatsTabCoordinator(theme: theme, submanagerObjects: toxManager.objects, submanagerChats: toxManager.chats, submanagerFiles: toxManager.files)
                chatsCoordinator.delegate = self

                let tabBarControllers = IphoneObjects.TabCoordinator.allValues().map { object -> UINavigationController in
                    switch object {
                        case .Friends:
                            return friendsCoordinator.navigationController
                        case .Chats:
                            return chatsCoordinator.navigationController
                        case .Settings:
                            return settingsCoordinator.navigationController
                        case .Profile:
                            return profileCoordinator.navigationController
                    }
                }

                let tabBarItems = createTabBarItems()

                let friendsTabBarItem = tabBarItems[IphoneObjects.TabCoordinator.Friends.rawValue] as! TabBarBadgeItem
                let chatsTabBarItem = tabBarItems[IphoneObjects.TabCoordinator.Chats.rawValue] as! TabBarBadgeItem
                let profileTabBarItem = tabBarItems[IphoneObjects.TabCoordinator.Profile.rawValue] as! TabBarProfileItem

                let tabBarController = TabBarController(theme: theme, controllers: tabBarControllers, tabBarItems: tabBarItems)

                iPhone = IphoneObjects(
                        chatsCoordinator: chatsCoordinator,
                        tabBarController: tabBarController,
                        friendsTabBarItem: friendsTabBarItem,
                        chatsTabBarItem: chatsTabBarItem,
                        profileTabBarItem: profileTabBarItem)

            case .iPad:
                let splitController = UISplitViewController()
                splitController.preferredDisplayMode = .AllVisible

                let primaryController = PrimaryIpadController(theme: theme, submanagerChats: toxManager.chats, submanagerObjects: toxManager.objects)
                primaryController.delegate = self
                splitController.viewControllers = [UINavigationController(rootViewController: primaryController)]

                iPad = IpadObjects(splitController: splitController, primaryController: primaryController)
        }
    }

    func createCallCoordinator() {
        let presentingController: UIViewController

        switch InterfaceIdiom.current() {
            case .iPhone:
                presentingController = iPhone.tabBarController
            case .iPad:
                presentingController = iPad.splitController
        }

        self.callCoordinator = CallCoordinator(
                theme: theme,
                presentingController: presentingController,
                submanagerCalls: toxManager.calls,
                submanagerObjects: toxManager.objects)
        callCoordinator.delegate = self
    }

    func createTabBarItems() -> [TabBarAbstractItem] {
        return IphoneObjects.TabCoordinator.allValues().map {
            switch $0 {
                case .Friends:
                    let item = TabBarBadgeItem(theme: theme)
                    item.image = UIImage(named: "tab-bar-friends")
                    item.text = String(localized: "contacts_title")
                    return item
                case .Chats:
                    let item = TabBarBadgeItem(theme: theme)
                    item.image = UIImage(named: "tab-bar-chats")
                    item.text = String(localized: "chats_title")
                    return item
                case .Settings:
                    let item = TabBarBadgeItem(theme: theme)
                    item.image = UIImage(named: "tab-bar-settings")
                    item.text = String(localized: "settings_title")
                    return item
                case .Profile:
                    return TabBarProfileItem(theme: theme)
            }
        }
    }

    func showFriendRequest(request: OCTFriendRequest) {
        switch InterfaceIdiom.current() {
            case .iPhone:
                iPhone.tabBarController.selectedIndex = IphoneObjects.TabCoordinator.Friends.rawValue
            case .iPad:
                primaryIpadControllerShowFriends(iPad.primaryController)
        }

        friendsCoordinator.showRequest(request, animated: false)
    }

    func showChat(chat: OCTChat) {
        switch InterfaceIdiom.current() {
            case .iPhone:
                iPhone.tabBarController.selectedIndex = IphoneObjects.TabCoordinator.Chats.rawValue
                iPhone.chatsCoordinator.showChat(chat, animated: false)
            case .iPad:
                if let chatVC = iPadDetailController() as? ChatPrivateController {
                    if chatVC.chat == chat {
                        // controller is already visible
                        return
                    }
                }

                let controller = ChatPrivateController(
                        theme: theme,
                        chat: chat,
                        submanagerChats: toxManager.chats,
                        submanagerObjects: toxManager.objects,
                        submanagerFiles: toxManager.files,
                        delegate: self)
                let navigation = UINavigationController(rootViewController: controller)

                iPad.splitController.showDetailViewController(navigation, sender: nil)
        }
    }

    func showSettings() {
        switch InterfaceIdiom.current() {
            case .iPhone:
                iPhone.tabBarController.selectedIndex = IphoneObjects.TabCoordinator.Settings.rawValue
            case .iPad:
                primaryIpadControllerShowFriends(iPad.primaryController)
        }
    }

    func updateUserStatusView() {
        let status = UserStatus(connectionStatus: toxManager.user.connectionStatus, userStatus: toxManager.user.userStatus)

        switch InterfaceIdiom.current() {
            case .iPhone:
                iPhone.profileTabBarItem.userStatus = status
            case .iPad:
                iPad.primaryController.userStatus = status
        }
    }

    func updateUserAvatar() {
        var avatar: UIImage?

        if let avatarData = toxManager.user.userAvatar() {
            avatar = UIImage(data: avatarData)
        }

        switch InterfaceIdiom.current() {
            case .iPhone:
                iPhone.profileTabBarItem.userImage = avatar
            case .iPad:
                iPad.primaryController.userAvatar = avatar
        }
    }

    func updateUserName() {
        switch InterfaceIdiom.current() {
            case .iPhone:
                // nop
                break
            case .iPad:
                iPad.primaryController.userName = toxManager.user.userName()
        }
    }

    func iPadDetailController() -> UIViewController? {
        guard iPad.splitController.viewControllers.count == 2 else {
            return nil
        }

        let controller = iPad.splitController.viewControllers[1]

        if let navigation = controller as? UINavigationController {
            return navigation.topViewController
        }

        return controller
    }

    func logout() {
        UserDefaultsManager().isUserLoggedIn = false

        delegate?.runningCoordinatorDidLogout(self)
    }
}
