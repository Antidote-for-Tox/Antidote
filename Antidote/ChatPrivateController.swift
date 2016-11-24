// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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

    static let MaxInlineImageSide: CGFloat = LoadingImageView.Constants.ImageButtonSize * UIScreen.main.scale
}

protocol ChatPrivateControllerDelegate: class {
    func chatPrivateControllerWillAppear(_ controller: ChatPrivateController)
    func chatPrivateControllerWillDisappear(_ controller: ChatPrivateController)
    func chatPrivateControllerCallToChat(_ controller: ChatPrivateController, enableVideo: Bool)
    func chatPrivateControllerShowQuickLookController(
            _ controller: ChatPrivateController,
            dataSource: QuickLookPreviewControllerDataSource,
            selectedIndex: Int)
}

class ChatPrivateController: KeyboardNotificationController {
    let chat: OCTChat

    fileprivate weak var delegate: ChatPrivateControllerDelegate?

    fileprivate let theme: Theme
    fileprivate weak var submanagerChats: OCTSubmanagerChats!
    fileprivate weak var submanagerObjects: OCTSubmanagerObjects!
    fileprivate weak var submanagerFiles: OCTSubmanagerFiles!

    fileprivate let messages: Results<OCTMessageAbstract>
    fileprivate var messagesToken: RLMNotificationToken?
    fileprivate var visibleMessages: Int
    
    fileprivate let friend: OCTFriend?
    fileprivate var friendToken: RLMNotificationToken?

    fileprivate let imageCache = NSCache<AnyObject, AnyObject>()

    fileprivate let timeFormatter: DateFormatter

    fileprivate var audioButton: UIBarButtonItem!
    fileprivate var videoButton: UIBarButtonItem!

    fileprivate var titleView: ChatPrivateTitleView!
    fileprivate var tableView: UITableView?
    fileprivate var newMessagesView: UIView!
    fileprivate var chatInputView: ChatInputView!
    fileprivate var editMessagesToolbar: UIToolbar!

    fileprivate var tableViewTapGestureRecognizer: UITapGestureRecognizer!

    fileprivate var newMessageViewTopConstraint: Constraint?
    fileprivate var chatInputViewBottomConstraint: Constraint?

    fileprivate var newMessagesViewVisible = false

    /// Index path for cell with UIMenu presented.
    fileprivate var selectedMenuIndexPath: IndexPath?

    fileprivate var disableNextInputViewAnimation = false

