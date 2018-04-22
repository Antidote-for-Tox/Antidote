// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

private enum NotificationType {
    case newMessage(OCTMessageAbstract)
    case friendRequest(OCTFriendRequest)
}

private struct Constants {
    static let NotificationVisibleDuration = 3.0
}

protocol NotificationCoordinatorDelegate: class {
    func notificationCoordinator(_ coordinator: NotificationCoordinator, showChat chat: OCTChat)
    func notificationCoordinatorShowFriendRequest(_ coordinator: NotificationCoordinator, showRequest request: OCTFriendRequest)
    func notificationCoordinatorAnswerIncomingCall(_ coordinator: NotificationCoordinator, userInfo: String)

    func notificationCoordinator(_ coordinator: NotificationCoordinator, updateFriendsBadge badge: Int)
    func notificationCoordinator(_ coordinator: NotificationCoordinator, updateChatsBadge badge: Int)
}

class NotificationCoordinator: NSObject {
    weak var delegate: NotificationCoordinatorDelegate?

    fileprivate let theme: Theme
    fileprivate let userDefaults = UserDefaultsManager()

    fileprivate let notificationWindow: NotificationWindow

    fileprivate weak var submanagerObjects: OCTSubmanagerObjects!

    fileprivate var messagesToken: RLMNotificationToken?
    fileprivate var chats: Results<OCTChat>
    fileprivate var chatsToken: RLMNotificationToken?
    fileprivate var requests: Results<OCTFriendRequest>
    fileprivate var requestsToken: RLMNotificationToken?

    fileprivate let avatarManager: AvatarManager
    fileprivate let audioPlayer = AlertAudioPlayer()

    fileprivate var notificationQueue = [NotificationType]()
    fileprivate var inAppNotificationAppIdsRegistered = [String: Bool]()
    fileprivate var bannedChatIdentifiers = Set<String>()

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

        NotificationCenter.default.addObserver(self, selector: #selector(NotificationCoordinator.applicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)

        messagesToken?.invalidate()
        chatsToken?.invalidate()
        requestsToken?.invalidate()
    }

    /**
        Show or hide connnecting view.
     */
    func toggleConnectingView(show: Bool, animated: Bool) {
        notificationWindow.showConnectingView(show, animated: animated)
    }

    /**
        Stops showing notifications for given chat.
        Also removes all related to that chat notifications from queue.
     */
    func banNotificationsForChat(_ chat: OCTChat) {
        bannedChatIdentifiers.insert(chat.uniqueIdentifier)

        notificationQueue = notificationQueue.filter {
            switch $0 {
                case .newMessage(let messageAbstract):
                    return messageAbstract.chatUniqueIdentifier != chat.uniqueIdentifier
                case .friendRequest:
                    return true
            }
        }
        
        LNNotificationCenter.default().clearPendingNotifications(forApplicationIdentifier: chat.uniqueIdentifier);
    }

    /**
        Unban notifications for given chat (if they were banned before).
     */
    func unbanNotificationsForChat(_ chat: OCTChat) {
        bannedChatIdentifiers.remove(chat.uniqueIdentifier)
    }

    func handleLocalNotification(_ notification: UILocalNotification) {
        guard let userInfo = notification.userInfo as? [String: String] else {
            return
        }

        guard let action = NotificationAction(dictionary: userInfo) else {
            return
        }

        performAction(action)
    }

    func showCallNotificationWithCaller(_ caller: String, userInfo: String) {
        let object = NotificationObject(
                title: caller,
                body: String(localized: "notification_is_calling"),
                action: .answerIncomingCall(userInfo: userInfo),
                soundName: "isotoxin_Ringtone.aac")

        showLocalNotificationObject(object)
    }
    
    func registerInAppNotificationAppId(_ appId: String) {
        if inAppNotificationAppIdsRegistered[appId] == nil {
            LNNotificationCenter.default().registerApplication(withIdentifier: appId, name: Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String, icon: UIImage(named: "notification-app-icon"), defaultSettings: LNNotificationAppSettings.default())
            inAppNotificationAppIdsRegistered[appId] = true
        }
    }
}

extension NotificationCoordinator: CoordinatorProtocol {
    func startWithOptions(_ options: CoordinatorOptions?) {
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)

        let application = UIApplication.shared
        application.registerUserNotificationSettings(settings)
        application.cancelAllLocalNotifications()

        updateBadges()
    }
}

// MARK: Notifications
extension NotificationCoordinator {
    @objc func applicationDidBecomeActive() {
        UIApplication.shared.cancelAllLocalNotifications()
    }
}

