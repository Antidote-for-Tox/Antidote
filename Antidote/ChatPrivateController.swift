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

    private let messages: RLMResults
    private var messagesToken: RLMNotificationToken?
    private var visibleMessages: Int
    
    private let friend: OCTFriend
    private var friendToken: RLMNotificationToken?

    private let imageCache = NSCache()

    private let timeFormatter: NSDateFormatter

    private var audioButton: UIBarButtonItem!
    private var videoButton: UIBarButtonItem!

    private var titleView: ChatPrivateTitleView!
    private var tableView: UITableView!
    private var newMessagesView: UIView!
    private var chatInputView: ChatInputView!

    private var newMessageViewTopConstraint: Constraint!
    private var chatInputViewBottomConstraint: Constraint!

    private var newMessagesViewVisible = false

    init(theme: Theme, chat: OCTChat, submanagerChats: OCTSubmanagerChats, submanagerObjects: OCTSubmanagerObjects, submanagerFiles: OCTSubmanagerFiles, delegate: ChatPrivateControllerDelegate) {
        self.theme = theme
        self.chat = chat
        self.friend = chat.friends.lastObject() as! OCTFriend
        self.submanagerChats = submanagerChats
        self.submanagerObjects = submanagerObjects
        self.submanagerFiles = submanagerFiles
        self.delegate = delegate

        let predicate = NSPredicate(format: "chat.uniqueIdentifier == %@", chat.uniqueIdentifier)
        self.messages = submanagerObjects.objectsForType(.MessageAbstract, predicate: predicate).sortedResultsUsingProperty("dateInterval", ascending: false)
        self.visibleMessages = Constants.MessagesPortionSize

        self.timeFormatter = NSDateFormatter(type: .Time)

        super.init()

        createNavigationViews()

        edgesForExtendedLayout = .None
        hidesBottomBarWhenPushed = true

        NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: #selector(ChatPrivateController.applicationDidBecomeActive),
                name: UIApplicationDidBecomeActiveNotification,
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
        installConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addMessagesNotification()
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

    func audioCallButtonPressed() {
        delegate?.chatPrivateControllerCallToChat(self, enableVideo: false)
    }

    func videoCallButtonPressed() {
        delegate?.chatPrivateControllerCallToChat(self, enableVideo: true)
    }
}

// MARK: Notifications
extension ChatPrivateController {
    func applicationDidBecomeActive() {
        self.updateLastReadDate()
    }
}

extension ChatPrivateController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = messages[UInt(indexPath.row)] as! OCTMessageAbstract

        // setting default values to avoid crash
        var model: ChatMovableDateCellModel  = ChatMovableDateCellModel()
        var cell: ChatMovableDateCell  = tableView.dequeueReusableCellWithIdentifier(ChatMovableDateCell.staticReuseIdentifier) as! ChatMovableDateCell

        if message.isOutgoing() {
            if let messageText = message.messageText {
                let outgoingModel = ChatOutgoingTextCellModel()
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
                let incomingModel = ChatIncomingTextCellModel()
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

        cell.setupWithTheme(theme, model: model)
        cell.transform = tableView.transform;

        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(visibleMessages, Int(messages.count))
    }
}

extension ChatPrivateController: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            toggleNewMessageView(show: false)
        }

        maybeLoadImageForCellAtPath(cell, indexPath: indexPath)
    }
}