    init(theme: Theme, chat: OCTChat, submanagerChats: OCTSubmanagerChats, submanagerObjects: OCTSubmanagerObjects, submanagerFiles: OCTSubmanagerFiles, delegate: ChatPrivateControllerDelegate) {
        self.theme = theme
        self.chat = chat
        self.friend = chat.friends.lastObject() as? OCTFriend
        self.submanagerChats = submanagerChats
        self.submanagerObjects = submanagerObjects
        self.submanagerFiles = submanagerFiles
        self.delegate = delegate

        let predicate = NSPredicate(format: "chatUniqueIdentifier == %@", chat.uniqueIdentifier)
        self.messages = submanagerObjects.messages(predicate: predicate).sortedResultsUsingProperty("dateInterval", ascending: false)
        self.visibleMessages = Constants.MessagesPortionSize

        self.timeFormatter = DateFormatter(type: .time)

        super.init()

        edgesForExtendedLayout = UIRectEdge()
        hidesBottomBarWhenPushed = true

        NotificationCenter.default.addObserver(
                self,
                selector: #selector(ChatPrivateController.applicationDidBecomeActive),
                name: NSNotification.Name.UIApplicationDidBecomeActive,
                object: nil)

        NotificationCenter.default.addObserver(
                self,
                selector: #selector(ChatPrivateController.willShowMenuNotification(_:)),
                name: NSNotification.Name.UIMenuControllerWillShowMenu,
                object: nil)
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(ChatPrivateController.willHideMenuNotification),
                name: NSNotification.Name.UIMenuControllerWillHideMenu,
                object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateLastReadDate()
        delegate?.chatPrivateControllerWillAppear(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        delegate?.chatPrivateControllerWillDisappear(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !chatInputView.text.isEmpty {
            disableNextInputViewAnimation = true
            _ = chatInputView.becomeFirstResponder()
        }
    }

    override func keyboardWillShowAnimated(keyboardFrame frame: CGRect) {
        super.keyboardWillShowAnimated(keyboardFrame: frame)

        guard let constraint = chatInputViewBottomConstraint else {
            return
        }

        constraint.update(offset: -frame.size.height)

        if disableNextInputViewAnimation {
            disableNextInputViewAnimation = false

            UIView.setAnimationsEnabled(false)
            view.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
        }
        else {
            view.layoutIfNeeded()
        }
    }

    override func keyboardWillHideAnimated(keyboardFrame frame: CGRect) {
        super.keyboardWillHideAnimated(keyboardFrame: frame)

        guard let constraint = chatInputViewBottomConstraint else {
            return
        }

        constraint.update(offset: 0.0)

        if disableNextInputViewAnimation {
            disableNextInputViewAnimation = false

            UIView.setAnimationsEnabled(false)
            view.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
        }
        else {
            view.layoutIfNeeded()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateInputViewMaxHeight()
    }
}

// MARK: Actions
extension ChatPrivateController {
    func tapOnTableView() {
        _ = chatInputView.resignFirstResponder()
    }

    func panOnTableView(_ recognizer: UIPanGestureRecognizer) {
        guard let tableView = tableView else {
            return
        }

        let translation = recognizer.translation(in: recognizer.view)
        recognizer.setTranslation(CGPoint.zero, in: recognizer.view)

        _ = tableView.visibleCells.filter {
            $0 is ChatMovableDateCell
        }.map {
            $0 as! ChatMovableDateCell
        }.map {
            switch recognizer.state {
                case .possible:
                    fallthrough
                case .began:
                    // nop
                    break
                case .changed:
                    $0.movableOffset += translation.x
                case .ended:
                    fallthrough
                case .cancelled:
                    fallthrough
                case .failed:
                    let cell = $0
                    UIView.animate(withDuration: Constants.ResetPanAnimationDuration, animations: {
                        cell.movableOffset = 0.0
                    }) 
            }
        }
    }

    func newMessagesViewPressed() {
        guard let tableView = tableView else {
            return
        }

        tableView.setContentOffset(CGPoint.zero, animated: true)

        // iOS is broken =\
        // See https://stackoverflow.com/a/30804874
        let delayTime = DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) { [weak self] in
            self?.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }

    func audioCallButtonPressed() {
        delegate?.chatPrivateControllerCallToChat(self, enableVideo: false)
    }

    func videoCallButtonPressed() {
        delegate?.chatPrivateControllerCallToChat(self, enableVideo: true)
    }

    func editMessagesDeleteButtonPressed(_ barButtonItem: UIBarButtonItem) {
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

    func deleteAllMessagesButtonPressed(_ barButtonItem: UIBarButtonItem) {
        toggleTableViewEditing(false, animated: true)

        showMessageDeletionConfirmation(messagesCount: messages.count,
                                        showFromItem: barButtonItem,
                                        deleteClosure: { [unowned self] _ -> Void in
            self.submanagerChats.removeAllMessages(in: self.chat, removeChat: false)
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

    func willShowMenuNotification(_ notification: Notification) {
        guard let indexPath = selectedMenuIndexPath else {
            return
        }
        guard let cell = tableView?.cellForRow(at: indexPath) else {
            return
        }
        guard let editable = cell as? ChatEditable else {
            return
        }
        guard let menu = notification.object as? UIMenuController else {
            return
        }

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIMenuControllerWillShowMenu, object: nil)

        menu.setMenuVisible(false, animated: false)

        let rect = cell.convert(editable.menuTargetRect(), to: view)

        menu.setTargetRect(rect, in: view)
        menu.setMenuVisible(true, animated: true)

        NotificationCenter.default.addObserver(
                self,
                selector: #selector(ChatPrivateController.willShowMenuNotification(_:)),
                name: NSNotification.Name.UIMenuControllerWillShowMenu,
                object: nil)
    }

    func willHideMenuNotification() {
        guard let indexPath = selectedMenuIndexPath else {
            return
        }
        selectedMenuIndexPath = nil

        guard let editable = tableView?.cellForRow(at: indexPath) as? ChatEditable else {
            return
        }

        editable.willHideMenu()
    }
}

extension ChatPrivateController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]

        // setting default values to avoid crash
        var model: ChatMovableDateCellModel  = ChatMovableDateCellModel()
        var cell: ChatMovableDateCell  = tableView.dequeueReusableCell(withIdentifier: ChatMovableDateCell.staticReuseIdentifier) as! ChatMovableDateCell

        if message.isOutgoing() {
            if let messageText = message.messageText {
                let outgoingModel = ChatOutgoingTextCellModel()
                outgoingModel.message = messageText.text ?? ""
                outgoingModel.delivered = messageText.isDelivered
                model = outgoingModel

                cell = tableView.dequeueReusableCell(withIdentifier: ChatOutgoingTextCell.staticReuseIdentifier) as! ChatOutgoingTextCell
            }
            else if let messageCall = message.messageCall {
                let outgoingModel = ChatOutgoingCallCellModel()
                outgoingModel.callDuration = messageCall.callDuration
                outgoingModel.answered = (messageCall.callEvent == .answered)
                model = outgoingModel

                cell = tableView.dequeueReusableCell(withIdentifier: ChatOutgoingCallCell.staticReuseIdentifier) as! ChatOutgoingCallCell
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

                cell = tableView.dequeueReusableCell(withIdentifier: ChatIncomingTextCell.staticReuseIdentifier) as! ChatIncomingTextCell
            }
            else if let messageCall = message.messageCall {
                let incomingModel = ChatIncomingCallCellModel()
                incomingModel.callDuration = messageCall.callDuration
                incomingModel.answered = (messageCall.callEvent == .answered)
                model = incomingModel

                cell = tableView.dequeueReusableCell(withIdentifier: ChatIncomingCallCell.staticReuseIdentifier) as! ChatIncomingCallCell
            }
            else if let _ = message.messageFile {
                (model, cell) = imageCellWithMessage(message, incoming: true)
            }
        }

        model.dateString = timeFormatter.string(from: message.date())

        cell.delegate = self
        cell.setupWithTheme(theme, model: model)
        cell.transform = tableView.transform;

        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(visibleMessages, messages.count)
    }
}

extension ChatPrivateController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            toggleNewMessageView(show: false)
        }

        maybeLoadImageForCellAtPath(cell, indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        guard !tableView.isEditing else {
            return false
        }
        guard let editable = tableView.cellForRow(at: indexPath) as? ChatEditable else {
            return false
        }

        if !editable.shouldShowMenu() {
            return false
        }

        selectedMenuIndexPath = indexPath
        editable.willShowMenu()

        return true
    }

    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        guard let cell = tableView.cellForRow(at: indexPath) as? ChatMovableDateCell else {
            return false
        }

        return cell.isMenuActionSupportedByCell(action)
    }

    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        // Dummy method to make tableView:shouldShowMenuForRowAtIndexPath: work.
    }
}

