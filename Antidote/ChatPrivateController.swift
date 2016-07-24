//
//  ChatPrivateController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 13.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit
import MobileCoreServices
import Photos

private struct Constants {
    static let MessagesPortionSize = 50

    static let InputViewTopOffset: CGFloat = 50.0

    static let NewMessageViewAllowedDelta: CGFloat = 20.0
    static let NewMessageViewEdgesOffset: CGFloat = 5.0
    static let NewMessageViewTopOffset: CGFloat = -15.0
    static let NewMessageViewAnimationDuration = 0.2

    static let ResetPanAnimationDuration = 0.3

    static let MaxImageSizeToShowInline: OCTToxFileSize = 20 * 1024 * 1024

    static let MaxInlineImageSide: CGFloat = LoadingImageView.Constants.ImageButtonSize * UIScreen.mainScreen().scale
}

protocol ChatPrivateControllerDelegate: class {
    func chatPrivateControllerWillAppear(controller: ChatPrivateController)
    func chatPrivateControllerWillDisappear(controller: ChatPrivateController)
    func chatPrivateControllerCallToChat(controller: ChatPrivateController, enableVideo: Bool)
    func chatPrivateControllerShowQuickLookController(
            controller: ChatPrivateController,
            dataSource: QuickLookPreviewControllerDataSource,
            selectedIndex: Int)
}

class ChatPrivateController: KeyboardNotificationController {
    let chat: OCTChat

    private weak var delegate: ChatPrivateControllerDelegate?

    private let theme: Theme
    private weak var submanagerChats: OCTSubmanagerChats!
    private weak var submanagerObjects: OCTSubmanagerObjects!
    private weak var submanagerFiles: OCTSubmanagerFiles!

    private let messages: Results<OCTMessageAbstract>
    private var messagesToken: RLMNotificationToken?
    private var visibleMessages: Int
    
    private let friend: OCTFriend
    private var friendToken: RLMNotificationToken?

    private let imageCache = NSCache()

    private let timeFormatter: NSDateFormatter

    private var audioButton: UIBarButtonItem!
    private var videoButton: UIBarButtonItem!

    private var titleView: ChatPrivateTitleView!
    private var tableView: UITableView?
    private var newMessagesView: UIView!
    private var chatInputView: ChatInputView!
    private var editMessagesToolbar: UIToolbar!

    private var tableViewTapGestureRecognizer: UITapGestureRecognizer!

    private var newMessageViewTopConstraint: Constraint!
    private var chatInputViewBottomConstraint: Constraint!

    private var newMessagesViewVisible = false

    /// Index path for cell with UIMenu presented.
    private var selectedMenuIndexPath: NSIndexPath?

    init(theme: Theme, chat: OCTChat, submanagerChats: OCTSubmanagerChats, submanagerObjects: OCTSubmanagerObjects, submanagerFiles: OCTSubmanagerFiles, delegate: ChatPrivateControllerDelegate) {
        self.theme = theme
        self.chat = chat
        self.friend = chat.friends.lastObject() as! OCTFriend
        self.submanagerChats = submanagerChats
        self.submanagerObjects = submanagerObjects
        self.submanagerFiles = submanagerFiles
        self.delegate = delegate

        let predicate = NSPredicate(format: "chatUniqueIdentifier == %@", chat.uniqueIdentifier)
        self.messages = submanagerObjects.messages(predicate: predicate).sortedResultsUsingProperty("dateInterval", ascending: false)
        self.visibleMessages = Constants.MessagesPortionSize

        self.timeFormatter = NSDateFormatter(type: .Time)

        super.init()

        edgesForExtendedLayout = .None
        hidesBottomBarWhenPushed = true

        NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: #selector(ChatPrivateController.applicationDidBecomeActive),
                name: UIApplicationDidBecomeActiveNotification,
                object: nil)

        NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: #selector(ChatPrivateController.willShowMenuNotification(_:)),
                name: UIMenuControllerWillShowMenuNotification,
                object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: #selector(ChatPrivateController.willHideMenuNotification),
                name: UIMenuControllerWillHideMenuNotification,
                object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)

        messagesToken?.stop()
        friendToken?.stop()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        createTableView()
        createNewMessagesView()
        createInputView()
        createEditMessageToolbar()
        installConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addMessagesNotification()

        createNavigationViews()
        addFriendNotification()
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
        guard let tableView = tableView else {
            return
        }

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
        guard let tableView = tableView else {
            return
        }

        tableView.setContentOffset(CGPointZero, animated: true)

        // iOS is broken =\
        // See https://stackoverflow.com/a/30804874
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            self?.tableView?.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        }
    }

    func audioCallButtonPressed() {
        delegate?.chatPrivateControllerCallToChat(self, enableVideo: false)
    }

    func videoCallButtonPressed() {
        delegate?.chatPrivateControllerCallToChat(self, enableVideo: true)
    }

    func editMessagesDeleteButtonPressed(barButtonItem: UIBarButtonItem) {
        guard let selectedRows = tableView?.indexPathsForSelectedRows else {
            return
        }

        showMessageDeletionConfirmation(messagesCount: selectedRows.count,
                                        showFromItem: barButtonItem,
                                        deleteClosure: { [unowned self] _ -> Void in
            self.toggleTableViewEditing(false, animated: true)

            let toRemove = selectedRows.map {
                return self.messages[$0.row]
            }

            self.submanagerChats.removeMessages(toRemove)
        })
    }

    func deleteAllMessagesButtonPressed(barButtonItem: UIBarButtonItem) {
        toggleTableViewEditing(false, animated: true)

        showMessageDeletionConfirmation(messagesCount: messages.count,
                                        showFromItem: barButtonItem,
                                        deleteClosure: { [unowned self] _ -> Void in
            self.submanagerChats.removeAllMessagesInChat(self.chat, removeChat: false)
        })
    }

    func cancelEditingButtonPressed() {
        toggleTableViewEditing(false, animated: true)
    }
}

// MARK: Notifications
extension ChatPrivateController {
    func applicationDidBecomeActive() {
        updateLastReadDate()
    }

    func willShowMenuNotification(notification: NSNotification) {
        guard let indexPath = selectedMenuIndexPath else {
            return
        }
        guard let cell = tableView?.cellForRowAtIndexPath(indexPath) else {
            return
        }
        guard let editable = cell as? ChatEditable else {
            return
        }
        guard let menu = notification.object as? UIMenuController else {
            return
        }

        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIMenuControllerWillShowMenuNotification, object: nil)

        menu.setMenuVisible(false, animated: false)

        let rect = cell.convertRect(editable.menuTargetRect(), toView: view)

        menu.setTargetRect(rect, inView: view)
        menu.setMenuVisible(true, animated: true)

        NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: #selector(ChatPrivateController.willShowMenuNotification(_:)),
                name: UIMenuControllerWillShowMenuNotification,
                object: nil)
    }

    func willHideMenuNotification() {
        guard let indexPath = selectedMenuIndexPath else {
            return
        }
        selectedMenuIndexPath = nil

        guard let editable = tableView?.cellForRowAtIndexPath(indexPath) as? ChatEditable else {
            return
        }

        editable.willHideMenu()
    }
}

