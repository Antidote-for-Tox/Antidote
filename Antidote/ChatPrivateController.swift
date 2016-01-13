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
    static let InputViewTopOffset: CGFloat = 50.0
}

class ChatPrivateController: KeyboardNotificationController {
    private let theme: Theme
    private let chat: OCTChat
    private let submanagerChats: OCTSubmanagerChats

    private var chatInputView: ChatInputView!

    private var chatInputViewBottomConstraint: Constraint!

    init(theme: Theme, chat: OCTChat, submanagerChats: OCTSubmanagerChats) {
        self.theme = theme
        self.chat = chat
        self.submanagerChats = submanagerChats

        super.init()

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

        createViews()
        installConstraints()
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

private extension ChatPrivateController {
    func addNavigationButtons() {}

    func createViews() {
        chatInputView = ChatInputView(theme: theme)
        view.addSubview(chatInputView)
    }

    func installConstraints() {
        chatInputView.snp_makeConstraints {
            $0.left.right.equalTo(view)
            $0.top.greaterThanOrEqualTo(view).offset(Constants.InputViewTopOffset)
            chatInputViewBottomConstraint = $0.bottom.equalTo(view).constraint
        }
    }

    func updateInputViewMaxHeight() {
        chatInputView.maxHeight = chatInputView.frame.origin.y - Constants.InputViewTopOffset
    }
}
