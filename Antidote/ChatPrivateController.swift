//
//  ChatPrivateController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 13.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let MessagesPortionSize = 50

    static let InputViewTopOffset: CGFloat = 50.0

    static let NewMessageViewAllowedDelta: CGFloat = 20.0
    static let NewMessageViewEdgesOffset: CGFloat = 5.0
    static let NewMessageViewTopOffset: CGFloat = -15.0
    static let NewMessageViewAnimationDuration = 0.2

    static let ResetPanAnimationDuration = 0.3
}

protocol ChatPrivateControllerDelegate: class {
    func chatPrivateControllerWillAppear(controller: ChatPrivateController)
    func chatPrivateControllerWillDisappear(controller: ChatPrivateController)
}

class ChatPrivateController: KeyboardNotificationController {
    let chat: OCTChat

    private weak var delegate: ChatPrivateControllerDelegate?

    private let theme: Theme
    private let friend: OCTFriend
    private weak var submanagerChats: OCTSubmanagerChats!
    private weak var submanagerObjects: OCTSubmanagerObjects!

    private let dataSource: PortionDataSource
    private let friendController: RBQFetchedResultsController

    private let timeFormatter: NSDateFormatter

    private var titleView: ChatPrivateTitleView!
    private var tableView: UITableView!
    private var newMessagesView: UIView!
    private var chatInputView: ChatInputView!

    private var newMessageViewTopConstraint: Constraint!
    private var chatInputViewBottomConstraint: Constraint!

    private var didAddNewMessageInLastUpdate = false
    private var newMessagesViewVisible = false

    init(theme: Theme, chat: OCTChat, submanagerChats: OCTSubmanagerChats, submanagerObjects: OCTSubmanagerObjects, delegate: ChatPrivateControllerDelegate) {
        self.theme = theme
        self.chat = chat
        self.friend = chat.friends.lastObject() as! OCTFriend
        self.submanagerChats = submanagerChats
        self.submanagerObjects = submanagerObjects
        self.delegate = delegate

        let messagesController = submanagerObjects.fetchedResultsControllerForType(
                .MessageAbstract,
                predicate: NSPredicate(format: "chat.uniqueIdentifier == %@", chat.uniqueIdentifier),
                sortDescriptors: [RLMSortDescriptor(property: "dateInterval", ascending: false)])
        self.dataSource = PortionDataSource(controller: messagesController, portionSize:Constants.MessagesPortionSize)

        self.friendController = submanagerObjects.fetchedResultsControllerForType(
                .Friend,
                predicate: NSPredicate(format: "uniqueIdentifier == %@", friend.uniqueIdentifier))

        self.timeFormatter = NSDateFormatter(type: .Time)

        super.init()

        dataSource.delegate = self
        friendController.delegate = self
        friendController.performFetch()

        createNavigationViews()

        edgesForExtendedLayout = .None
        hidesBottomBarWhenPushed = true
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        createTableView()
        createNewMessagesView()
        createInputView()
        installConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        friendWasUpdated()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        updateLastReadDate()
        delegate?.chatPrivateControllerWillAppear(self)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        delegate?.chatPrivateControllerWillDisappear(self)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if !chatInputView.text.isEmpty {
            chatInputView.becomeFirstResponder()
        }
    }

    override func keyboardWillShowAnimated(keyboardFrame frame: CGRect) {
        super.keyboardWillShowAnimated(keyboardFrame: frame)

        chatInputViewBottomConstraint.updateOffset(-frame.size.height)
        view.layoutIfNeeded()
    }

    override func keyboardWillHideAnimated(keyboardFrame frame: CGRect) {
        super.keyboardWillHideAnimated(keyboardFrame: frame)

        chatInputViewBottomConstraint.updateOffset(0.0)
        view.layoutIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateInputViewMaxHeight()
    }
}

// MARK: Actions
extension ChatPrivateController {
    func tapOnTableView() {
        chatInputView.resignFirstResponder()
    }

    func panOnTableView(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(recognizer.view)
        recognizer.setTranslation(CGPointZero, inView: recognizer.view)

        _ = tableView.visibleCells.filter {
            $0 is ChatMovableDateCell
        }.map {
            $0 as! ChatMovableDateCell
        }.map {
            switch recognizer.state {
                case .Possible:
                    fallthrough
                case .Began:
                    // nop
                    break
                case .Changed:
                    $0.movableOffset += translation.x
                case .Ended:
                    fallthrough
                case .Cancelled:
                    fallthrough
                case .Failed:
                    let cell = $0
                    UIView.animateWithDuration(Constants.ResetPanAnimationDuration) {
                        cell.movableOffset = 0.0
                    }
            }
        }
    }

