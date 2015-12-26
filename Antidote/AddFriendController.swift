//
//  AddFriendController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 25/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let TextViewTopOffset = 5.0
    static let TextViewXOffset = 5.0
    static let QrCodeBottomSpacerDeltaHeight = 70.0

    static let SendAlertTextViewBottomOffset = -10.0
    static let SendAlertTextViewXOffset = 5.0
    static let SendAlertTextViewHeight = 70.0
}

protocol AddFriendControllerDelegate: class {
    /**
        Ask delegate to scan QR code.

        - Parameters:
          - scanQRWithHandler: handler to be called on successful scan:
            - [String] - array with scanned strings.
            - -> Bool - return true if scanning should be finished, false otherwise.
     */
    func addFriendController(controller: AddFriendController, scanQRWithHandler: [String] -> Bool)
    func addFriendControllerDidFinish(controller: AddFriendController)
}

class AddFriendController: UIViewController {
    weak var delegate: AddFriendControllerDelegate?

    private let theme: Theme
    private let submanagerFriends: OCTSubmanagerFriends

    private var textView: UITextView!

    private var orTopSpacer: UIView!
    private var qrCodeBottomSpacer: UIView!

    private var orLabel: UILabel!
    private var qrCodeButton: UIButton!

    private var cachedMessage: String?

    init(theme: Theme, submanagerFriends: OCTSubmanagerFriends) {
        self.theme = theme
        self.submanagerFriends = submanagerFriends

        super.init(nibName: nil, bundle: nil)

        addNavigationButtons()

        edgesForExtendedLayout = .None
        title = String(localized: "add_friend_title")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        createViews()
        installConstraints()

        updateSendButton()
    }
}

extension AddFriendController {
    func qrCodeButtonPressed() {
        delegate?.addFriendController(self, scanQRWithHandler: { [unowned self] stringValues in
            let ids = stringValues.map {
                $0.uppercaseString
            }.map {
                $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }.map {
                $0.hasPrefix("TOX:") ? $0.substringToIndex($0.startIndex.advancedBy(4)) : $0
            }.filter {
                isAddressString($0)
            }

            guard ids.count > 0 else {
                UIAlertView.showErrorWithMessage(String(localized: "add_friend_wrong_qr"))
                return false
            }

            self.textView.text = ids[0]
            self.updateSendButton()

            return true
        })
    }

    func sendButtonPressed() {
        textView.resignFirstResponder()

        let messageView = UITextView()
        messageView.text = cachedMessage
        messageView.placeholder = String(localized: "add_friend_default_message_text")
        messageView.font = UIFont.systemFontOfSize(17.0)
        messageView.layer.cornerRadius = 5.0
        messageView.layer.masksToBounds = true

        let alert = SDCAlertController(
                title: String(localized: "add_friend_default_message_title"),
                message: nil,
                preferredStyle: .Alert)

        alert.contentView.addSubview(messageView)
        messageView.snp_makeConstraints{ make -> Void in
            make.top.equalTo(alert.contentView)
            make.bottom.equalTo(alert.contentView).offset(Constants.SendAlertTextViewBottomOffset);
            make.left.equalTo(alert.contentView).offset(Constants.SendAlertTextViewXOffset);
            make.right.equalTo(alert.contentView).offset(-Constants.SendAlertTextViewXOffset);
            make.height.equalTo(Constants.SendAlertTextViewHeight);
        }

        alert.addAction(SDCAlertAction(title: String(localized: "add_friend_cancel"), style: .Default, handler: nil))
        alert.addAction(SDCAlertAction(title: String(localized: "add_friend_send"), style: .Recommended) { [unowned self] action in
            self.cachedMessage = messageView.text

            let message = messageView.text.isEmpty ? messageView.placeholder : messageView.text

            do {
                try self.submanagerFriends.sendFriendRequestToAddress(self.textView.text, message: message)
            }
            catch let error as NSError {
                handleErrorWithType(.ToxAddFriend, error: error)
                return
            }

            self.delegate?.addFriendControllerDidFinish(self)
        })

        alert.presentWithCompletion(nil)
    }
}

extension AddFriendController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }

        let resultText = (textView.text! as NSString).stringByReplacingCharactersInRange(range, withString: text)
        let maxLength = Int(kOCTToxAddressLength)

        if resultText.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > maxLength {
            textView.text = resultText.substringToByteLength(maxLength, encoding: NSUTF8StringEncoding)
            return false
        }

        return true
    }

    func textViewDidChange(textView: UITextView) {
        updateSendButton()
    }
}

private extension AddFriendController {
    func addNavigationButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: String(localized: "add_friend_send"),
                style: .Done,
                target: self,
                action: "sendButtonPressed")
    }

    func createViews() {
        textView = UITextView()
        textView.placeholder = String(localized: "add_friend_tox_id_placeholder")
        textView.delegate = self
        textView.scrollEnabled = false
        textView.font = UIFont.systemFontOfSize(17)
        textView.textColor = theme.colorForType(.NormalText)
        textView.backgroundColor = .clearColor()
        textView.returnKeyType = .Done
        textView.layer.cornerRadius = 5.0
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = theme.colorForType(.TableSeparator).CGColor
        textView.layer.masksToBounds = true
        view.addSubview(textView)

        orTopSpacer = createSpacer()
        qrCodeBottomSpacer = createSpacer()

        orLabel = UILabel()
        orLabel.text = String(localized: "add_friend_or_label")
        orLabel.textColor = theme.colorForType(.NormalText)
        orLabel.backgroundColor = .clearColor()
        view.addSubview(orLabel)

        qrCodeButton = UIButton(type: .System)
        qrCodeButton.setTitle(String(localized: "add_friend_use_qr"), forState: .Normal)
        qrCodeButton.titleLabel!.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightBold)
        qrCodeButton.addTarget(self, action: "qrCodeButtonPressed", forControlEvents: .TouchUpInside)
        view.addSubview(qrCodeButton)
    }

    func createSpacer() -> UIView {
        let spacer = UIView()
        spacer.backgroundColor = .clearColor()
        view.addSubview(spacer)

        return spacer
    }

    func installConstraints() {
        textView.snp_makeConstraints{ make -> Void in
            make.top.equalTo(view).offset(Constants.TextViewTopOffset)
            make.left.equalTo(view).offset(Constants.TextViewXOffset)
            make.right.equalTo(view).offset(-Constants.TextViewXOffset)
            make.bottom.equalTo(view.snp_centerY)
        }

        orTopSpacer.snp_makeConstraints{ make -> Void in
            make.top.equalTo(textView.snp_bottom)
        }

        orLabel.snp_makeConstraints{ make -> Void in
            make.top.equalTo(orTopSpacer.snp_bottom)
            make.centerX.equalTo(view)
        }

        qrCodeButton.snp_makeConstraints{ make -> Void in
            make.top.equalTo(orLabel.snp_bottom)
            make.centerX.equalTo(view)
        }

        qrCodeBottomSpacer.snp_makeConstraints{ make -> Void in
            make.top.equalTo(qrCodeButton.snp_bottom)
            make.bottom.equalTo(view)
            make.height.equalTo(orTopSpacer)
        }
    }

    func updateSendButton() {
        navigationItem.rightBarButtonItem!.enabled = isAddressString(textView.text)
    }
}
