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
    private var chats: Results<OCTChat>
    private var chatsToken: RLMNotificationToken?
    private var requests: Results<OCTFriendRequest>
    private var requestsToken: RLMNotificationToken?

    private let avatarManager: AvatarManager
    private let audioPlayer = AlertAudioPlayer()

    private var notificationQueue = [NotificationType]()
    private var inAppNotificationAppIdsRegistered = [String: Bool]()
    private var bannedChatIdentifiers = Set<String>()

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme
        self.notificationWindow = NotificationWindow(theme: theme)

        self.submanagerObjects = submanagerObjects
        self.avatarManager = AvatarManager(theme: theme)

        let predicate = NSPredicate(format: "lastMessage.dateInterval > lastReadDateInterval")
        self.chats = submanagerObjects.chats(predicate: predicate)
        self.requests = submanagerObjects.friendRequests()

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
                    return messageAbstract.chatUniqueIdentifier != chat.uniqueIdentifier
                case .FriendRequest:
                    return true
            }
        }
        
        LNNotificationCenter.defaultCenter().clearPendingNotificationsForApplicationIdentifier(chat.uniqueIdentifier);
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
                title: caller,
                body: String(localized: "notification_is_calling"),
                action: .AnswerIncomingCall(userInfo: userInfo),
                soundName: "isotoxin_Ringtone.aac")

        showLocalNotificationObject(object)
    }
    
    func registerInAppNotificationAppId(appId: String) {
        if inAppNotificationAppIdsRegistered[appId] == nil {
            LNNotificationCenter.defaultCenter().registerApplicationWithIdentifier(appId, name: NSBundle.mainBundle().infoDictionary?["CFBundleDisplayName"] as? String, icon: UIImage.init(imageLiteral: "notification-app-icon"), defaultSettings: LNNotificationAppSettings.defaultNotificationAppSettings())
            inAppNotificationAppIdsRegistered[appId] = true
        }
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
        let messages = submanagerObjects.messages().sortedResultsUsingProperty("dateInterval", ascending: false)
        messagesToken = messages.addNotificationBlock { [unowned self] change in
            switch change {
                case .Initial:
                    break
                case .Update(let messages, _, let insertions, _):
                    guard let messages = messages else {
                        break
                    }
                    if insertions.contains(0) {
                        let message = messages[0]

                        self.playSoundForMessageIfNeeded(message)

                        if self.shouldEnqueueMessage(message) {
                            self.enqueueNotification(.NewMessage(message))
                        }
                    }
                case .Error(let error):
                fatalError("\(error)")
            }
        }

        chatsToken = chats.addNotificationBlock { [unowned self] change in
            switch change {
                case .Initial:
                    break
                case .Update:
                    self.updateBadges()
                case .Error(let error):
                fatalError("\(error)")
            }
        }

        requestsToken = requests.addNotificationBlock { [unowned self] change in
            switch change {
                case .Initial:
                    break
                case .Update(let requests, _, let insertions, _):
                    guard let requests = requests else {
                        break
                    }
                    for index in insertions {
                        let request = requests[index]

                        self.audioPlayer.playSound(.NewMessage)
                        self.enqueueNotification(.FriendRequest(request))
                    }
                    self.updateBadges()
                case .Error(let error):
                fatalError("\(error)")
            }
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

        if UIApplication.isActive && bannedChatIdentifiers.contains(message.chatUniqueIdentifier) {
            return false
        }

        if message.messageText != nil || message.messageFile != nil {
            return true
        }

        return false
    }

    func enqueueNotification(notification: NotificationType) {
        notificationQueue.append(notification)

        showNextNotification()
    }

    func showNextNotification() {
        if notificationQueue.isEmpty {
            return
        }

        let notification = notificationQueue.removeFirst()
        let object = notificationObjectFromNotification(notification)

        if UIApplication.isActive {
            switch notification {
                case .NewMessage(let messageAbstract):
                    showInAppNotificationObject(object, chatUniqueIdentifier: messageAbstract.chatUniqueIdentifier)
                default:
                    showInAppNotificationObject(object, chatUniqueIdentifier: nil)
            }
        }
        else {
            showLocalNotificationObject(object)
        }
    }

    func showInAppNotificationObject(object: NotificationObject, chatUniqueIdentifier: String?) {
        var appId:String
        
        if chatUniqueIdentifier != nil {
            appId = chatUniqueIdentifier!
        } else {
            appId = NSBundle.mainBundle().bundleIdentifier!
        }
        
        registerInAppNotificationAppId(appId);

        let notification = LNNotification.init(message: object.body, title: object.title)
        notification.soundName = object.soundName;
        notification.defaultAction = LNNotificationAction.init(title: nil, handler: { [weak self] _ in
            self?.performAction(object.action)
        })
        
        LNNotificationCenter.defaultCenter().presentNotification(notification, forApplicationIdentifier: appId)
        
        showNextNotification()
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
        let title = String(localized: "notification_incoming_contact_request")
        let body = request.message ?? ""
        let action = NotificationAction.OpenRequest(requestUniqueIdentifier: request.uniqueIdentifier)

        return NotificationObject(title: title, body: body, action: action, soundName: "isotoxin_NewMessage.aac")
    }

    func notificationObjectFromMessage(message: OCTMessageAbstract) -> NotificationObject {
        let title: String

        if let friend = submanagerObjects.objectWithUniqueIdentifier(message.senderUniqueIdentifier, forType: .Friend) as? OCTFriend {
            title = friend.nickname
        }
        else {
            title = ""
        }

        var body: String = ""
        let action = NotificationAction.OpenChat(chatUniqueIdentifier: message.chatUniqueIdentifier)

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

        return NotificationObject(title: title, body: body, action: action, soundName: "isotoxin_NewMessage.aac")
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
        let chatsCount = chats.count
        let requestsCount = requests.count

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