extension ChatPrivateController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]

        // setting default values to avoid crash
        var model: ChatMovableDateCellModel  = ChatMovableDateCellModel()
        var cell: ChatMovableDateCell  = tableView.dequeueReusableCellWithIdentifier(ChatMovableDateCell.staticReuseIdentifier) as! ChatMovableDateCell

        if message.isOutgoing() {
            if let messageText = message.messageText {
                let outgoingModel = ChatBaseTextCellModel()
                outgoingModel.message = messageText.text ?? ""
                model = outgoingModel

                cell = tableView.dequeueReusableCellWithIdentifier(ChatOutgoingTextCell.staticReuseIdentifier) as! ChatOutgoingTextCell
            }
            else if let messageCall = message.messageCall {
                let outgoingModel = ChatOutgoingCallCellModel()
                outgoingModel.callDuration = messageCall.callDuration
                outgoingModel.answered = (messageCall.callEvent == .Answered)
                model = outgoingModel

                cell = tableView.dequeueReusableCellWithIdentifier(ChatOutgoingCallCell.staticReuseIdentifier) as! ChatOutgoingCallCell
            }
            else if let _ = message.messageFile {
                (model, cell) = imageCellWithMessage(message, incoming: false)
            }
        }
        else {
            if let messageText = message.messageText {
                let incomingModel = ChatBaseTextCellModel()
                incomingModel.message = messageText.text ?? ""
                model = incomingModel

                cell = tableView.dequeueReusableCellWithIdentifier(ChatIncomingTextCell.staticReuseIdentifier) as! ChatIncomingTextCell
            }
            else if let messageCall = message.messageCall {
                let incomingModel = ChatIncomingCallCellModel()
                incomingModel.callDuration = messageCall.callDuration
                incomingModel.answered = (messageCall.callEvent == .Answered)
                model = incomingModel

                cell = tableView.dequeueReusableCellWithIdentifier(ChatIncomingCallCell.staticReuseIdentifier) as! ChatIncomingCallCell
            }
            else if let _ = message.messageFile {
                (model, cell) = imageCellWithMessage(message, incoming: true)
            }
        }

        model.dateString = timeFormatter.stringFromDate(message.date())

        cell.delegate = self
        cell.setupWithTheme(theme, model: model)
        cell.transform = tableView.transform;

        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(visibleMessages, messages.count)
    }
}

extension ChatPrivateController: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            toggleNewMessageView(show: false)
        }

        maybeLoadImageForCellAtPath(cell, indexPath: indexPath)
    }

    func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard !tableView.editing else {
            return false
        }
        guard let editable = tableView.cellForRowAtIndexPath(indexPath) as? ChatEditable else {
            return false
        }

        if !editable.shouldShowMenu() {
            return false
        }

        selectedMenuIndexPath = indexPath
        editable.willShowMenu()

        return true
    }

    func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChatMovableDateCell else {
            return false
        }

        return cell.isMenuActionSupportedByCell(action)
    }

    func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        // Dummy method to make tableView:shouldShowMenuForRowAtIndexPath: work.
    }
}

extension ChatPrivateController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard let tableView = tableView else {
            return
        }
        guard scrollView === tableView else {
            return
        }

        if tableView.contentOffset.y > (tableView.contentSize.height - tableView.frame.size.height) {
            let previous = visibleMessages

            visibleMessages = visibleMessages + Constants.MessagesPortionSize

            if visibleMessages > messages.count {
                visibleMessages = messages.count
            }

            if visibleMessages != previous {
                tableView.reloadData()
            }
        }
    }
}

extension ChatPrivateController: ChatMovableDateCellDelegate {
    func chatMovableDateCellCopyPressed(cell: ChatMovableDateCell) {
        guard let indexPath = tableView?.indexPathForCell(cell) else {
            return
        }

        let message = messages[indexPath.row]

        if let messageText = message.messageText {
            UIPasteboard.generalPasteboard().string = messageText.text
        }
        else if let _ = message.messageCall {
            fatalError("Message call cannot be copied")
        }
        else if let messageFile = message.messageFile {
            guard UTTypeConformsTo(messageFile.fileUTI ?? "", kUTTypeImage) else {
                fatalError("Cannot copy non-image file")
            }
            guard let file = messageFile.filePath() else {
                assertionFailure("Tried to copy non-existing file")
                return
            }
            guard let image = UIImage(contentsOfFile: file) else {
                assertionFailure("Cannot create image from file")
                return
            }

            UIPasteboard.generalPasteboard().image = image
        }
    }

    func chatMovableDateCellDeletePressed(cell: ChatMovableDateCell) {
        guard let indexPath = tableView?.indexPathForCell(cell) else {
            return
        }

        let message = messages[indexPath.row]

        submanagerChats.removeMessages([message])
    }

    func chatMovableDateCellMorePressed(cell: ChatMovableDateCell) {
        toggleTableViewEditing(true, animated: true)

        // TODO select row
        // guard let indexPath = tableView?.indexPathForCell(cell) else {
        //     return
        // }

        // tableView?.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
    }
}