extension ChatPrivateController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
    func chatMovableDateCellCopyPressed(_ cell: ChatMovableDateCell) {
        guard let indexPath = tableView?.indexPath(for: cell) else {
            return
        }

        let message = messages[indexPath.row]

        if let messageText = message.messageText {
            UIPasteboard.general.string = messageText.text
        }
        else if let _ = message.messageCall {
            fatalError("Message call cannot be copied")
        }
        else if let messageFile = message.messageFile {
            guard UTTypeConformsTo(messageFile.fileUTI as CFString? ?? "" as CFString, kUTTypeImage) else {
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

            UIPasteboard.general.image = image
        }
    }

    func chatMovableDateCellDeletePressed(_ cell: ChatMovableDateCell) {
        guard let indexPath = tableView?.indexPath(for: cell) else {
            return
        }

        let message = messages[indexPath.row]

        submanagerChats.removeMessages([message])
    }

    func chatMovableDateCellMorePressed(_ cell: ChatMovableDateCell) {
        toggleTableViewEditing(true, animated: true)

        // TODO select row
        // guard let indexPath = tableView?.indexPathForCell(cell) else {
        //     return
        // }

        // tableView?.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
    }
}

extension ChatPrivateController: ChatInputViewDelegate {
    func chatInputViewCameraButtonPressed(_ view: ChatInputView, cameraView: UIView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = cameraView
        alert.popoverPresentationController?.sourceRect = CGRect(x: cameraView.frame.size.width / 2, y: cameraView.frame.size.height / 2, width: 1.0, height: 1.0)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: String(localized: "photo_from_camera"), style: .default) { [unowned self] _ -> Void in
                let controller = UIImagePickerController()
                controller.sourceType = .camera
                controller.delegate = self
                self.present(controller, animated: true, completion: nil)
            })
        }

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: String(localized: "photo_from_photo_library"), style: .default) { [unowned self] _ -> Void in
                let controller = UIImagePickerController()
                controller.sourceType = .photoLibrary
                controller.delegate = self
                self.present(controller, animated: true, completion: nil)
            })
        }

        alert.addAction(UIAlertAction(title: String(localized: "alert_cancel"), style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    func chatInputViewSendButtonPressed(_ view: ChatInputView) {
        submanagerChats.sendMessage(to: chat, text: view.text, type: .normal, successBlock: nil, failureBlock: nil)

        view.text = ""
        submanagerObjects.change(chat, enteredText: "")
    }

    func chatInputViewTextDidChange(_ view: ChatInputView) {
        submanagerObjects.change(chat, enteredText: view.text)
    }
}

extension ChatPrivateController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGR = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }

        let translation = panGR.translation(in: panGR.view)

        return fabsf(Float(translation.x)) > fabsf(Float(translation.y))
    }
}

