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
            _ controller: AddFriendController,
            validateCodeHandler: @escaping (String) -> Bool,
            didScanHander: @escaping (String) -> Void)

    func addFriendControllerDidFinish(_ controller: AddFriendController)
}

class AddFriendController: UIViewController {
    weak var delegate: AddFriendControllerDelegate?

    fileprivate let theme: Theme
    fileprivate weak var submanagerFriends: OCTSubmanagerFriends!

    fileprivate var textView: UITextView!

    fileprivate var orTopSpacer: UIView!
    fileprivate var qrCodeBottomSpacer: UIView!

    fileprivate var orLabel: UILabel!
    fileprivate var qrCodeButton: UIButton!

    fileprivate var cachedMessage: String?

    init(theme: Theme, submanagerFriends: OCTSubmanagerFriends) {
        self.theme = theme
        self.submanagerFriends = submanagerFriends

        super.init(nibName: nil, bundle: nil)

        addNavigationButtons()

        edgesForExtendedLayout = UIRectEdge()
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
    @objc func qrCodeButtonPressed() {
        func prepareString(_ string: String) -> String {
            var string = string

            string = string.uppercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

            if string.hasPrefix("TOX:") {
                return string.substring(from: string.characters.index(string.startIndex, offsetBy: 4))
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

    @objc func sendButtonPressed() {
        textView.resignFirstResponder()

        let messageView = UITextView()
        messageView.text = cachedMessage
        messageView.placeholder = String(localized: "add_contact_default_message_text")
        messageView.font = UIFont.systemFont(ofSize: 17.0)
        messageView.layer.cornerRadius = 5.0
        messageView.layer.masksToBounds = true

        let alert = SDCAlertController(
                title: String(localized: "add_contact_default_message_title"),
                message: nil,
                preferredStyle: .alert)!

        alert.contentView.addSubview(messageView)
        messageView.snp.makeConstraints {
            $0.top.equalTo(alert.contentView)
            $0.bottom.equalTo(alert.contentView).offset(Constants.SendAlertTextViewBottomOffset);
            $0.leading.equalTo(alert.contentView).offset(Constants.SendAlertTextViewXOffset);
            $0.trailing.equalTo(alert.contentView).offset(-Constants.SendAlertTextViewXOffset);
            $0.height.equalTo(Constants.SendAlertTextViewHeight);
        }

        alert.addAction(SDCAlertAction(title: String(localized: "alert_cancel"), style: .default, handler: nil))
        alert.addAction(SDCAlertAction(title: String(localized: "add_contact_send"), style: .recommended) { [unowned self] action in
            self.cachedMessage = messageView.text

            let message = messageView.text.isEmpty ? messageView.placeholder : messageView.text

            do {
                try self.submanagerFriends.sendFriendRequest(toAddress: self.textView.text, message: message)
            }
            catch let error as NSError {
                handleErrorWithType(.toxAddFriend, error: error)
                return
            }

            self.delegate?.addFriendControllerDidFinish(self)
        })

        alert.present(completion: nil)
    }
}

extension AddFriendController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }

        let resultText = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        let maxLength = Int(kOCTToxAddressLength)

        if resultText.lengthOfBytes(using: String.Encoding.utf8) > maxLength {
            textView.text = resultText.substringToByteLength(maxLength, encoding: String.Encoding.utf8)
            return false
        }

        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        updateSendButton()
    }
}

private extension AddFriendController {
    func addNavigationButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: String(localized: "add_contact_send"),
                style: .done,
                target: self,
                action: #selector(AddFriendController.sendButtonPressed))
    }

    func createViews() {
        textView = UITextView()
        textView.placeholder = String(localized: "add_contact_tox_id_placeholder")
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textColor = theme.colorForType(.NormalText)
        textView.backgroundColor = .clear
        textView.returnKeyType = .done
        textView.layer.cornerRadius = 5.0
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = theme.colorForType(.SeparatorsAndBorders).cgColor
        textView.layer.masksToBounds = true
        view.addSubview(textView)

        orTopSpacer = createSpacer()
        qrCodeBottomSpacer = createSpacer()

        orLabel = UILabel()
        orLabel.text = String(localized: "add_contact_or_label")
        orLabel.textColor = theme.colorForType(.NormalText)
        orLabel.backgroundColor = .clear
        view.addSubview(orLabel)

        qrCodeButton = UIButton(type: .system)
        qrCodeButton.setTitle(String(localized: "add_contact_use_qr"), for: UIControlState())
        qrCodeButton.titleLabel!.font = UIFont.antidoteFontWithSize(16.0, weight: .bold)
        qrCodeButton.addTarget(self, action: #selector(AddFriendController.qrCodeButtonPressed), for: .touchUpInside)
        view.addSubview(qrCodeButton)
    }

    func createSpacer() -> UIView {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        view.addSubview(spacer)

        return spacer
    }

    func installConstraints() {
        textView.snp.makeConstraints {
            $0.top.equalTo(view).offset(Constants.TextViewTopOffset)
            $0.leading.equalTo(view).offset(Constants.TextViewXOffset)
            $0.trailing.equalTo(view).offset(-Constants.TextViewXOffset)
            $0.bottom.equalTo(view.snp.centerY)
        }

        orTopSpacer.snp.makeConstraints {
            $0.top.equalTo(textView.snp.bottom)
        }

        orLabel.snp.makeConstraints {
            $0.top.equalTo(orTopSpacer.snp.bottom)
            $0.centerX.equalTo(view)
        }

        qrCodeButton.snp.makeConstraints {
            $0.top.equalTo(orLabel.snp.bottom)
            $0.centerX.equalTo(view)
        }

        qrCodeBottomSpacer.snp.makeConstraints {
            $0.top.equalTo(qrCodeButton.snp.bottom)
            $0.bottom.equalTo(view)
            $0.height.equalTo(orTopSpacer)
        }
    }

    func updateSendButton() {
        navigationItem.rightBarButtonItem!.isEnabled = isAddressString(textView.text)
    }
}
