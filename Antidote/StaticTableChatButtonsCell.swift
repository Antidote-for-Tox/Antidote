// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

private struct Constants {
    static let ButtonSize = 40.0
    static let VerticalOffset = 8.0
}

class StaticTableChatButtonsCell: StaticTableBaseCell {
    fileprivate var chatButton: UIButton!
    fileprivate var callButton: UIButton!
    fileprivate var videoButton: UIButton!

    fileprivate var separators: [UIView]!

    fileprivate var chatButtonHandler: (() -> Void)?
    fileprivate var callButtonHandler: (() -> Void)?
    fileprivate var videoButtonHandler: (() -> Void)?

    override func setupWithTheme(_ theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let buttonsModel = model as? StaticTableChatButtonsCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        selectionStyle = .none

        chatButtonHandler = buttonsModel.chatButtonHandler
        callButtonHandler = buttonsModel.callButtonHandler
        videoButtonHandler = buttonsModel.videoButtonHandler

        chatButton.isEnabled = buttonsModel.chatButtonEnabled
        callButton.isEnabled = buttonsModel.callButtonEnabled
        videoButton.isEnabled = buttonsModel.videoButtonEnabled
    }

    override func createViews() {
        super.createViews()

        chatButton = createButtonWithImageName("friend-card-chat",
                                               accessibilityLabel: String(localized: "accessibility_chat_button_label"),
                                               accessibilityHint: String(localized: "accessibility_chat_button_hint"),
                                               action: #selector(StaticTableChatButtonsCell.chatButtonPressed))
        callButton = createButtonWithImageName("start-call",
                                               accessibilityLabel: String(localized: "accessibility_call_button_label"),
                                               accessibilityHint: String(localized: "accessibility_call_button_hint"),
                                               action: #selector(StaticTableChatButtonsCell.callButtonPressed))
        videoButton = createButtonWithImageName("video-call",
                                               accessibilityLabel: String(localized: "accessibility_video_button_label"),
                                               accessibilityHint: String(localized: "accessibility_video_button_hint"),
                                               action: #selector(StaticTableChatButtonsCell.videoButtonPressed))

        separators = [UIView]()
        for _ in 0...3 {
            let sep = UIView()
            sep.backgroundColor = UIColor.clear
            customContentView.addSubview(sep)
            separators.append(sep)
        }
    }

    override func installConstraints() {
        super.installConstraints()

        var previous: UIView? = nil
        for (index, sep) in separators.enumerated() {
            sep.snp.makeConstraints {
                if previous != nil {
                    $0.width.equalTo(previous!.snp.width)
                }

                if index == 0 {
                    $0.leading.equalTo(customContentView)
                }

                if index == (separators.count-1) {
                    $0.trailing.equalTo(customContentView)
                }
            }

            previous = sep
        }

        func installForButton(_ button: UIButton, index: Int) {
            button.snp.makeConstraints {
                $0.top.equalTo(customContentView).offset(Constants.VerticalOffset)
                $0.bottom.equalTo(customContentView).offset(-Constants.VerticalOffset)

                $0.leading.equalTo(separators[index].snp.trailing)
                $0.trailing.equalTo(separators[index+1].snp.leading)

                $0.size.equalTo(Constants.ButtonSize)
            }
        }

        installForButton(chatButton, index: 0)
        installForButton(callButton, index: 1)
        installForButton(videoButton, index: 2)
    }
}

extension StaticTableChatButtonsCell {
    @objc func chatButtonPressed() {
        chatButtonHandler?()
    }

    @objc func callButtonPressed() {
        callButtonHandler?()
    }

    @objc func videoButtonPressed() {
        videoButtonHandler?()
    }
}

private extension StaticTableChatButtonsCell {
    func createButtonWithImageName(_ imageName: String,
                                   accessibilityLabel: String,
                                   accessibilityHint: String,
                                   action: Selector) -> UIButton {
        let image = UIImage.templateNamed(imageName)

        let button = UIButton()
        button.setImage(image, for: UIControlState())
        button.accessibilityLabel = accessibilityLabel
        button.accessibilityHint = accessibilityHint
        button.addTarget(self, action: action, for: .touchUpInside)
        customContentView.addSubview(button)

        return button
    }
}
