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
    func notificationCoordinator(coordinator: NotificationCoordinator, showFriendRequest request: OCTFriendRequest)
}

class NotificationCoordinator: NSObject {
    weak var delegate: NotificationCoordinatorDelegate?

    private let theme: Theme

    private let notificationWindow: NotificationWindow

    private let messagesController: RBQFetchedResultsController
    private let avatarManager: AvatarManager

    private var notificationQueue = [NotificationType]()
    private var isShowingNotifications = false
    private var bannedChatIdentifiers = Set<String>()

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme
        self.notificationWindow = NotificationWindow(theme: theme)

        self.messagesController = submanagerObjects.fetchedResultsControllerForType(.MessageAbstract)
        self.avatarManager = AvatarManager(theme: theme)

        super.init()

        messagesController.delegate = self
        messagesController.performFetch()
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
}

extension NotificationCoordinator: CoordinatorProtocol {
    func start() {
        // nop
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
                let message = anObject.RLMObject() as! OCTMessageAbstract
                if shouldEnqueueMessage(message) {
                    enqueueNotification(.NewMessage(message))
                }
            case .Delete:
                // nop
                break
            case .Move:
                // nop
                break
            case .Update:
                // nop
                break
        }
    }
}

private extension NotificationCoordinator {
    func shouldEnqueueMessage(message: OCTMessageAbstract) -> Bool {
        if message.isOutgoing() {
            return false
        }

        if bannedChatIdentifiers.contains(message.chat.uniqueIdentifier) {
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

        let timer = NSTimer.scheduledTimerWithTimeInterval(Constants.NotificationVisibleDuration, block: { [weak self] _ in
            self?.showNextNotification()
        }, repeats: false)

        let notification = notificationQueue.removeFirst()
        let view: NotificationView
        let closeHandler = { [weak self] in
            timer.invalidate()
            self?.showNextNotification()
        }

        switch notification {
            case .FriendRequest(let request):
                view = notificationViewFromFriendRequest(request, closeHandler: closeHandler)
            case .NewMessage(let message):
                view = notificationViewFromMessage(message, closeHandler: closeHandler)
        }

        notificationWindow.pushNotificationView(view)
    }

    func notificationViewFromFriendRequest(request: OCTFriendRequest, closeHandler: Void -> Void) -> NotificationView {
        // FIXME

        return NotificationView(theme: theme, image: UIImage(), topText: "", bottomText: "", tapHandler: { [weak self] in
            self?.delegate?.notificationCoordinator(self!, showFriendRequest: request)
            closeHandler()
        }, closeHandler: {
            closeHandler()
        })
    }

    func notificationViewFromMessage(message: OCTMessageAbstract, closeHandler: Void -> Void) -> NotificationView {
        let image = avatarManager.avatarFromString(message.sender.nickname, diameter: NotificationView.Constants.ImageSize)
        let topText = message.sender.nickname
        var bottomText: String = ""

        if message.messageText != nil {
            bottomText = message.messageText.text
        }

        return NotificationView(theme: theme, image: image, topText: topText, bottomText: bottomText, tapHandler: { [weak self] in
            self?.delegate?.notificationCoordinator(self!, showChat: message.chat)
            self?.banNotificationsForChat(message.chat)
            closeHandler()
        }, closeHandler: {
            closeHandler()
        })
    }
}
