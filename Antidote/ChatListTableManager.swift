//
//  ChatListTableManager.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 19/01/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

protocol ChatListTableManagerDelegate: class {
    func chatListTableManager(manager: ChatListTableManager, didSelectChat chat: OCTChat)
    func chatListTableManager(manager: ChatListTableManager, presentAlertController controller: UIAlertController)
    func chatListTableManagerWasUpdated(manager: ChatListTableManager)
}

class ChatListTableManager: NSObject {
    weak var delegate: ChatListTableManagerDelegate?

    let tableView: UITableView

    var isEmpty: Bool {
        get {
            return chats.count == 0
        }
    }

    private let theme: Theme
    private let avatarManager: AvatarManager
    private let dateFormatter: NSDateFormatter
    private let timeFormatter: NSDateFormatter

    private weak var submanagerChats: OCTSubmanagerChats!

    private let chats: Results<OCTChat>
    private var chatsToken: RLMNotificationToken?
    private let friends: Results<OCTFriend>
    private var friendsToken: RLMNotificationToken?

    init(theme: Theme, tableView: UITableView, submanagerChats: OCTSubmanagerChats, submanagerObjects: OCTSubmanagerObjects) {
        self.tableView = tableView

        self.theme = theme
        self.avatarManager = AvatarManager(theme: theme)
        self.dateFormatter = NSDateFormatter(type: .RelativeDate)
        self.timeFormatter = NSDateFormatter(type: .Time)

        self.submanagerChats = submanagerChats

        self.chats = submanagerObjects.chats().sortedResultsUsingProperty("lastActivityDateInterval", ascending: false)
        self.friends = submanagerObjects.friends()

        super.init()

        tableView.delegate = self
        tableView.dataSource = self

        addNotificationBlocks()
    }

    deinit {
        chatsToken?.stop()
        friendsToken?.stop()
    }
}

extension ChatListTableManager: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let chat = chats[indexPath.row]
        let friend = chat.friends.lastObject() as! OCTFriend

        let model = ChatListCellModel()
        if let data = friend.avatarData {
            model.avatar = UIImage(data: data)
        }
        else {
            model.avatar = avatarManager.avatarFromString(
                    friend.nickname,
                    diameter: CGFloat(ChatListCell.Constants.AvatarSize))
        }

        model.nickname = friend.nickname
        model.message = lastMessageTextFromChat(chat)
        if let date = chat.lastActivityDate() {
            model.dateText = dateTextFromDate(date)
        }

        model.status = UserStatus(connectionStatus: friend.connectionStatus, userStatus: friend.status)
        model.isUnread = chat.hasUnreadMessages()

        let cell = tableView.dequeueReusableCellWithIdentifier(ChatListCell.staticReuseIdentifier) as! ChatListCell
        cell.setupWithTheme(theme, model: model)

        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let alert = UIAlertController(title: String(localized:"delete_chat_title"), message: nil, preferredStyle: .Alert)

            alert.addAction(UIAlertAction(title: String(localized: "alert_cancel"), style: .Default, handler: nil))
            alert.addAction(UIAlertAction(title: String(localized: "alert_delete"), style: .Destructive) { [unowned self] _ -> Void in
                let chat = self.chats[indexPath.row]
                self.submanagerChats.removeChatWithAllMessages(chat)
            })

            delegate?.chatListTableManager(self, presentAlertController: alert)
        }
    }
}

extension ChatListTableManager: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let chat = self.chats[indexPath.row]
        delegate?.chatListTableManager(self, didSelectChat: chat)
    }
}

private extension ChatListTableManager {
    func addNotificationBlocks() {
        chatsToken = chats.addNotificationBlock { [unowned self] change in
            switch change {
                case .Initial:
                    break
                case .Update(_, let deletions, let insertions, let modifications):
                    self.tableView.beginUpdates()
                    self.tableView.deleteRowsAtIndexPaths(deletions.map { NSIndexPath(forRow: $0, inSection: 0) },
                                                          withRowAnimation: .Automatic)
                    self.tableView.insertRowsAtIndexPaths(insertions.map { NSIndexPath(forRow: $0, inSection: 0) },
                                                          withRowAnimation: .Automatic)
                    self.tableView.reloadRowsAtIndexPaths(modifications.map { NSIndexPath(forRow: $0, inSection: 0) },
                                                          withRowAnimation: .None)
                    self.tableView.endUpdates()

                    self.delegate?.chatListTableManagerWasUpdated(self)
                case .Error(let error):
                    fatalError("\(error)")
            }
        }

        friendsToken = friends.addNotificationBlock { [unowned self] change in
            switch change {
                case .Initial:
                    break
                case .Update(let friends, _, _, let modifications):
                    guard let friends = friends else {
                        break
                    }

                    for index in modifications {
                        let friend = friends[index]

                        let pathsToUpdate = self.tableView.indexPathsForVisibleRows?.filter {
                            let chat = self.chats[$0.row]

                            return Int(chat.friends.indexOfObject(friend)) != NSNotFound
                        }

                        if let paths = pathsToUpdate {
                            self.tableView.reloadRowsAtIndexPaths(paths, withRowAnimation: .None)
                        }
                    }
                case .Error(let error):
                fatalError("\(error)")
            }
        }
    }

    func lastMessageTextFromChat(chat: OCTChat) -> String {
        guard let message = chat.lastMessage else {
            return ""
        }

        if let text = message.messageText {
            return text.text ?? ""
        }
        else if let file = message.messageFile {
            let fileName = file.fileName ?? ""
            return String(localized: message.isOutgoing() ? "chat_outgoing_file" : "chat_incoming_file") + " \(fileName)"
        }
        else if let call = message.messageCall {
            switch call.callEvent {
                case .Answered:
                    let timeString = String(timeInterval: call.callDuration)
                    return String(localized: "chat_call_finished") + " - \(timeString)"
                case .Unanswered:
                    return message.isOutgoing() ?  String(localized: "chat_unanwered_call") : String(localized: "chat_missed_call_message")
            }
        }

        return ""
    }

    func dateTextFromDate(date: NSDate) -> String {
        let isToday = NSCalendar.currentCalendar().compareDate(NSDate(), toDate: date, toUnitGranularity: .Day) == .OrderedSame

        return isToday ? timeFormatter.stringFromDate(date) : dateFormatter.stringFromDate(date)
    }
}