    func newMessagesViewPressed() {
        tableView.setContentOffset(CGPointZero, animated: true)

        // iOS is broken =\
        // See https://stackoverflow.com/a/30804874
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            self?.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }
}

extension ChatPrivateController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = dataSource.objectAtIndexPath(indexPath) as! OCTMessageAbstract

        let model: ChatMovableDateCellModel
        let cell: ChatMovableDateCell

        if message.isOutgoing() {
            if message.messageText != nil {
                let outgoingModel = ChatOutgoingTextCellModel()
                outgoingModel.message = message.messageText.text
                model = outgoingModel

                cell = tableView.dequeueReusableCellWithIdentifier(ChatOutgoingTextCell.staticReuseIdentifier) as! ChatOutgoingTextCell
            }
            else {
                model = ChatMovableDateCellModel()
                cell = tableView.dequeueReusableCellWithIdentifier(ChatMovableDateCell.staticReuseIdentifier) as! ChatMovableDateCell
            }
        }
        else {
            if message.messageText != nil {
                let incomingModel = ChatIncomingTextCellModel()
                incomingModel.message = message.messageText.text
                model = incomingModel

                cell = tableView.dequeueReusableCellWithIdentifier(ChatIncomingTextCell.staticReuseIdentifier) as! ChatIncomingTextCell
            }
            else {
                model = ChatMovableDateCellModel()
                cell = tableView.dequeueReusableCellWithIdentifier(ChatMovableDateCell.staticReuseIdentifier) as! ChatMovableDateCell
            }
        }


        model.dateString = timeFormatter.stringFromDate(message.date())

        cell.setupWithTheme(theme, model: model)
        cell.transform = tableView.transform;

        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfObjects()
    }
}

extension ChatPrivateController: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            toggleNewMessageView(show: false)
        }
    }
}

extension ChatPrivateController: UIScrollViewDelegate
{
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard scrollView === tableView else {
            return
        }

        if tableView.contentOffset.y > (tableView.contentSize.height - tableView.frame.size.height) {
            if dataSource.increaseLimit() {
                tableView.reloadData()
            }
        }
    }
}

extension ChatPrivateController: PortionDataSourceDelegate {
    func portionDataSourceBeginUpdates() {
        tableView.beginUpdates()
    }

    func portionDataSourceEndUpdates() {
        ExceptionHandling.tryWithBlock({ [unowned self] in
            self.tableView.endUpdates()
        }) { [unowned self] _ in
            self.dataSource.reset()
            self.tableView.reloadData()
        }

        if didAddNewMessageInLastUpdate {
            didAddNewMessageInLastUpdate = false
            handleNewMessage()
        }

        // workaround for deadlock in objcTox https://github.com/Antidote-for-Tox/objcTox/issues/51
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            self?.updateLastReadDate()
        }
    }

    func portionDataSourceInsertObjectAtIndexPath(indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            didAddNewMessageInLastUpdate = true
        }

        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
    }

    func portionDataSourceDeleteObjectAtIndexPath(indexPath: NSIndexPath) {
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    func portionDataSourceReloadObjectAtIndexPath(indexPath: NSIndexPath) {
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }

    func portionDataSourceMoveObjectAtIndexPath(indexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        tableView.insertRowsAtIndexPaths([toIndexPath], withRowAnimation: .Automatic)
    }

}

extension ChatPrivateController: RBQFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: RBQFetchedResultsController) {
        if controller === friendController {
            friendWasUpdated()
        }
    }
}

extension ChatPrivateController: ChatInputViewDelegate {
    func chatInputViewSendButtonPressed(view: ChatInputView) {
        do {
            try submanagerChats.sendMessageToChat(chat, text: view.text, type: .Normal)

            view.text = ""
            submanagerObjects.changeChat(chat, enteredText: "")
        }
        catch {

        }
    }

    func chatInputViewTextDidChange(view: ChatInputView) {
        submanagerObjects.changeChat(chat, enteredText: view.text)
    }
}

extension ChatPrivateController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGR = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }

        let translation = panGR.translationInView(panGR.view)

        return fabsf(Float(translation.x)) > fabsf(Float(translation.y))
    }
}

private extension ChatPrivateController {
    func createNavigationViews() {
        titleView = ChatPrivateTitleView(theme: theme)
        navigationItem.titleView = titleView
    }

