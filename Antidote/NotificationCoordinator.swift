//
//  NotificationCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 18/01/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

private enum NotificationType {
    case NewMessage(OCTMessageAbstract)
    case FriendRequest(OCTFriendRequest)
}

private struct Constants {
    static let NotificationVisibleDuration = 3.0
}

protocol NotificationCoordinatorDelegate: class {
    func notificationCoordinator(coordinator: NotificationCoordinator, showChat chat: OCTChat)
    func notificationCoordinatorShowFriendRequest(coordinator: NotificationCoordinator)
}

class NotificationCoordinator: NSObject {
    weak var delegate: NotificationCoordinatorDelegate?

    private let theme: Theme
    private let userDefaults = UserDefaultsManager()

    private let notificationWindow: NotificationWindow

    private weak var submanagerObjects: OCTSubmanagerObjects!
    private let messagesController: RBQFetchedResultsController
    private let requestsController: RBQFetchedResultsController
    private let avatarManager: AvatarManager

    private var notificationQueue = [NotificationType]()
    private var isShowingNotifications = false
    private var bannedChatIdentifiers = Set<String>()

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme
        self.notificationWindow = NotificationWindow(theme: theme)

        self.submanagerObjects = submanagerObjects
        self.messagesController = submanagerObjects.fetchedResultsControllerForType(.MessageAbstract)
        self.requestsController = submanagerObjects.fetchedResultsControllerForType(.FriendRequest)
        self.avatarManager = AvatarManager(theme: theme)

        super.init()

        messagesController.delegate = self
        messagesController.performFetch()
        requestsController.delegate = self
        requestsController.performFetch()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    /**
        Show or hide connnecting view.
     */
    func toggleConnectingView(show show: Bool, animated: Bool) {
        notificationWindow.showConnectingView(show, animated: animated)
    }

    /**
        Stops showing notifications for given chat.
        Also removes all related to that chat notifications from queue.
     */
    func banNotificationsForChat(chat: OCTChat) {
        bannedChatIdentifiers.insert(chat.uniqueIdentifier)

        notificationQueue = notificationQueue.filter {
            switch $0 {
                case .NewMessage(let messageAbstract):
                    return messageAbstract.chat.uniqueIdentifier != chat.uniqueIdentifier
                case .FriendRequest:
                    return true
            }
        }
    }

    /**
        Unban notifications for given chat (if they were banned before).
     */
    func unbanNotificationsForChat(chat: OCTChat) {
        bannedChatIdentifiers.remove(chat.uniqueIdentifier)
    }

    func handleLocalNotification(notification: UILocalNotification) {
        guard let userInfo = notification.userInfo as? [String: String] else {
            return
        }

        guard let action = NotificationAction(dictionary: userInfo) else {
            return
        }

        performAction(action)
    }
}

extension NotificationCoordinator: CoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)

        let application = UIApplication.sharedApplication()
        application.registerUserNotificationSettings(settings)
        application.cancelAllLocalNotifications()
    }
}

// MARK: Notifications
extension NotificationCoordinator {
    func applicationDidBecomeActive() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
}

extension NotificationCoordinator: RBQFetchedResultsControllerDelegate {
    func controller(
            controller: RBQFetchedResultsController,
            didChangeObject anObject: RBQSafeRealmObject,
            atIndexPath indexPath: NSIndexPath?,
            forChangeType type: RBQFetchedResultsChangeType,
            newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                // we're good
                break
            case .Delete:
                return
            case .Move:
                return
            case .Update:
                return
        }

        if controller === messagesController {
            let message = anObject.RLMObject() as! OCTMessageAbstract

            if shouldEnqueueMessage(message) {
                enqueueNotification(.NewMessage(message))
            }
        }
        else if controller === requestsController {
            let request = anObject.RLMObject() as! OCTFriendRequest

            enqueueNotification(.FriendRequest(request))
        }
    }
}

private extension NotificationCoordinator {
    func shouldEnqueueMessage(message: OCTMessageAbstract) -> Bool {
        if message.isOutgoing() {
            return false
        }

        if UIApplication.sharedApplication().applicationState == .Active &&
           bannedChatIdentifiers.contains(message.chat.uniqueIdentifier) {
            return false
        }

        // Currently support only text notifications.
        if message.messageText != nil {
            return true
        }

        return false
    }

    func enqueueNotification(notification: NotificationType) {
        notificationQueue.append(notification)

        if isShowingNotifications {
            return
        }
        isShowingNotifications = true

        showNextNotification()
    }

    func showNextNotification() {
        if notificationQueue.isEmpty {
            notificationWindow.pushNotificationView(nil)
            isShowingNotifications = false
            return
        }

        let notification = notificationQueue.removeFirst()

        switch UIApplication.sharedApplication().applicationState {
            case .Active:
                showInAppNotification(notification)
            case .Inactive:
                fallthrough
            case .Background:
                showLocalNotification(notification)
        }
    }

    func showInAppNotification(notification: NotificationType) {
        let timer = NSTimer.scheduledTimerWithTimeInterval(Constants.NotificationVisibleDuration, block: { [weak self] _ in
            self?.showNextNotification()
        }, repeats: false)

        let closeHandler = { [weak self] in
            timer.invalidate()
            self?.showNextNotification()
        }

        let object = notificationObjectFromNotification(notification)

        let view = NotificationView(theme: theme, image: object.image, topText: object.title, bottomText: object.body, tapHandler: { [weak self] in
            self?.performAction(object.action)
            closeHandler()
        }, closeHandler: closeHandler)

        notificationWindow.pushNotificationView(view)
    }

    func showLocalNotification(notification: NotificationType) {
        let object = notificationObjectFromNotification(notification)

        let local = UILocalNotification()
        local.alertBody = "\(object.title): \(object.body)"
        local.userInfo = object.action.archive()

        UIApplication.sharedApplication().presentLocalNotificationNow(local)

        showNextNotification()
    }

    func notificationObjectFromNotification(notification: NotificationType) -> NotificationObject {
        switch notification {
            case .FriendRequest(let request):
                return notificationObjectFromRequest(request)
            case .NewMessage(let message):
                return notificationObjectFromMessage(message)
        }
    }

    func notificationObjectFromRequest(request: OCTFriendRequest) -> NotificationObject {
        let image = avatarManager.avatarFromString("", diameter: NotificationView.Constants.ImageSize)
        let title = String(localized: "notification_incoming_friend_request")
        let body = request.message

        return NotificationObject(image: image, title: title, body: body, action: .OpenRequests)
    }

    func notificationObjectFromMessage(message: OCTMessageAbstract) -> NotificationObject {
        let image = avatarManager.avatarFromString(message.sender.nickname, diameter: NotificationView.Constants.ImageSize)
        let title = message.sender.nickname
        var body: String = ""
        let action = NotificationAction.OpenChat(chatUniqueIdentifier: message.chat.uniqueIdentifier)

        if message.messageText != nil {
            body = userDefaults.showNotificationPreview ? message.messageText.text : String(localized: "notification_new_message")
        }

        return NotificationObject(image: image, title: title, body: body, action: action)
    }

    func performAction(action: NotificationAction) {
        switch action {
            case .OpenChat(let identifier):
                guard let chat = submanagerObjects.objectWithUniqueIdentifier(identifier, forType: .Chat) as? OCTChat else {
                    return
                }

                delegate?.notificationCoordinator(self, showChat: chat)
                banNotificationsForChat(chat)
            case .OpenRequests:
                delegate?.notificationCoordinatorShowFriendRequest(self)
                break
        }
    }
}