private extension NotificationCoordinator {
    func addNotificationBlocks() {
        let messages = submanagerObjects.messages().sortedResultsUsingProperty("dateInterval", ascending: false)
        messagesToken = messages.addNotificationBlock { [unowned self] change in
            switch change {
                case .initial:
                    break
                case .update(let messages, _, let insertions, _):
                    guard let messages = messages else {
                        break
                    }
                    if insertions.contains(0) {
                        let message = messages[0]

                        self.playSoundForMessageIfNeeded(message)

                        if self.shouldEnqueueMessage(message) {
                            self.enqueueNotification(.newMessage(message))
                        }
                    }
                case .error(let error):
                fatalError("\(error)")
            }
        }

        chatsToken = chats.addNotificationBlock { [unowned self] change in
            switch change {
                case .initial:
                    break
                case .update:
                    self.updateBadges()
                case .error(let error):
                fatalError("\(error)")
            }
        }

        requestsToken = requests.addNotificationBlock { [unowned self] change in
            switch change {
                case .initial:
                    break
                case .update(let requests, _, let insertions, _):
                    guard let requests = requests else {
                        break
                    }
                    for index in insertions {
                        let request = requests[index]

                        self.audioPlayer.playSound(.NewMessage)
                        self.enqueueNotification(.friendRequest(request))
                    }
                    self.updateBadges()
                case .error(let error):
                fatalError("\(error)")
            }
        }
    }

    func playSoundForMessageIfNeeded(_ message: OCTMessageAbstract) {
        if message.isOutgoing() {
            return
        }

        if message.messageText != nil || message.messageFile != nil {
            audioPlayer.playSound(.NewMessage)
        }
    }

    func shouldEnqueueMessage(_ message: OCTMessageAbstract) -> Bool {
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

    func enqueueNotification(_ notification: NotificationType) {
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
                case .newMessage(let messageAbstract):
                    showInAppNotificationObject(object, chatUniqueIdentifier: messageAbstract.chatUniqueIdentifier)
                default:
                    showInAppNotificationObject(object, chatUniqueIdentifier: nil)
            }
        }
        else {
            showLocalNotificationObject(object)
        }
    }

    func showInAppNotificationObject(_ object: NotificationObject, chatUniqueIdentifier: String?) {
        var appId:String
        
        if chatUniqueIdentifier != nil {
            appId = chatUniqueIdentifier!
        } else {
            appId = Bundle.main.bundleIdentifier!
        }
        
        registerInAppNotificationAppId(appId);

        let notification = LNNotification.init(message: object.body, title: object.title)
        notification?.defaultAction = LNNotificationAction.init(title: nil, handler: { [weak self] _ in
            self?.performAction(object.action)
        })
        
        LNNotificationCenter.default().present(notification, forApplicationIdentifier: appId)
        
        showNextNotification()
    }

    func showLocalNotificationObject(_ object: NotificationObject) {
        let local = UILocalNotification()
        local.alertBody = "\(object.title): \(object.body)"
        local.userInfo = object.action.archive()
        local.soundName = object.soundName

        UIApplication.shared.presentLocalNotificationNow(local)

        showNextNotification()
    }

    func notificationObjectFromNotification(_ notification: NotificationType) -> NotificationObject {
        switch notification {
            case .friendRequest(let request):
                return notificationObjectFromRequest(request)
            case .newMessage(let message):
                return notificationObjectFromMessage(message)
        }
    }

    func notificationObjectFromRequest(_ request: OCTFriendRequest) -> NotificationObject {
        let title = String(localized: "notification_incoming_contact_request")
        let body = request.message ?? ""
        let action = NotificationAction.openRequest(requestUniqueIdentifier: request.uniqueIdentifier)

        return NotificationObject(title: title, body: body, action: action, soundName: "isotoxin_NewMessage.aac")
    }

    func notificationObjectFromMessage(_ message: OCTMessageAbstract) -> NotificationObject {
        let title: String

        if let friend = submanagerObjects.object(withUniqueIdentifier: message.senderUniqueIdentifier, for: .friend) as? OCTFriend {
            title = friend.nickname
        }
        else {
            title = ""
        }

        var body: String = ""
        let action = NotificationAction.openChat(chatUniqueIdentifier: message.chatUniqueIdentifier)

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

    func performAction(_ action: NotificationAction) {
        switch action {
            case .openChat(let identifier):
                guard let chat = submanagerObjects.object(withUniqueIdentifier: identifier, for: .chat) as? OCTChat else {
                    return
                }

                delegate?.notificationCoordinator(self, showChat: chat)
                banNotificationsForChat(chat)
            case .openRequest(let identifier):
                guard let request = submanagerObjects.object(withUniqueIdentifier: identifier, for: .friendRequest) as? OCTFriendRequest else {
                    return
                }

                delegate?.notificationCoordinatorShowFriendRequest(self, showRequest: request)
            case .answerIncomingCall(let userInfo):
                delegate?.notificationCoordinatorAnswerIncomingCall(self, userInfo: userInfo)
        }
    }

    func updateBadges() {
        let chatsCount = chats.count
        let requestsCount = requests.count

        delegate?.notificationCoordinator(self, updateChatsBadge: chatsCount)
        delegate?.notificationCoordinator(self, updateFriendsBadge: requestsCount)

        UIApplication.shared.applicationIconBadgeNumber = chatsCount + requestsCount
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
