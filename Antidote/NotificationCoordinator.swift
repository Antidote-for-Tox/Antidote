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
    func notificationCoordinatorShowFriendRequest(coordinator: NotificationCoordinator, showRequest request: OCTFriendRequest)
    func notificationCoordinatorAnswerIncomingCall(coordinator: NotificationCoordinator, userInfo: String)

    func notificationCoordinator(coordinator: NotificationCoordinator, updateFriendsBadge badge: Int)
    func notificationCoordinator(coordinator: NotificationCoordinator, updateChatsBadge badge: Int)
}

class NotificationCoordinator: NSObject {
    weak var delegate: NotificationCoordinatorDelegate?

    private let theme: Theme
    private let userDefaults = UserDefaultsManager()

    private let notificationWindow: NotificationWindow

    private weak var submanagerObjects: OCTSubmanagerObjects!

    private var messagesToken: RLMNotificationToken?
    private var chats: RLMResults
    private var chatsToken: RLMNotificationToken?
    private var requests: RLMResults
    private var requestsToken: RLMNotificationToken?

    private let avatarManager: AvatarManager
    private let audioPlayer = AlertAudioPlayer()

    private var notificationQueue = [NotificationType]()
    private var isShowingNotifications = false
    private var bannedChatIdentifiers = Set<String>()

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme
        self.notificationWindow = NotificationWindow(theme: theme)

        self.submanagerObjects = submanagerObjects
        self.avatarManager = AvatarManager(theme: theme)

        let predicate = NSPredicate(format: "lastMessage.dateInterval > lastReadDateInterval")
        self.chats = submanagerObjects.objectsForType(.Chat, predicate: predicate)
        self.requests = submanagerObjects.objectsForType(.FriendRequest, predicate: nil)

        super.init()

        addNotificationBlocks()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NotificationCoordinator.applicationDidBecomeActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)

        messagesToken?.stop()
        chatsToken?.stop()
        requestsToken?.stop()
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

    func showCallNotificationWithCaller(caller: String, userInfo: String) {
        let object = NotificationObject(
                image: UIImage.emptyImage(),
                title: caller,
                body: String(localized: "notification_is_calling"),
                action: .AnswerIncomingCall(userInfo: userInfo),
                soundName: "isotoxin_Ringtone.aac")

        showLocalNotificationObject(object)
    }
}

extension NotificationCoordinator: CoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)

        let application = UIApplication.sharedApplication()
        application.registerUserNotificationSettings(settings)
        application.cancelAllLocalNotifications()

        updateBadges()
    }
}

// MARK: Notifications
extension NotificationCoordinator {
    func applicationDidBecomeActive() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
}

private extension NotificationCoordinator {
    func addNotificationBlocks() {
        let messages = submanagerObjects.objectsForType(.MessageAbstract, predicate: nil)
        messagesToken = messages.addNotificationBlock { [unowned self] messages, changes, error in
            if let error = error {
                fatalError("\(error)")
            }

            guard let changes = changes, let messages = messages else {
                return
            }

            for index in changes.insertions {
                let message = messages[UInt(index)] as! OCTMessageAbstract

                self.playSoundForMessageIfNeeded(message)

                if self.shouldEnqueueMessage(message) {
                    self.enqueueNotification(.NewMessage(message))
                }
            }
        }

        chatsToken = chats.addNotificationBlock { [unowned self] chats, changes, error in
            if let error = error {
                fatalError("\(error)")
            }

            self.updateBadges()
        }

        requestsToken = requests.addNotificationBlock { [unowned self] requests, changes, error in
            if let error = error {
                fatalError("\(error)")
            }
            
            guard let changes = changes, let requests = requests else {
                return
            }

            for index in changes.insertions {
                let request = requests[UInt(index)] as! OCTFriendRequest

                self.audioPlayer.playSound(.NewMessage)
                self.enqueueNotification(.FriendRequest(request))
            }
            self.updateBadges()
        }
    }

    func playSoundForMessageIfNeeded(message: OCTMessageAbstract) {
        if message.isOutgoing() {
            return
        }

        if message.messageText != nil || message.messageFile != nil {
            audioPlayer.playSound(.NewMessage)
        }
    }

