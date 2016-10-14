// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
    func addFriendControllerScanQRCode(
            controller: AddFriendController,
            validateCodeHandler: String -> Bool,
            didScanHander: String -> Void)

    func addFriendControllerDidFinish(controller: AddFriendController)
}

class AddFriendController: UIViewController {
    weak var delegate: AddFriendControllerDelegate?

    private let theme: Theme
    private weak var submanagerFriends: OCTSubmanagerFriends!

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
        title = String(localized: "add_contact_title")
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
        func prepareString(string: String) -> String {
            var string = string

            string = string.uppercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

            if string.hasPrefix("TOX:") {
                return string.substringFromIndex(string.startIndex.advancedBy(4))
            }

            return string
        }

        delegate?.addFriendControllerScanQRCode(self, validateCodeHandler: {
            return isAddressString(prepareString($0))

        }, didScanHander: { [unowned self] in
            self.textView.text = prepareString($0)
            self.updateSendButton()
        })
    }

    func sendButtonPressed() {
        textView.resignFirstResponder()

        let messageView = UITextView()
        messageView.text = cachedMessage
        messageView.placeholder = String(localized: "add_contact_default_message_text")
        messageView.font = UIFont.systemFontOfSize(17.0)
        messageView.layer.cornerRadius = 5.0
        messageView.layer.masksToBounds = true

        let alert = SDCAlertController(
                title: String(localized: "add_contact_default_message_title"),
                message: nil,
                preferredStyle: .Alert)

        alert.contentView.addSubview(messageView)
        messageView.snp_makeConstraints {
            $0.top.equalTo(alert.contentView)
            $0.bottom.equalTo(alert.contentView).offset(Constants.SendAlertTextViewBottomOffset);
            $0.leading.equalTo(alert.contentView).offset(Constants.SendAlertTextViewXOffset);
            $0.trailing.equalTo(alert.contentView).offset(-Constants.SendAlertTextViewXOffset);
            $0.height.equalTo(Constants.SendAlertTextViewHeight);
        }

        alert.addAction(SDCAlertAction(title: String(localized: "alert_cancel"), style: .Default, handler: nil))
        alert.addAction(SDCAlertAction(title: String(localized: "add_contact_send"), style: .Recommended) { [unowned self] action in
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
                title: String(localized: "add_contact_send"),
                style: .Done,
                target: self,
                action: #selector(AddFriendController.sendButtonPressed))
    }

    func createViews() {
        textView = UITextView()
        textView.placeholder = String(localized: "add_contact_tox_id_placeholder")
        textView.delegate = self
        textView.scrollEnabled = false
        textView.font = UIFont.systemFontOfSize(17)
        textView.textColor = theme.colorForType(.NormalText)
        textView.backgroundColor = .clearColor()
        textView.returnKeyType = .Done
        textView.layer.cornerRadius = 5.0
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = theme.colorForType(.SeparatorsAndBorders).CGColor
        textView.layer.masksToBounds = true
        view.addSubview(textView)

        orTopSpacer = createSpacer()
        qrCodeBottomSpacer = createSpacer()

        orLabel = UILabel()
        orLabel.text = String(localized: "add_contact_or_label")
        orLabel.textColor = theme.colorForType(.NormalText)
        orLabel.backgroundColor = .clearColor()
        view.addSubview(orLabel)

        qrCodeButton = UIButton(type: .System)
        qrCodeButton.setTitle(String(localized: "add_contact_use_qr"), forState: .Normal)
        qrCodeButton.titleLabel!.font = UIFont.antidoteFontWithSize(16.0, weight: .Bold)
        qrCodeButton.addTarget(self, action: #selector(AddFriendController.qrCodeButtonPressed), forControlEvents: .TouchUpInside)
        view.addSubview(qrCodeButton)
    }

    func createSpacer() -> UIView {
        let spacer = UIView()
        spacer.backgroundColor = .clearColor()
        view.addSubview(spacer)

        return spacer
    }

    func installConstraints() {
        textView.snp_makeConstraints {
            $0.top.equalTo(view).offset(Constants.TextViewTopOffset)
            $0.leading.equalTo(view).offset(Constants.TextViewXOffset)
            $0.trailing.equalTo(view).offset(-Constants.TextViewXOffset)
            $0.bottom.equalTo(view.snp_centerY)
        }

        orTopSpacer.snp_makeConstraints {
            $0.top.equalTo(textView.snp_bottom)
        }

        orLabel.snp_makeConstraints {
            $0.top.equalTo(orTopSpacer.snp_bottom)
            $0.centerX.equalTo(view)
        }

        qrCodeButton.snp_makeConstraints {
            $0.top.equalTo(orLabel.snp_bottom)
            $0.centerX.equalTo(view)
        }

        qrCodeBottomSpacer.snp_makeConstraints {
            $0.top.equalTo(qrCodeButton.snp_bottom)
            $0.bottom.equalTo(view)
            $0.height.equalTo(orTopSpacer)
        }
    }

    func updateSendButton() {
        navigationItem.rightBarButtonItem!.enabled = isAddressString(textView.text)
    }
}