extension ChatPrivateController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard scrollView === tableView else {
            return
        }

        if tableView.contentOffset.y > (tableView.contentSize.height - tableView.frame.size.height) {
            let previous = visibleMessages

            visibleMessages = visibleMessages + Constants.MessagesPortionSize

            if visibleMessages > Int(messages.count) {
                visibleMessages = Int(messages.count)
            }

            if visibleMessages != previous {
                tableView.reloadData()
            }
        }
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

        let audioImage = UIImage(named: "start-call-medium")!
        let videoImage = UIImage(named: "video-call-medium")!

        audioButton = UIBarButtonItem(image: audioImage, style: .Plain, target: self, action: #selector(ChatPrivateController.audioCallButtonPressed))
        videoButton = UIBarButtonItem(image: videoImage, style: .Plain, target: self, action: #selector(ChatPrivateController.videoCallButtonPressed))

        navigationItem.rightBarButtonItems = [
            audioButton,
            videoButton,
        ]
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
        tableView.registerClass(ChatIncomingCallCell.self, forCellReuseIdentifier: ChatIncomingCallCell.staticReuseIdentifier)
        tableView.registerClass(ChatOutgoingCallCell.self, forCellReuseIdentifier: ChatOutgoingCallCell.staticReuseIdentifier)
        tableView.registerClass(ChatIncomingFileCell.self, forCellReuseIdentifier: ChatIncomingFileCell.staticReuseIdentifier)
        tableView.registerClass(ChatOutgoingFileCell.self, forCellReuseIdentifier: ChatOutgoingFileCell.staticReuseIdentifier)

        let tapGR = UITapGestureRecognizer(target: self, action: #selector(ChatPrivateController.tapOnTableView))
        tableView.addGestureRecognizer(tapGR)

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

    func installConstraints() {
        tableView.snp_makeConstraints {
            $0.top.leading.trailing.equalTo(view)
        }

        newMessagesView.snp_makeConstraints {
            $0.centerX.equalTo(tableView)
            newMessageViewTopConstraint = $0.top.equalTo(chatInputView.snp_top).constraint
        }

        chatInputView.snp_makeConstraints {
            $0.leading.trailing.equalTo(view)
            $0.top.equalTo(tableView.snp_bottom)
            $0.top.greaterThanOrEqualTo(view).offset(Constants.InputViewTopOffset)
            chatInputViewBottomConstraint = $0.bottom.equalTo(view).constraint
        }
    }

    func addMessagesNotification() {
        self.messagesToken = messages.addNotificationBlock { [unowned self] _, changes, error in
            if let error = error {
                fatalError("\(error)")
            }

            guard let changes = changes else {
                return
            }

            self.visibleMessages = self.visibleMessages + changes.insertions.count - changes.deletions.count

            self.tableView.beginUpdates()

            for index in changes.insertions {
                if Int(index) >= self.visibleMessages {
                    continue
                }
                let indexPath = NSIndexPath(forRow: Int(index), inSection: 0)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
            }

            for index in changes.deletions {
                if Int(index) >= self.visibleMessages {
                    continue
                }
                let indexPath = NSIndexPath(forRow: Int(index), inSection: 0)
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
            }

            for index in changes.modifications {
                if Int(index) >= self.visibleMessages {
                    continue
                }
                let message = self.messages[UInt(index)] as! OCTMessageAbstract
                let indexPath = NSIndexPath(forRow: Int(index), inSection: 0)

                if message.messageFile == nil {
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    continue
                }

                guard let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? ChatGenericFileCell else {
                    continue
                }

                let model = ChatIncomingFileCellModel()
                self.prepareFileCell(cell, andModel: model, withMessage: message)
                cell.setupWithTheme(self.theme, model: model)

                self.maybeLoadImageForCellAtPath(cell, indexPath: indexPath)
            }

            self.tableView.endUpdates()

            if changes.insertions.contains(0) {
                self.handleNewMessage()
            }
        }
    }

    func addFriendNotification() {
        let predicate = NSPredicate(format: "uniqueIdentifier == %@", friend.uniqueIdentifier)
        let results = submanagerObjects.objectsForType(.Friend, predicate: predicate)

        friendToken = results.addNotificationBlock { [unowned self] _, change, error in
            if let error = error {
                fatalError("\(error)")
            }

            self.titleView.name = self.friend.nickname
            self.titleView.userStatus = UserStatus(connectionStatus: self.friend.connectionStatus, userStatus: self.friend.status)

            let isConnected = self.friend.isConnected

            self.audioButton.enabled = isConnected
            self.videoButton.enabled = isConnected
            self.chatInputView.buttonsEnabled = isConnected
        }
    }

    func updateInputViewMaxHeight() {
        chatInputView.maxHeight = CGRectGetMaxY(chatInputView.frame) - Constants.InputViewTopOffset
    }

    func handleNewMessage() {
        if UIApplication.isActive {
            updateLastReadDate()
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
            cell = tableView.dequeueReusableCellWithIdentifier(ChatIncomingFileCell.staticReuseIdentifier) as! ChatIncomingFileCell
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier(ChatOutgoingFileCell.staticReuseIdentifier) as! ChatOutgoingFileCell
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
        let message = messages[UInt(indexPath.row)] as! OCTMessageAbstract

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
                let optionalCell = self?.tableView.cellForRowAtIndexPath(indexPath)
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
}
