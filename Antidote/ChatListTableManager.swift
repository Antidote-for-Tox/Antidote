// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol ChatListTableManagerDelegate: class {
    func chatListTableManager(_ manager: ChatListTableManager, didSelectChat chat: OCTChat)
    func chatListTableManager(_ manager: ChatListTableManager, presentAlertController controller: UIAlertController)
    func chatListTableManagerWasUpdated(_ manager: ChatListTableManager)
}

class ChatListTableManager: NSObject {
    weak var delegate: ChatListTableManagerDelegate?

    let tableView: UITableView

    var isEmpty: Bool {
        get {
            return chats.count == 0
        }
    }

    fileprivate let theme: Theme
    fileprivate let avatarManager: AvatarManager
    fileprivate let dateFormatter: DateFormatter
    fileprivate let timeFormatter: DateFormatter

    fileprivate weak var submanagerChats: OCTSubmanagerChats!

    fileprivate let chats: Results<OCTChat>
    fileprivate var chatsToken: RLMNotificationToken?
    fileprivate let friends: Results<OCTFriend>
    fileprivate var friendsToken: RLMNotificationToken?

    init(theme: Theme, tableView: UITableView, submanagerChats: OCTSubmanagerChats, submanagerObjects: OCTSubmanagerObjects) {
        self.tableView = tableView

        self.theme = theme
        self.avatarManager = AvatarManager(theme: theme)
        self.dateFormatter = DateFormatter(type: .relativeDate)
        self.timeFormatter = DateFormatter(type: .time)

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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

        let cell = tableView.dequeueReusableCell(withIdentifier: ChatListCell.staticReuseIdentifier) as! ChatListCell
        cell.setupWithTheme(theme, model: model)

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: String(localized:"delete_chat_title"), message: nil, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: String(localized: "alert_cancel"), style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: String(localized: "alert_delete"), style: .destructive) { [unowned self] _ -> Void in
                let chat = self.chats[indexPath.row]
                self.submanagerChats.removeAllMessages(in: chat, removeChat: true)
            })

            delegate?.chatListTableManager(self, presentAlertController: alert)
        }
    }
}

extension ChatListTableManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let chat = self.chats[indexPath.row]
        delegate?.chatListTableManager(self, didSelectChat: chat)
    }
}

private extension ChatListTableManager {
    func addNotificationBlocks() {
        chatsToken = chats.addNotificationBlock { [unowned self] change in
            switch change {
                case .initial:
                    break
                case .update(_, let deletions, let insertions, let modifications):
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) },
                                                          with: .automatic)
                    self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) },
                                                          with: .automatic)
                    self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) },
                                                          with: .none)
                    self.tableView.endUpdates()

                    self.delegate?.chatListTableManagerWasUpdated(self)
                case .error(let error):
                    fatalError("\(error)")
            }
        }

        friendsToken = friends.addNotificationBlock { [unowned self] change in
            switch change {
                case .initial:
                    break
                case .update(let friends, _, _, let modifications):
                    guard let friends = friends else {
                        break
                    }

                    for index in modifications {
                        let friend = friends[index]

                        let pathsToUpdate = self.tableView.indexPathsForVisibleRows?.filter {
                            let chat = self.chats[$0.row]

                            return Int(chat.friends.index(of: friend)) != NSNotFound
                        }

                        if let paths = pathsToUpdate {
                            self.tableView.reloadRows(at: paths, with: .none)
                        }
                    }
                case .error(let error):
                fatalError("\(error)")
            }
        }
    }

    func lastMessageTextFromChat(_ chat: OCTChat) -> String {
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
                case .answered:
                    let timeString = String(timeInterval: call.callDuration)
                    return String(localized: "chat_call_finished") + " - \(timeString)"
                case .unanswered:
                    return message.isOutgoing() ?  String(localized: "chat_unanwered_call") : String(localized: "chat_missed_call_message")
            }
        }

        return ""
    }

    func dateTextFromDate(_ date: Date) -> String {
        let isToday = (Calendar.current as NSCalendar).compare(Date(), to: date, toUnitGranularity: .day) == .orderedSame

        return isToday ? timeFormatter.string(from: date) : dateFormatter.string(from: date)
    }
}
