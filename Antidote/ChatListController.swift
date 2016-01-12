//
//  ChatListController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 12/01/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

protocol ChatListControllerDelegate: class {
    func chatListController(controller: ChatListController, didSelectChat chat: OCTChat)
}

class ChatListController: UIViewController {
    weak var delegate: ChatListControllerDelegate?

    private let theme: Theme
    private let avatarManager: AvatarManager
    private let dateFormatter: NSDateFormatter
    private let timeFormatter: NSDateFormatter

    private let chatsController: RBQFetchedResultsController
    private let friendsController: RBQFetchedResultsController

    private var tableView: UITableView!

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme
        self.avatarManager = AvatarManager(theme: theme)
        self.dateFormatter = NSDateFormatter(type: .RelativeDate)
        self.timeFormatter = NSDateFormatter(type: .Time)

        let descriptors = [RLMSortDescriptor(property: "lastActivityDateInterval", ascending: false)]
        self.chatsController = submanagerObjects.fetchedResultsControllerForType(.Chat, sortDescriptors: descriptors)
        self.chatsController.performFetch()

        self.friendsController = submanagerObjects.fetchedResultsControllerForType(.Friend)
        self.friendsController.performFetch()

        super.init(nibName: nil, bundle: nil)

        chatsController.delegate = self
        friendsController.delegate = self

        addNavigationButtons()

        edgesForExtendedLayout = .None
        title = String(localized: "chats_title")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        createTableView()
        installConstraints()
    }
}

extension ChatListController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let chat = chatsController.objectAtIndexPath(indexPath) as! OCTChat
        let friend = chat.friends.lastObject() as! OCTFriend

        let model = ChatListCellModel()
        model.avatar = avatarManager.avatarFromString(
                friend.nickname,
                diameter: CGFloat(ChatListCell.Constants.AvatarSize))

        model.nickname = friend.nickname
        model.message = lastMessageTextFromChat(chat)
        model.dateText = dateTextFromDate(chat.lastActivityDate())

        model.status = UserStatus(connectionStatus: friend.connectionStatus, userStatus: friend.status)
        model.isUnread = chat.hasUnreadMessages()

        let cell = tableView.dequeueReusableCellWithIdentifier(ChatListCell.staticReuseIdentifier) as! ChatListCell
        cell.setupWithTheme(theme, model: model)

        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatsController.numberOfRowsForSectionIndex(section)
    }
}

extension ChatListController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let chat = chatsController.objectAtIndexPath(indexPath) as! OCTChat
        delegate?.chatListController(self, didSelectChat: chat)
    }
}

extension ChatListController: RBQFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: RBQFetchedResultsController) {
        tableView.beginUpdates()
    }

   func controllerDidChangeContent(controller: RBQFetchedResultsController) {
        ExceptionHandling.tryWithBlock({ [unowned self] in
            self.tableView.endUpdates()
        }) { [unowned self] _ in
            controller.reset()
            self.tableView.reloadData()
        }
   }

    func controller(
            controller: RBQFetchedResultsController,
            didChangeObject anObject: RBQSafeRealmObject,
            atIndexPath indexPath: NSIndexPath?,
            forChangeType type: RBQFetchedResultsChangeType,
            newIndexPath: NSIndexPath?) {

        if controller === chatsController {
            switch type {
                case .Insert:
                    tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
                case .Delete:
                    tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
                case .Move:
                    tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
                    tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
                case .Update:
                    tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
            }
        }
        else if controller === friendsController {
            guard type == .Update else {
                return
            }

            let friend = anObject.RLMObject() as! OCTFriend

            let pathsToUpdate = tableView.indexPathsForVisibleRows?.filter {
                let chat = chatsController.objectAtIndexPath($0) as! OCTChat

                return Int(chat.friends.indexOfObject(friend)) != NSNotFound
            }

            if let paths = pathsToUpdate {
                tableView.reloadRowsAtIndexPaths(paths, withRowAnimation: .None)
            }
        }
    }
}

private extension ChatListController {
    func addNavigationButtons() {
        // none for now
    }

    func createTableView() {
        tableView = UITableView()
        tableView.estimatedRowHeight = 44.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = theme.colorForType(.NormalBackground)
        tableView.sectionIndexColor = theme.colorForType(.LinkText)
        // removing separators on empty lines
        tableView.tableFooterView = UIView()

        view.addSubview(tableView)

        tableView.registerClass(ChatListCell.self, forCellReuseIdentifier: ChatListCell.staticReuseIdentifier)
    }

    func installConstraints() {
        tableView.snp_makeConstraints {
            $0.edges.equalTo(view)
        }
    }

    func lastMessageTextFromChat(chat: OCTChat) -> String {
        guard let message = chat.lastMessage else {
            return ""
        }

        if let text = message.messageText {
            return text.text
        }
        else if let file = message.messageFile {
            return String(localized: message.isOutgoing() ? "chat_outgoing_file" : "chat_incoming_file") + " \(file.fileName)"
        }
        else if let call = message.messageCall {
            switch call.callEvent {
                case .Answered:
                    let timeString = String(timeInterval: call.callDuration)
                    return String(localized: "chat_call_finished") + " - \(timeString)"
                case .Unanswered:
                    return String(localized: "chat_unanwered_call")
            }
        }

        return ""
    }

    func dateTextFromDate(date: NSDate) -> String {
        let isToday = NSCalendar.currentCalendar().compareDate(NSDate(), toDate: date, toUnitGranularity: .Day) == .OrderedSame

        return isToday ? timeFormatter.stringFromDate(date) : dateFormatter.stringFromDate(date)
    }
}