    func createTableView() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0)
        tableView.scrollsToTop = false
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 44.0
        tableView.backgroundColor = theme.colorForType(.NormalBackground)
        tableView.separatorStyle = .None

        view.addSubview(tableView)

        tableView.registerClass(ChatMovableDateCell.self, forCellReuseIdentifier: ChatMovableDateCell.staticReuseIdentifier)
        tableView.registerClass(ChatIncomingTextCell.self, forCellReuseIdentifier: ChatIncomingTextCell.staticReuseIdentifier)
        tableView.registerClass(ChatOutgoingTextCell.self, forCellReuseIdentifier: ChatOutgoingTextCell.staticReuseIdentifier)

        let tapGR = UITapGestureRecognizer(target: self, action: "tapOnTableView")
        tableView.addGestureRecognizer(tapGR)

        let panGR = UIPanGestureRecognizer(target: self, action: "panOnTableView:")
        panGR.delegate = self
        tableView.addGestureRecognizer(panGR)
    }

    func createNewMessagesView() {
        newMessagesView = UIView()
        newMessagesView.backgroundColor = theme.colorForType(.ConnectingBackground)
        newMessagesView.layer.cornerRadius = 5.0
        newMessagesView.layer.masksToBounds = true
        newMessagesView.hidden = true
        view.addSubview(newMessagesView)

        let label = UILabel()
        label.text = String(localized: "chat_new_messages")
        label.textColor = theme.colorForType(.ConnectingText)
        label.backgroundColor = .clearColor()
        label.font = UIFont.systemFontOfSize(12.0)
        newMessagesView.addSubview(label)

        let button = UIButton()
        button.addTarget(self, action: "newMessagesViewPressed", forControlEvents: .TouchUpInside)
        newMessagesView.addSubview(button)

        label.snp_makeConstraints {
            $0.left.equalTo(newMessagesView).offset(Constants.NewMessageViewEdgesOffset)
            $0.right.equalTo(newMessagesView).offset(-Constants.NewMessageViewEdgesOffset)
            $0.top.equalTo(newMessagesView).offset(Constants.NewMessageViewEdgesOffset)
            $0.bottom.equalTo(newMessagesView).offset(-Constants.NewMessageViewEdgesOffset)
        }

        button.snp_makeConstraints {
            $0.edges.equalTo(newMessagesView)
        }
    }

    func createInputView() {
        chatInputView = ChatInputView(theme: theme)
        chatInputView.text = chat.enteredText
        chatInputView.delegate = self
        view.addSubview(chatInputView)
    }

    func installConstraints() {
        tableView.snp_makeConstraints {
            $0.top.left.right.equalTo(view)
        }

        newMessagesView.snp_makeConstraints {
            $0.centerX.equalTo(tableView)
            newMessageViewTopConstraint = $0.top.equalTo(chatInputView.snp_top).constraint
        }

        chatInputView.snp_makeConstraints {
            $0.left.right.equalTo(view)
            $0.top.equalTo(tableView.snp_bottom)
            $0.top.greaterThanOrEqualTo(view).offset(Constants.InputViewTopOffset)
            chatInputViewBottomConstraint = $0.bottom.equalTo(view).constraint
        }
    }

    func updateInputViewMaxHeight() {
        chatInputView.maxHeight = chatInputView.frame.origin.y - Constants.InputViewTopOffset
    }

    func handleNewMessage() {
        guard let visible = tableView.indexPathsForVisibleRows else {
            return
        }

        let first = NSIndexPath(forRow: 0, inSection: 0)

        if !visible.contains(first) {
            toggleNewMessageView(show: true)
        }
    }

    func toggleNewMessageView(show show: Bool) {
        guard show != newMessagesViewVisible else {
            return
        }
        newMessagesViewVisible = show

        if show {
            newMessagesView.hidden = false
        }

        UIView.animateWithDuration(Constants.NewMessageViewAnimationDuration, animations: {
            if show {
                self.newMessageViewTopConstraint.updateOffset(Constants.NewMessageViewTopOffset - self.newMessagesView.frame.size.height)
            }
            else {
                self.newMessageViewTopConstraint.updateOffset(0.0)
            }

            self.view.layoutIfNeeded()

        }, completion: { finished in
            if !show {
                self.newMessagesView.hidden = true
            }
        })
    }

    func updateLastReadDate() {
        submanagerObjects.changeChat(chat, lastReadDateInterval: NSDate().timeIntervalSince1970)
    }

    func friendWasUpdated() {
        titleView.name = friend.nickname
        titleView.userStatus = UserStatus(connectionStatus: friend.connectionStatus, userStatus: friend.status)

        chatInputView.sendButtonEnabled = friend.isConnected
    }
}
