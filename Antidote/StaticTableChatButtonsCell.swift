//
//  StaticTableChatButtonsCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 24/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let ButtonSize = 50.0
    static let VerticalOffset = 8.0
}

class StaticTableChatButtonsCell: StaticTableBaseCell {
    private var chatButton: UIButton!
    private var callButton: UIButton!
    private var videoButton: UIButton!

    private var separators: [UIView]!

    private var chatButtonHandler: (Void -> Void)?
    private var callButtonHandler: (Void -> Void)?
    private var videoButtonHandler: (Void -> Void)?

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let buttonsModel = model as? StaticTableChatButtonsCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        selectionStyle = .None

        chatButtonHandler = buttonsModel.chatButtonHandler
        callButtonHandler = buttonsModel.callButtonHandler
        videoButtonHandler = buttonsModel.videoButtonHandler

        chatButton.enabled = buttonsModel.chatButtonEnabled
        callButton.enabled = buttonsModel.callButtonEnabled
        videoButton.enabled = buttonsModel.videoButtonEnabled
    }

    override func createViews() {
        super.createViews()

        chatButton = createButtonWithImageName("friend-card-chat", action: "chatButtonPressed")
        callButton = createButtonWithImageName("call-phone", action: "callButtonPressed")
        videoButton = createButtonWithImageName("call-video", action: "videoButtonPressed")

        separators = [UIView]()
        for _ in 0...3 {
            let sep = UIView()
            sep.backgroundColor = UIColor.clearColor()
            customContentView.addSubview(sep)
            separators.append(sep)
        }
    }

    override func installConstraints() {
        super.installConstraints()

        var previous: UIView? = nil
        for (index, sep) in separators.enumerate() {
            sep.snp_makeConstraints {
                if previous != nil {
                    $0.width.equalTo(previous!.snp_width)
                }

                if index == 0 {
                    $0.left.equalTo(customContentView)
                }

                if index == (separators.count-1) {
                    $0.right.equalTo(customContentView)
                }
            }

            previous = sep
        }

        func installForButton(button: UIButton, index: Int) {
            button.snp_makeConstraints {
                $0.top.equalTo(customContentView).offset(Constants.VerticalOffset)
                $0.bottom.equalTo(customContentView).offset(-Constants.VerticalOffset)

                $0.left.equalTo(separators[index].snp_right)
                $0.right.equalTo(separators[index+1].snp_left)

                $0.size.equalTo(Constants.ButtonSize)
            }
        }

        installForButton(chatButton, index: 0)
        installForButton(callButton, index: 1)
        installForButton(videoButton, index: 2)
    }
}

extension StaticTableChatButtonsCell {
    func chatButtonPressed() {
        chatButtonHandler?()
    }

    func callButtonPressed() {
        callButtonHandler?()
    }

    func videoButtonPressed() {
        videoButtonHandler?()
    }
}

private extension StaticTableChatButtonsCell {
    func createButtonWithImageName(imageName: String, action: Selector) -> UIButton {
        let image = UIImage(named: imageName)!.imageWithRenderingMode(.AlwaysTemplate)

        let button = UIButton()
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: action, forControlEvents: .TouchUpInside)
        customContentView.addSubview(button)

        return button
    }
}