    func shouldEnqueueMessage(message: OCTMessageAbstract) -> Bool {
        if message.isOutgoing() {
            return false
        }

        if UIApplication.isActive && bannedChatIdentifiers.contains(message.chat.uniqueIdentifier) {
            return false
        }

        if message.messageText != nil || message.messageFile != nil {
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
        let object = notificationObjectFromNotification(notification)

        if UIApplication.isActive {
            showInAppNotificationObject(object)
        }
        else {
            showLocalNotificationObject(object)
        }
    }

    func showInAppNotificationObject(object: NotificationObject) {
        let timer = NSTimer.scheduledTimerWithTimeInterval(Constants.NotificationVisibleDuration, block: { [weak self] _ in
            self?.showNextNotification()
        }, repeats: false)

        let closeHandler = { [weak self] in
            timer.invalidate()
            self?.showNextNotification()
        }

        let view = NotificationView(theme: theme, image: object.image, topText: object.title, bottomText: object.body, tapHandler: { [weak self] in
            self?.performAction(object.action)
            closeHandler()
        }, closeHandler: closeHandler)

        notificationWindow.pushNotificationView(view)
    }

    func showLocalNotificationObject(object: NotificationObject) {
        let local = UILocalNotification()
        local.alertBody = "\(object.title): \(object.body)"
        local.userInfo = object.action.archive()
        local.soundName = object.soundName

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
        let title = String(localized: "notification_incoming_contact_request")
        let body = request.message ?? ""
        let action = NotificationAction.OpenRequest(requestUniqueIdentifier: request.uniqueIdentifier)

        return NotificationObject(image: image, title: title, body: body, action: action, soundName: "isotoxin_NewMessage.aac")
    }

    func notificationObjectFromMessage(message: OCTMessageAbstract) -> NotificationObject {
        let image = avatarManager.avatarFromString(message.sender?.nickname ?? "?", diameter: NotificationView.Constants.ImageSize)
        let title = message.sender?.nickname ?? ""
        var body: String = ""
        let action = NotificationAction.OpenChat(chatUniqueIdentifier: message.chat.uniqueIdentifier)

        if let messageText = message.messageText {
            let defaultString = String(localized: "notification_new_message")

            if userDefaults.showNotificationPreview {
                body = messageText.text ?? defaultString
            }
            else {
                body = defaultString
            }
        }
        else if let messageFile = message.messageFile {
            let defaultString = String(localized: "notification_incoming_file")

            if userDefaults.showNotificationPreview {
                body = messageFile.fileName ?? defaultString
            }
            else {
                body = defaultString
            }
        }

        return NotificationObject(image: image, title: title, body: body, action: action, soundName: "isotoxin_NewMessage.aac")
    }

    func performAction(action: NotificationAction) {
        switch action {
            case .OpenChat(let identifier):
                guard let chat = submanagerObjects.objectWithUniqueIdentifier(identifier, forType: .Chat) as? OCTChat else {
                    return
                }

                delegate?.notificationCoordinator(self, showChat: chat)
                banNotificationsForChat(chat)
            case .OpenRequest(let identifier):
                guard let request = submanagerObjects.objectWithUniqueIdentifier(identifier, forType: .FriendRequest) as? OCTFriendRequest else {
                    return
                }

                delegate?.notificationCoordinatorShowFriendRequest(self, showRequest: request)
            case .AnswerIncomingCall(let userInfo):
                delegate?.notificationCoordinatorAnswerIncomingCall(self, userInfo: userInfo)
        }
    }

    func updateBadges() {
        let chatsCount = Int(chats.count)
        let requestsCount = Int(requests.count)

        delegate?.notificationCoordinator(self, updateChatsBadge: chatsCount)
        delegate?.notificationCoordinator(self, updateFriendsBadge: requestsCount)

        UIApplication.sharedApplication().applicationIconBadgeNumber = chatsCount + requestsCount
    }

    // func chatsBadge() -> Int {
    //     // TODO update to new Realm and filter unread chats with predicate "lastMessage.dateInterval > lastReadDateInterval"
    //     var badge = 0

    //     for index in 0..<chats.count {
    //         guard let chat = chats[index] as? OCTChat else {
    //             continue
    //         }

    //         if chat.hasUnreadMessages() {
    //             badge += 1
    //         }
    //     }

    //     return badge
    // }
}