extension ChatPrivateController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)

        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        guard let data = UIImageJPEGRepresentation(image, 0.9) else {
            return
        }

        var fileName: String? = fileNameFromImageInfo(info as [String : AnyObject])

        if fileName == nil {
            let dateString = DateFormatter(type: .dateAndTime).string(from: Date())
            fileName = "Photo \(dateString).jpg".replacingOccurrences(of: "/", with: "-")
        }

        submanagerFiles.send(data, withFileName: fileName!, to: chat) { (error: Error) in
            handleErrorWithType(.sendFileToFriend, error: error as NSError)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
        tableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        tableView.scrollsToTop = false
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 44.0
        tableView.backgroundColor = theme.colorForType(.NormalBackground)
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.separatorStyle = .none

        view.addSubview(tableView)

        tableView.register(ChatMovableDateCell.self, forCellReuseIdentifier: ChatMovableDateCell.staticReuseIdentifier)
        tableView.register(ChatIncomingTextCell.self, forCellReuseIdentifier: ChatIncomingTextCell.staticReuseIdentifier)
        tableView.register(ChatOutgoingTextCell.self, forCellReuseIdentifier: ChatOutgoingTextCell.staticReuseIdentifier)
        tableView.register(ChatIncomingCallCell.self, forCellReuseIdentifier: ChatIncomingCallCell.staticReuseIdentifier)
        tableView.register(ChatOutgoingCallCell.self, forCellReuseIdentifier: ChatOutgoingCallCell.staticReuseIdentifier)
        tableView.register(ChatIncomingFileCell.self, forCellReuseIdentifier: ChatIncomingFileCell.staticReuseIdentifier)
        tableView.register(ChatOutgoingFileCell.self, forCellReuseIdentifier: ChatOutgoingFileCell.staticReuseIdentifier)

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
        newMessagesView.isHidden = true
        view.addSubview(newMessagesView)

        let label = UILabel()
        label.text = String(localized: "chat_new_messages")
        label.textColor = theme.colorForType(.ConnectingText)
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 12.0)
        newMessagesView.addSubview(label)

        let button = UIButton()
        button.addTarget(self, action: #selector(ChatPrivateController.newMessagesViewPressed), for: .touchUpInside)
        newMessagesView.addSubview(button)

        label.snp.makeConstraints {
            $0.leading.equalTo(newMessagesView).offset(Constants.NewMessageViewEdgesOffset)
            $0.trailing.equalTo(newMessagesView).offset(-Constants.NewMessageViewEdgesOffset)
            $0.top.equalTo(newMessagesView).offset(Constants.NewMessageViewEdgesOffset)
            $0.bottom.equalTo(newMessagesView).offset(-Constants.NewMessageViewEdgesOffset)
        }

        button.snp.makeConstraints {
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
        editMessagesToolbar.isHidden = true
        editMessagesToolbar.tintColor = theme.colorForType(.LinkText)
        editMessagesToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(ChatPrivateController.editMessagesDeleteButtonPressed(_:)))
        ]
        view.addSubview(editMessagesToolbar)
    }

    func installConstraints() {
        tableView!.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view)
        }

        newMessagesView.snp.makeConstraints {
            $0.centerX.equalTo(tableView!)
            newMessageViewTopConstraint = $0.top.equalTo(chatInputView.snp.top).constraint
        }

        chatInputView.snp.makeConstraints {
            $0.leading.trailing.equalTo(view)
            $0.top.equalTo(tableView!.snp.bottom)
            $0.top.greaterThanOrEqualTo(view).offset(Constants.InputViewTopOffset)
            chatInputViewBottomConstraint = $0.bottom.equalTo(view).constraint
        }

        editMessagesToolbar.snp.makeConstraints {
            $0.edges.equalTo(chatInputView)
        }
    }

    func addMessagesNotification() {
        self.messagesToken = messages.addNotificationBlock { [unowned self] change in
            guard let tableView = self.tableView else {
                return
            }
            switch change {
                case .initial:
                    break
                case .update(_, let deletions, let insertions, let modifications):
                    tableView.beginUpdates()
                    self.updateTableViewWithDeletions(deletions)
                    self.updateTableViewWithInsertions(insertions)
                    self.updateTableViewWithModifications(modifications)

                    self.visibleMessages = self.visibleMessages + insertions.count - deletions.count
                    tableView.endUpdates()

                    if insertions.contains(0) {
                        self.handleNewMessage()
                    }
                case .error(let error):
                    fatalError("\(error)")
            }
        }
    }

    func updateTableViewWithDeletions(_ deletions: [Int]) {
        guard let tableView = tableView else {
            return
        }

        for index in deletions {
            if index >= visibleMessages {
                continue
            }
            let indexPath = IndexPath(row: index, section: 0)
            tableView.deleteRows(at: [indexPath], with: .top)
        }
    }

    func updateTableViewWithInsertions(_ insertions: [Int]) {
        guard let tableView = tableView else {
            return
        }

        for index in insertions {
            if index >= visibleMessages {
                continue
            }
            let indexPath = IndexPath(row: index, section: 0)
            tableView.insertRows(at: [indexPath], with: .top)
        }
    }

    func updateTableViewWithModifications(_ modifications: [Int]) {
        guard let tableView = tableView else {
            return
        }

        for index in modifications {
            if index >= visibleMessages {
                continue
            }
            let message = messages[index]
            let indexPath = IndexPath(row: index, section: 0)

            if message.messageFile == nil {
                tableView.reloadRows(at: [indexPath], with: .none)
                continue
            }

            guard let cell = tableView.cellForRow(at: indexPath) as? ChatGenericFileCell else {
                continue
            }

            let model = ChatIncomingFileCellModel()
            prepareFileCell(cell, andModel: model, withMessage: message)
            cell.setupWithTheme(theme, model: model)

            maybeLoadImageForCellAtPath(cell, indexPath: indexPath)
        }
    }

    func addFriendNotification() {
        guard let friend = self.friend else {
            titleView.name = String(localized: "contact_deleted")
            titleView.userStatus = UserStatus(connectionStatus: .none, userStatus: .none)
            audioButton.isEnabled = false
            videoButton.isEnabled = false
            chatInputView.buttonsEnabled = false
            return
        }

        titleView.name = friend.nickname
        titleView.userStatus = UserStatus(connectionStatus: friend.connectionStatus, userStatus: friend.status)

        let predicate = NSPredicate(format: "uniqueIdentifier == %@", friend.uniqueIdentifier)
        let results = submanagerObjects.friends(predicate: predicate)

        friendToken = results.addNotificationBlock { [unowned self] change in
            guard let friend = self.friend else {
                return
            }

            switch change {
                case .initial:
                    fallthrough
                case .update:
                    self.titleView.name = friend.nickname
                    self.titleView.userStatus = UserStatus(connectionStatus: friend.connectionStatus, userStatus: friend.status)

                    let isConnected = friend.isConnected

                    self.audioButton.isEnabled = isConnected
                    self.videoButton.isEnabled = isConnected
                    self.chatInputView.buttonsEnabled = isConnected
                case .error(let error):
                    fatalError("\(error)")
            }
        }
    }

    func updateInputViewMaxHeight() {
        chatInputView.maxHeight = chatInputView.frame.maxY - Constants.InputViewTopOffset
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

        let first = IndexPath(row: 0, section: 0)

        if !visible.contains(first) {
            toggleNewMessageView(show: true)
        }
    }

    func toggleNewMessageView(show: Bool) {
        guard show != newMessagesViewVisible else {
            return
        }
        newMessagesViewVisible = show

        if show {
            newMessagesView.isHidden = false
        }

        UIView.animate(withDuration: Constants.NewMessageViewAnimationDuration, animations: {
            if show {
                self.newMessageViewTopConstraint?.update(offset: Constants.NewMessageViewTopOffset - self.newMessagesView.frame.size.height)
            }
            else {
                self.newMessageViewTopConstraint?.update(offset: 0.0)
            }

            self.view.layoutIfNeeded()

        }, completion: { finished in
            if !show {
                self.newMessagesView.isHidden = true
            }
        })
    }

    func updateLastReadDate() {
        submanagerObjects.change(chat, lastReadDateInterval: Date().timeIntervalSince1970)
    }

    func imageCellWithMessage(_ message: OCTMessageAbstract, incoming: Bool) -> (ChatMovableDateCellModel, ChatMovableDateCell) {
        let cell: ChatGenericFileCell

        if incoming {
            cell = tableView!.dequeueReusableCell(withIdentifier: ChatIncomingFileCell.staticReuseIdentifier) as! ChatIncomingFileCell
        }
        else {
            cell = tableView!.dequeueReusableCell(withIdentifier: ChatOutgoingFileCell.staticReuseIdentifier) as! ChatOutgoingFileCell
        }
        let model = ChatIncomingFileCellModel()

        prepareFileCell(cell, andModel: model, withMessage: message)

        return (model, cell)
    }

    func prepareFileCell(_ cell: ChatGenericFileCell, andModel model: ChatGenericFileCellModel, withMessage message: OCTMessageAbstract) {
        cell.progressObject = nil

        model.fileName = message.messageFile!.fileName
        model.fileSize = ByteCountFormatter.string(fromByteCount: message.messageFile!.fileSize, countStyle: .file)
        model.fileUTI = message.messageFile!.fileUTI

        switch message.messageFile!.fileType {
            case .waitingConfirmation:
                model.state = .waitingConfirmation
            case .loading:
                model.state = .loading

                let bridge = ChatProgressBridge()
                cell.progressObject = bridge
                _ = try? self.submanagerFiles.add(bridge, forFileTransfer: message)
            case .paused:
                model.state = .paused
            case .canceled:
                model.state = .cancelled
            case .ready:
                model.state = .done
        }

        if !message.isOutgoing() {
            model.startLoadingHandle = { [weak self] in
                self?.submanagerFiles.acceptFileTransfer(message) { (error: Error) -> Void in
                    handleErrorWithType(.acceptIncomingFile, error: error as NSError)
                }
            }
        }

        model.cancelHandle = { [weak self] in
            do {
                try self?.submanagerFiles.cancelFileTransfer(message)
            }
            catch let error as NSError {
                handleErrorWithType(.cancelFileTransfer, error: error)
            }
        }

        model.retryHandle = { [weak self] in
            self?.submanagerFiles.retrySendingFile(message) { (error: Error) in
                handleErrorWithType(.sendFileToFriend, error: error as NSError)
            }
        }

        model.pauseOrResumeHandle = { [weak self] in
            let isPaused = (message.messageFile!.pausedBy.rawValue & OCTMessageFilePausedBy.user.rawValue) != 0

            do {
                try self?.submanagerFiles.pauseFileTransfer(!isPaused, message: message)
            }
            catch let error as NSError {
                handleErrorWithType(.cancelFileTransfer, error: error)
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

    func maybeLoadImageForCellAtPath(_ cell: UITableViewCell, indexPath: IndexPath) {
        let message = messages[indexPath.row]

        guard let messageFile = message.messageFile else {
            return
        }

        guard UTTypeConformsTo(messageFile.fileUTI as CFString? ?? "" as CFString, kUTTypeImage) else {
            return
        }

        guard let file = messageFile.filePath() else {
            return
        }

        if messageFile.fileSize >= Constants.MaxImageSizeToShowInline {
            return
        }

        if let image = imageCache.object(forKey: file as AnyObject) as? UIImage {
            let cell = (cell as? ChatIncomingFileCell) ?? (cell as? ChatOutgoingFileCell)

            cell?.setButtonImage(image)
        }
        else {
            loadImageForCellAtIndexPath(indexPath, fromFile: file)
        }
    }

    func loadImageForCellAtIndexPath(_ indexPath: IndexPath, fromFile: String) {
        DispatchQueue.global(qos: .default).async { [weak self] in
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
            self?.imageCache.setObject(image, forKey: fromFile as AnyObject)

            DispatchQueue.main.async {
                let optionalCell = self?.tableView?.cellForRow(at: indexPath)
                guard let cell = (optionalCell as? ChatIncomingFileCell) ?? (optionalCell as? ChatOutgoingFileCell) else {
                    return
                }

                cell.setButtonImage(image)
            }
        }
    }

    func fileNameFromImageInfo(_ info: [String: AnyObject]) -> String? {
        guard let url = info[UIImagePickerControllerReferenceURL] as? URL else {
            return nil
        }

        let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)

        guard let asset = fetchResult.firstObject else {
            return nil
        }

        if #available(iOS 9.0, *) {
            if let resource = PHAssetResource.assetResources(for: asset).first {
                return resource.originalFilename
            }
        } else {
            // Fallback on earlier versions
            if let name = asset.value(forKey: "filename") as? String {
                return name
            }
        }

        return nil
    }

    func toggleTableViewEditing(_ editing: Bool, animated: Bool) {
        tableView?.setEditing(editing, animated: animated)

        tableViewTapGestureRecognizer.isEnabled = !editing
        editMessagesToolbar.isHidden = !editing

        if editing {
            _ = chatInputView.resignFirstResponder()

            navigationItem.leftBarButtonItems = [UIBarButtonItem(
                title: String(localized: "delete_all_messages"),
                style: .plain,
                target: self,
                action: #selector(ChatPrivateController.deleteAllMessagesButtonPressed(_:)))]

            navigationItem.rightBarButtonItems = [UIBarButtonItem(
                    barButtonSystemItem: .cancel,
                    target: self,
                    action: #selector(ChatPrivateController.cancelEditingButtonPressed))]
        }
        else {
            let audioImage = UIImage(named: "start-call-medium")!
            let videoImage = UIImage(named: "video-call-medium")!

            audioButton = UIBarButtonItem(image: audioImage, style: .plain, target: self, action: #selector(ChatPrivateController.audioCallButtonPressed))
            videoButton = UIBarButtonItem(image: videoImage, style: .plain, target: self, action: #selector(ChatPrivateController.videoCallButtonPressed))

            navigationItem.leftBarButtonItems = nil
            navigationItem.rightBarButtonItems = [
                videoButton,
                audioButton,
            ]
        }
    }

    func showMessageDeletionConfirmation(messagesCount: Int,
                                         showFromItem barButtonItem: UIBarButtonItem,
                                         deleteClosure: @escaping (Void) -> Void) {
        let deleteButtonText = messagesCount > 1 ?
            String(localized: "delete_multiple_messages") + " (\(messagesCount))" :
            String(localized: "delete_single_message")

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.barButtonItem = barButtonItem

        alert.addAction(UIAlertAction(title: deleteButtonText, style: .destructive) { _ -> Void in
            deleteClosure()
        })

        alert.addAction(UIAlertAction(title: String(localized: "alert_cancel"), style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}
