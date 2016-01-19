//
//  RunningCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import Cent

protocol RunningCoordinatorDelegate: class {
    func runningCoordinatorDidLogout(coordinator: RunningCoordinator)
}

private struct IpadObjects {
    let splitController: UISplitViewController

    let primaryController: PrimaryIpadController

    var friendsCoordinator: FriendsTabCoordinator?
    var settingsCoordinator: SettingsTabCoordinator?
    var profileCoordinator: ProfileTabCoordinator?

    init(splitController: UISplitViewController, primaryController: PrimaryIpadController) {
        self.splitController = splitController
        self.primaryController = primaryController

        self.friendsCoordinator = nil
        self.settingsCoordinator = nil
        self.profileCoordinator = nil
    }
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

    let tabCoordinators: [RunningNavigationCoordinator]

    let tabBarController: TabBarController
    let profileTabBarItem: TabBarProfileItem
}

class RunningCoordinator: NSObject {
    weak var delegate: RunningCoordinatorDelegate?

    private let theme: Theme
    private let window: UIWindow
    private let toxManager: OCTManager

    private let notificationCoordinator: NotificationCoordinator
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

        self.notificationCoordinator = NotificationCoordinator(theme: theme)

        super.init()

        // order matters
        createDeviceSpecificObjects()
        createCallCoordinator()

        toxManager.user.delegate = self
    }
}

extension RunningCoordinator: CoordinatorProtocol {
    func start() {
        switch InterfaceIdiom.current() {
            case .iPhone:
                iPhone.tabCoordinators.each{ $0.start() }
                iPhone.tabBarController.selectedIndex = IphoneObjects.TabCoordinator.Chats.rawValue

                window.rootViewController = iPhone.tabBarController
            case .iPad:
                window.rootViewController = iPad.splitController
        }

        callCoordinator.start()

        notificationCoordinator.toggleConnectingView(show: true, animated: false)

        toxManager.bootstrap.addPredefinedNodes()
        toxManager.bootstrap.bootstrap()
    }
}

extension RunningCoordinator: OCTSubmanagerUserDelegate {
    func submanagerUser(submanager: OCTSubmanagerUser!, connectionStatusUpdate connectionStatus: OCTToxConnectionStatus) {
        switch InterfaceIdiom.current() {
            case .iPhone:
                iPhone.profileTabBarItem.userStatus = UserStatus(connectionStatus: connectionStatus, userStatus: submanager.userStatus)
            case .iPad:
                // TODO
                break
        }

        let show = (connectionStatus == .None)
        notificationCoordinator.toggleConnectingView(show: show, animated: false)
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

extension RunningCoordinator: ProfileTabCoordinatorDelegate {
    func profileTabCoordinatorDelegateLogout(coordinator: ProfileTabCoordinator) {
        UserDefaultsManager().isUserLoggedIn = false

        delegate?.runningCoordinatorDidLogout(self)
    }
}

extension RunningCoordinator: PrimaryIpadControllerDelegate {
    func primaryIpadController(controller: PrimaryIpadController, didSelectChat chat: OCTChat) {
        showChat(chat)
    }

    func primaryIpadControllerShowFriends(controller: PrimaryIpadController) {
        if iPad.friendsCoordinator == nil {
            iPad.friendsCoordinator = FriendsTabCoordinator(theme: theme, toxManager: toxManager)
            iPad.friendsCoordinator!.delegate = self
            iPad.friendsCoordinator!.start()
        }

        iPad.splitController.showDetailViewController(iPad.friendsCoordinator!.navigationController, sender: nil)
    }

    func primaryIpadControllerShowSettings(controller: PrimaryIpadController) {
        if iPad.settingsCoordinator == nil {
            iPad.settingsCoordinator = SettingsTabCoordinator(theme: theme)
            iPad.settingsCoordinator!.start()
        }

        iPad.splitController.showDetailViewController(iPad.settingsCoordinator!.navigationController, sender: nil)
    }

    func primaryIpadControllerShowProfile(controller: PrimaryIpadController) {
        if iPad.profileCoordinator == nil {
            iPad.profileCoordinator = ProfileTabCoordinator(theme: theme, toxManager: toxManager)
            iPad.profileCoordinator!.delegate = self
            iPad.profileCoordinator!.start()
        }

        iPad.splitController.showDetailViewController(iPad.profileCoordinator!.navigationController, sender: nil)
    }
}

private extension RunningCoordinator {
    func createDeviceSpecificObjects() {
        switch InterfaceIdiom.current() {
            case .iPhone:
                let tabCoordinators = createTabCoordinators()
                let tabBarItems = createTabBarItems()
                let profileTabBarItem = tabBarItems[IphoneObjects.TabCoordinator.Profile.rawValue] as! TabBarProfileItem

                let tabBarController = TabBarController(theme: theme, controllers: tabCoordinators.map {
                    $0.navigationController
                }, tabBarItems: tabBarItems)


                iPhone = IphoneObjects(
                        tabCoordinators: tabCoordinators,
                        tabBarController: tabBarController,
                        profileTabBarItem: profileTabBarItem)
            case .iPad:
                let splitController = UISplitViewController()
                splitController.preferredDisplayMode = .AllVisible

                let primaryController = PrimaryIpadController(theme: theme, submanagerObjects: toxManager.objects)
                primaryController.delegate = self
                splitController.viewControllers = [UINavigationController(rootViewController: primaryController)]

                iPad = IpadObjects(
                        splitController: splitController,
                        primaryController: primaryController)
        }
    }

    func createTabCoordinators() -> [RunningNavigationCoordinator] {
        return IphoneObjects.TabCoordinator.allValues().map {
            switch $0 {
                case .Friends:
                    let friends = FriendsTabCoordinator(theme: theme, toxManager: toxManager)
                    friends.delegate = self
                    return friends
                case .Chats:
                    return ChatsTabCoordinator(theme: theme, submanagerObjects: toxManager.objects, submanagerChats: toxManager.chats)
                case .Settings:
                    return SettingsTabCoordinator(theme: theme)
                case .Profile:
                    let profile = ProfileTabCoordinator(theme: theme, toxManager: toxManager)
                    profile.delegate = self
                    return profile
            }
        }
    }

    func createTabBarItems() -> [TabBarAbstractItem] {
        return IphoneObjects.TabCoordinator.allValues().map {
            switch $0 {
                case .Friends:
                    let item = TabBarBadgeItem(theme: theme)
                    item.image = UIImage(named: "tab-bar-friends")
                    item.text = String(localized: "friends_title")
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

    }

    func showChat(chat: OCTChat) {
        switch InterfaceIdiom.current() {
            case .iPhone:
                let index = IphoneObjects.TabCoordinator.Chats.rawValue
                let coordinator = iPhone.tabCoordinators[index] as! ChatsTabCoordinator

                iPhone.tabBarController.selectedIndex = index
                coordinator.showChat(chat, animated: false)
            case .iPad:
                let controller = ChatPrivateController(
                        theme: theme,
                        chat: chat,
                        submanagerChats: toxManager.chats,
                        submanagerObjects: toxManager.objects)
                let navigation = UINavigationController(rootViewController: controller)

                iPad.splitController.showDetailViewController(navigation, sender: nil)
        }
    }
}