extension ChatPrivateController: ChatInputViewDelegate {
    func chatInputViewCameraButtonPressed(view: ChatInputView, cameraView: UIView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.popoverPresentationController?.sourceView = cameraView
        alert.popoverPresentationController?.sourceRect = CGRect(x: cameraView.frame.size.width / 2, y: cameraView.frame.size.height / 2, width: 1.0, height: 1.0)

        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            alert.addAction(UIAlertAction(title: String(localized: "photo_from_camera"), style: .Default) { [unowned self] _ -> Void in
                let controller = UIImagePickerController()
                controller.sourceType = .Camera
                controller.delegate = self
                self.presentViewController(controller, animated: true, completion: nil)
            })
        }

        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            alert.addAction(UIAlertAction(title: String(localized: "photo_from_photo_library"), style: .Default) { [unowned self] _ -> Void in
                let controller = UIImagePickerController()
                controller.sourceType = .PhotoLibrary
                controller.delegate = self
                self.presentViewController(controller, animated: true, completion: nil)
            })
        }

        alert.addAction(UIAlertAction(title: String(localized: "alert_cancel"), style: .Cancel, handler: nil))

        presentViewController(alert, animated: true, completion: nil)
    }

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

extension ChatPrivateController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)

        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        guard let data = UIImageJPEGRepresentation(image, 0.9) else {
            return
        }

        var fileName: String? = fileNameFromImageInfo(info)

        if fileName == nil {
            let dateString = NSDateFormatter(type: .DateAndTime).stringFromDate(NSDate())
            fileName = "Photo \(dateString).jpg"
        }

        submanagerFiles.sendData(data, withFileName: fileName!, toChat: chat) { error in
            handleErrorWithType(.SendFileToFriend, error: error)
        }
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ChatPrivateController: UINavigationControllerDelegate {}

private extension ChatPrivateController {
    func createNavigationViews() {
        titleView = ChatPrivateTitleView(theme: theme)
        navigationItem.titleView = titleView

        // create correct navigation buttons
        toggleTableViewEditing(false, animated: false)
    }

    func createTableView() {
        let tableView = UITableView()
        self.tableView = tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0)
        tableView.scrollsToTop = false
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 44.0
        tableView.backgroundColor = theme.colorForType(.NormalBackground)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.separatorStyle = .None

        view.addSubview(tableView)

        tableView.registerClass(ChatMovableDateCell.self, forCellReuseIdentifier: ChatMovableDateCell.staticReuseIdentifier)
        tableView.registerClass(ChatIncomingTextCell.self, forCellReuseIdentifier: ChatIncomingTextCell.staticReuseIdentifier)
        tableView.registerClass(ChatOutgoingTextCell.self, forCellReuseIdentifier: ChatOutgoingTextCell.staticReuseIdentifier)
        tableView.registerClass(ChatIncomingCallCell.self, forCellReuseIdentifier: ChatIncomingCallCell.staticReuseIdentifier)
        tableView.registerClass(ChatOutgoingCallCell.self, forCellReuseIdentifier: ChatOutgoingCallCell.staticReuseIdentifier)
        tableView.registerClass(ChatIncomingFileCell.self, forCellReuseIdentifier: ChatIncomingFileCell.staticReuseIdentifier)
        tableView.registerClass(ChatOutgoingFileCell.self, forCellReuseIdentifier: ChatOutgoingFileCell.staticReuseIdentifier)

        tableViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatPrivateController.tapOnTableView))
        tableView.addGestureRecognizer(tableViewTapGestureRecognizer)

        let panGR = UIPanGestureRecognizer(target: self, action: #selector(ChatPrivateController.panOnTableView(_:)))
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
        button.addTarget(self, action: #selector(ChatPrivateController.newMessagesViewPressed), forControlEvents: .TouchUpInside)
        newMessagesView.addSubview(button)

        label.snp_makeConstraints {
            $0.leading.equalTo(newMessagesView).offset(Constants.NewMessageViewEdgesOffset)
            $0.trailing.equalTo(newMessagesView).offset(-Constants.NewMessageViewEdgesOffset)
            $0.top.equalTo(newMessagesView).offset(Constants.NewMessageViewEdgesOffset)
            $0.bottom.equalTo(newMessagesView).offset(-Constants.NewMessageViewEdgesOffset)
        }

        button.snp_makeConstraints {
            $0.edges.equalTo(newMessagesView)
        }
    }

    func createInputView() {
        chatInputView = ChatInputView(theme: theme)
        chatInputView.text = chat.enteredText ?? ""
        chatInputView.delegate = self
        view.addSubview(chatInputView)
    }

    func createEditMessageToolbar() {
        editMessagesToolbar = UIToolbar()
        editMessagesToolbar.hidden = true
        editMessagesToolbar.tintColor = theme.colorForType(.LinkText)
        editMessagesToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(ChatPrivateController.editMessagesDeleteButtonPressed(_:)))
        ]
        view.addSubview(editMessagesToolbar)
    }

    func installConstraints() {
        tableView!.snp_makeConstraints {
            $0.top.leading.trailing.equalTo(view)
        }

        newMessagesView.snp_makeConstraints {
            $0.centerX.equalTo(tableView!)
            newMessageViewTopConstraint = $0.top.equalTo(chatInputView.snp_top).constraint
        }

        chatInputView.snp_makeConstraints {
            $0.leading.trailing.equalTo(view)
            $0.top.equalTo(tableView!.snp_bottom)
            $0.top.greaterThanOrEqualTo(view).offset(Constants.InputViewTopOffset)
            chatInputViewBottomConstraint = $0.bottom.equalTo(view).constraint
        }

        editMessagesToolbar.snp_makeConstraints {
            $0.edges.equalTo(chatInputView)
        }
    }

    func addMessagesNotification() {
        self.messagesToken = messages.addNotificationBlock { [unowned self] change in
            guard let tableView = self.tableView else {
                return
            }
            switch change {
                case .Initial:
                    break
                case .Update(_, let deletions, let insertions, let modifications):
                    tableView.beginUpdates()
                    self.updateTableViewWithDeletions(deletions)
                    self.updateTableViewWithInsertions(insertions)
                    self.updateTableViewWithModifications(modifications)

                    self.visibleMessages = self.visibleMessages + insertions.count - deletions.count
                    tableView.endUpdates()

                    if insertions.contains(0) {
                        self.handleNewMessage()
                    }
                case .Error(let error):
                    fatalError("\(error)")
            }
        }
    }

    func updateTableViewWithDeletions(deletions: [Int]) {
        guard let tableView = tableView else {
            return
        }

        for index in deletions {
            if index >= visibleMessages {
                continue
            }
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
        }
    }

    func updateTableViewWithInsertions(insertions: [Int]) {
        guard let tableView = tableView else {
            return
        }

        for index in insertions {
            if index >= visibleMessages {
                continue
            }
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
        }
    }

    func updateTableViewWithModifications(modifications: [Int]) {
        guard let tableView = tableView else {
            return
        }

        for index in modifications {
            if index >= visibleMessages {
                continue
            }
            let message = messages[index]
            let indexPath = NSIndexPath(forRow: index, inSection: 0)

            if message.messageFile == nil {
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                continue
            }

            guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChatGenericFileCell else {
                continue
            }

            let model = ChatIncomingFileCellModel()
            prepareFileCell(cell, andModel: model, withMessage: message)
            cell.setupWithTheme(theme, model: model)

            maybeLoadImageForCellAtPath(cell, indexPath: indexPath)
        }
    }

    func addFriendNotification() {
        titleView.name = self.friend.nickname
        titleView.userStatus = UserStatus(connectionStatus: self.friend.connectionStatus, userStatus: self.friend.status)

        let predicate = NSPredicate(format: "uniqueIdentifier == %@", friend.uniqueIdentifier)
        let results = submanagerObjects.friends(predicate: predicate)

        friendToken = results.addNotificationBlock { [unowned self] change in
            switch change {
                case .Initial:
                    fallthrough
                case .Update:
                    self.titleView.name = self.friend.nickname
                    self.titleView.userStatus = UserStatus(connectionStatus: self.friend.connectionStatus, userStatus: self.friend.status)

                    let isConnected = self.friend.isConnected

                    self.audioButton.enabled = isConnected
                    self.videoButton.enabled = isConnected
                    self.chatInputView.buttonsEnabled = isConnected
                case .Error(let error):
                    fatalError("\(error)")
            }
        }
    }

    func updateInputViewMaxHeight() {
        chatInputView.maxHeight = CGRectGetMaxY(chatInputView.frame) - Constants.InputViewTopOffset
    }

    func handleNewMessage() {
        if UIApplication.isActive {
            updateLastReadDate()
        }

        guard let tableView = tableView else {
            return
        }
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

    func imageCellWithMessage(message: OCTMessageAbstract, incoming: Bool) -> (ChatMovableDateCellModel, ChatMovableDateCell) {
        let cell: ChatGenericFileCell

        if incoming {
            cell = tableView!.dequeueReusableCellWithIdentifier(ChatIncomingFileCell.staticReuseIdentifier) as! ChatIncomingFileCell
        }
        else {
            cell = tableView!.dequeueReusableCellWithIdentifier(ChatOutgoingFileCell.staticReuseIdentifier) as! ChatOutgoingFileCell
        }
        let model = ChatIncomingFileCellModel()

        prepareFileCell(cell, andModel: model, withMessage: message)

        return (model, cell)
    }

    func prepareFileCell(cell: ChatGenericFileCell, andModel model: ChatGenericFileCellModel, withMessage message: OCTMessageAbstract) {
        cell.progressObject = nil

        model.fileName = message.messageFile!.fileName
        model.fileSize = NSByteCountFormatter.stringFromByteCount(message.messageFile!.fileSize, countStyle: .File)
        model.fileUTI = message.messageFile!.fileUTI

        switch message.messageFile!.fileType {
            case .WaitingConfirmation:
                model.state = .WaitingConfirmation
            case .Loading:
                model.state = .Loading

                let bridge = ChatProgressBridge()
                cell.progressObject = bridge
                _ = try? self.submanagerFiles.addProgressSubscriber(bridge, forFileTransfer: message)
            case .Paused:
                model.state = .Paused
            case .Canceled:
                model.state = .Cancelled
            case .Ready:
                model.state = .Done
        }

        if !message.isOutgoing() {
            model.startLoadingHandle = { [weak self] in
                self?.submanagerFiles.acceptFileTransfer(message) { error -> Void in
                    handleErrorWithType(.AcceptIncomingFile, error: error)
                }
            }
        }

        model.cancelHandle = { [weak self] in
            do {
                try self?.submanagerFiles.cancelFileTransfer(message)
            }
            catch let error as NSError {
                handleErrorWithType(.CancelFileTransfer, error: error)
            }
        }

        model.retryHandle = { [weak self] in
            self?.submanagerFiles.retrySendingFile(message) { error in
                handleErrorWithType(.SendFileToFriend, error: error)
            }
        }

        model.pauseOrResumeHandle = { [weak self] in
            let isPaused = (message.messageFile!.pausedBy.rawValue & OCTMessageFilePausedBy.User.rawValue) != 0

            do {
                try self?.submanagerFiles.pauseFileTransfer(!isPaused, message: message)
            }
            catch let error as NSError {
                handleErrorWithType(.CancelFileTransfer, error: error)
            }
        }

        model.openHandle = { [weak self] in
            guard let sself = self else {
                return
            }
            let qlDataSource = FilePreviewControllerDataSource(chat: sself.chat, submanagerObjects: sself.submanagerObjects)
            guard let index = qlDataSource.indexOfMessage(message) else {
                return
            }

            sself.delegate?.chatPrivateControllerShowQuickLookController(sself, dataSource: qlDataSource, selectedIndex: index)
        }
    }

    func maybeLoadImageForCellAtPath(cell: UITableViewCell, indexPath: NSIndexPath) {
        let message = messages[indexPath.row]

        guard let messageFile = message.messageFile else {
            return
        }

        guard UTTypeConformsTo(messageFile.fileUTI ?? "", kUTTypeImage) else {
            return
        }

        guard let file = messageFile.filePath() else {
            return
        }

        if messageFile.fileSize >= Constants.MaxImageSizeToShowInline {
            return
        }

        if let image = imageCache.objectForKey(file) as? UIImage {
            let cell = (cell as? ChatIncomingFileCell) ?? (cell as? ChatOutgoingFileCell)

            cell?.setButtonImage(image)
        }
        else {
            loadImageForCellAtIndexPath(indexPath, fromFile: file)
        }
    }

    func loadImageForCellAtIndexPath(indexPath: NSIndexPath, fromFile: String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { [weak self] in
            guard var image = UIImage(contentsOfFile: fromFile) else {
                return
            }

            var size = image.size
            guard size.width > 0 || size.height > 0 else {
                return
            }

            let delta = (size.width > size.height) ? (Constants.MaxInlineImageSide / size.width) : (Constants.MaxInlineImageSide / size.height)

            size.width *= delta
            size.height *= delta

            image = image.scaleToSize(size)
            self?.imageCache.setObject(image, forKey: fromFile)

            dispatch_async(dispatch_get_main_queue()) {
                let optionalCell = self?.tableView?.cellForRowAtIndexPath(indexPath)
                guard let cell = (optionalCell as? ChatIncomingFileCell) ?? (optionalCell as? ChatOutgoingFileCell) else {
                    return
                }

                cell.setButtonImage(image)
            }
        }
    }

    func fileNameFromImageInfo(info: [String: AnyObject]) -> String? {
        guard let url = info[UIImagePickerControllerReferenceURL] as? NSURL else {
            return nil
        }

        let fetchResult = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil)

        guard let asset = fetchResult.firstObject as? PHAsset else {
            return nil
        }

        if #available(iOS 9.0, *) {
            if let resource = PHAssetResource.assetResourcesForAsset(asset).first {
                return resource.originalFilename
            }
        } else {
            // Fallback on earlier versions
            if let name = asset.valueForKey("filename") as? String {
                return name
            }
        }

        return nil
    }

    func toggleTableViewEditing(editing: Bool, animated: Bool) {
        tableView?.setEditing(editing, animated: animated)

        tableViewTapGestureRecognizer.enabled = !editing
        editMessagesToolbar.hidden = !editing

        if editing {
            chatInputView.resignFirstResponder()

            navigationItem.leftBarButtonItems = [UIBarButtonItem(
                title: String(localized: "delete_all_messages"),
                style: .Plain,
                target: self,
                action: #selector(ChatPrivateController.deleteAllMessagesButtonPressed(_:)))]

            navigationItem.rightBarButtonItems = [UIBarButtonItem(
                    barButtonSystemItem: .Cancel,
                    target: self,
                    action: #selector(ChatPrivateController.cancelEditingButtonPressed))]
        }
        else {
            let audioImage = UIImage(named: "start-call-medium")!
            let videoImage = UIImage(named: "video-call-medium")!

            audioButton = UIBarButtonItem(image: audioImage, style: .Plain, target: self, action: #selector(ChatPrivateController.audioCallButtonPressed))
            videoButton = UIBarButtonItem(image: videoImage, style: .Plain, target: self, action: #selector(ChatPrivateController.videoCallButtonPressed))

            navigationItem.leftBarButtonItems = nil
            navigationItem.rightBarButtonItems = [
                videoButton,
                audioButton,
            ]
        }
    }

    func showMessageDeletionConfirmation(messagesCount messagesCount: Int,
                                         showFromItem barButtonItem: UIBarButtonItem,
                                         deleteClosure: Void -> Void) {
        let deleteButtonText = messagesCount > 1 ?
            String(localized: "delete_multiple_messages") + " (\(messagesCount))" :
            String(localized: "delete_single_message")

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.popoverPresentationController?.barButtonItem = barButtonItem

        alert.addAction(UIAlertAction(title: deleteButtonText, style: .Destructive) { _ -> Void in
            deleteClosure()
        })

        alert.addAction(UIAlertAction(title: String(localized: "alert_cancel"), style: .Cancel, handler: nil))

        presentViewController(alert, animated: true, completion: nil)
    }
}
