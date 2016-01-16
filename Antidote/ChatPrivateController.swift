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

    static let PrependingTableOffsetY: CGFloat = 100.0

    static let InputViewTopOffset: CGFloat = 50.0

    static let NewMessageViewAllowedDelta: CGFloat = 20.0
    static let NewMessageViewEdgesOffset: CGFloat = 5.0
    static let NewMessageViewTopOffset: CGFloat = -15.0
    static let NewMessageViewAnimationDuration = 0.2

    static let ResetPanAnimationDuration = 0.3
}

class ChatPrivateController: KeyboardNotificationController {
    private let theme: Theme
    private let chat: OCTChat
    private let submanagerChats: OCTSubmanagerChats

    private let dataSource: PortionDataSource

    private let timeFormatter: NSDateFormatter

    private var tableView: UITableView!
    private var newMessagesView: UIView!
    private var chatInputView: ChatInputView!

    private var newMessageViewTopConstraint: Constraint!
    private var chatInputViewBottomConstraint: Constraint!

    private var didAddNewMessageInLastUpdate = false
    private var newMessagesViewVisible = false

    init(theme: Theme, chat: OCTChat, submanagerChats: OCTSubmanagerChats, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme
        self.chat = chat
        self.submanagerChats = submanagerChats

        let messagesController = submanagerObjects.fetchedResultsControllerForType(
                .MessageAbstract,
                predicate: NSPredicate(format: "chat.uniqueIdentifier == %@", chat.uniqueIdentifier),
                sortDescriptors: [RLMSortDescriptor(property: "dateInterval", ascending: true)])
        self.dataSource = PortionDataSource(controller: messagesController, portionSize:Constants.MessagesPortionSize)

        self.timeFormatter = NSDateFormatter(type: .Time)

        super.init()

        dataSource.delegate = self

        addNavigationButtons()

        edgesForExtendedLayout = .None
        hidesBottomBarWhenPushed = true

        let friend = chat.friends.lastObject() as! OCTFriend
        title = friend.nickname
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

        tableView.reloadData()
        scrollToLastMessage(animated: false)
    }

    override func keyboardWillShowAnimated(keyboardFrame frame: CGRect) {
        super.keyboardWillShowAnimated(keyboardFrame: frame)

        chatInputViewBottomConstraint.updateOffset(-frame.size.height)
        view.layoutIfNeeded()

        let maxOffsetY = max(0.0, tableView.contentSize.height - tableView.frame.size.height)

        var offsetY = tableView.contentOffset.y + frame.size.height

        if offsetY > maxOffsetY {
            offsetY = maxOffsetY
        }
        tableView.contentOffset.y = offsetY
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

        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfObjects()
    }
}

extension ChatPrivateController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == (dataSource.numberOfObjects() - 1) {
            toggleNewMessageView(show: false)
        }
    }
}

extension ChatPrivateController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard scrollView === tableView else {
            return
        }

        if (tableView.contentOffset.y < Constants.PrependingTableOffsetY) {
            let heightBefore = tableView.contentSize.height
            let numberBefore = dataSource.numberOfObjects()

            if dataSource.increaseLimit() {
                let animations = UIView.areAnimationsEnabled()
                UIView.setAnimationsEnabled(false)

                let numberDelta = dataSource.numberOfObjects() - numberBefore
                let indexPaths = (0..<numberDelta).map {
                    return NSIndexPath(forRow: $0, inSection: 0)
                }

                tableView.beginUpdates()
                tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
                tableView.endUpdates()

                let delta = tableView.contentSize.height - heightBefore

                var offset = tableView.contentOffset
                offset.y += delta
                tableView.setContentOffset(offset, animated: false)

                UIView.setAnimationsEnabled(animations)
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
    }

    func portionDataSourceInsertObjectAtIndexPath(indexPath: NSIndexPath) {
        if indexPath.row == (dataSource.numberOfObjects() - 1) {
            didAddNewMessageInLastUpdate = true
        }

        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
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

extension ChatPrivateController: ChatInputViewDelegate {
    func chatInputViewSendButtonPressed(view: ChatInputView) {
        do {
            try submanagerChats.sendMessageToChat(chat, text: view.text, type: .Normal)
            view.text = ""
        }
        catch {

        }
    }

    func tapOnTableView() {
        chatInputView.resignFirstResponder()
    }

    func panOnTableView(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(recognizer.view)
        recognizer.setTranslation(CGPointZero, inView: recognizer.view)

        let cells = tableView.visibleCells.filter {
            $0 is ChatMovableDateCell
        }.map {
            $0 as! ChatMovableDateCell
        }.each {
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
        scrollToLastMessage(animated: true)
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
    func addNavigationButtons() {}

    func createTableView() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
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
        chatInputView.delegate = self
        view.addSubview(chatInputView)
    }

    func installConstraints() {
        tableView.snp_makeConstraints {
            $0.top.left.right.equalTo(view)
        }

        newMessagesView.snp_makeConstraints {
            $0.centerX.equalTo(tableView)
            newMessageViewTopConstraint = $0.top.equalTo(tableView.snp_bottom).constraint
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

        let penultimate = NSIndexPath(forRow: dataSource.numberOfObjects() - 2, inSection: 0)

        if visible.contains(penultimate) {
            scrollToLastMessage(animated: true)
        }
        else {
            toggleNewMessageView(show: true)
        }
    }

    func scrollToLastMessage(animated animated: Bool) {
        let count = dataSource.numberOfObjects()

        guard count > 0 else {
            return
        }

        let path = NSIndexPath(forRow: count-1, inSection: 0)
        tableView.scrollToRowAtIndexPath(path, atScrollPosition: .Bottom, animated: animated)
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
}
