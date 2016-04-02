//
//  ChatInputView.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 13.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let TopBorderHeight = 0.5
    static let Offset: CGFloat = 5.0
    static let CameraHorizontalOffset: CGFloat = 10.0
    static let CameraBottomOffset: CGFloat = -10.0
    static let TextViewMinHeight: CGFloat = 35.0
}

protocol ChatInputViewDelegate: class {
    func chatInputViewCameraButtonPressed(view: ChatInputView, cameraView: UIView)
    func chatInputViewSendButtonPressed(view: ChatInputView)
    func chatInputViewTextDidChange(view: ChatInputView)
}

class ChatInputView: UIView {
    weak var delegate: ChatInputViewDelegate?

    var text: String {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
            updateViews()
        }
    }

    var maxHeight: CGFloat {
        didSet {
            updateViews()
        }
    }

    var buttonsEnabled: Bool = true{
        didSet {
            updateViews()
        }
    }

    private var topBorder: UIView!
    private var cameraButton: UIButton!
    private var textView: UITextView!
    private var sendButton: UIButton!

    init(theme: Theme) {
        self.maxHeight = 0.0

        super.init(frame: CGRectZero)

        backgroundColor = theme.colorForType(.ChatInputBackground)

        createViews(theme)
        installConstraints()
        updateViews()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }
}

// MARK: Actions
extension ChatInputView {
    func cameraButtonPressed() {
        delegate?.chatInputViewCameraButtonPressed(self, cameraView: cameraButton)
    }

    func sendButtonPressed() {
        delegate?.chatInputViewSendButtonPressed(self)
    }
}

extension ChatInputView: UITextViewDelegate {
    func textViewDidChange(textView: UITextView) {
        updateViews()
        delegate?.chatInputViewTextDidChange(self)
    }
}

private extension ChatInputView {
    func createViews(theme: Theme) {
        topBorder = UIView()
        topBorder.backgroundColor = theme.colorForType(.SeparatorsAndBorders)
        addSubview(topBorder)

        let cameraImage = UIImage.templateNamed("chat-camera")

        cameraButton = UIButton()
        cameraButton.setImage(cameraImage, forState: .Normal)
        cameraButton.tintColor = theme.colorForType(.LinkText)
        cameraButton.addTarget(self, action: #selector(ChatInputView.cameraButtonPressed), forControlEvents: .TouchUpInside)
        cameraButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        addSubview(cameraButton)

        textView = UITextView()
        textView.delegate = self
        textView.font = UIFont.systemFontOfSize(16.0)
        textView.backgroundColor = theme.colorForType(.NormalBackground)
        textView.layer.cornerRadius = 5.0
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = theme.colorForType(.SeparatorsAndBorders).CGColor
        textView.layer.masksToBounds = true
        textView.setContentHuggingPriority(0.0, forAxis: .Horizontal)
        addSubview(textView)

        sendButton = UIButton(type: .System)
        sendButton.setTitle(String(localized: "chat_send_button"), forState: .Normal)
        sendButton.titleLabel?.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightBold)
        sendButton.addTarget(self, action: #selector(ChatInputView.sendButtonPressed), forControlEvents: .TouchUpInside)
        sendButton.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        addSubview(sendButton)
    }

    func installConstraints() {
        topBorder.snp_makeConstraints {
            $0.top.left.right.equalTo(self)
            $0.height.equalTo(Constants.TopBorderHeight)
        }

        cameraButton.snp_makeConstraints {
            $0.left.equalTo(self).offset(Constants.CameraHorizontalOffset)
            $0.bottom.equalTo(self).offset(Constants.CameraBottomOffset)
        }

        textView.snp_makeConstraints {
            $0.left.equalTo(cameraButton.snp_right).offset(Constants.CameraHorizontalOffset)
            $0.top.equalTo(self).offset(Constants.Offset)
            $0.bottom.equalTo(self).offset(-Constants.Offset)
            $0.height.greaterThanOrEqualTo(Constants.TextViewMinHeight)
        }

        sendButton.snp_makeConstraints {
            $0.left.equalTo(textView.snp_right).offset(Constants.Offset)
            $0.right.equalTo(self).offset(-Constants.Offset)
            $0.bottom.equalTo(self).offset(-Constants.Offset)
        }
    }

    func updateViews() {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.max))

        if maxHeight > 0.0 {
            textView.scrollEnabled = (size.height + 2 * Constants.Offset) > maxHeight
        }
        else {
            textView.scrollEnabled = false
        }

        cameraButton.enabled = buttonsEnabled
        sendButton.enabled = buttonsEnabled && !textView.text.isEmpty
    }
}
