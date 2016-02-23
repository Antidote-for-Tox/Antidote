//
//  StaticTableMultiChoiceButtonCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 22.02.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let HorizontalOffset = 8.0
    static let Height = 40.0
}

class StaticTableMultiChoiceButtonCell: StaticTableBaseCell {
    private var buttonsContainer: UIView!

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let multiModel = model as? StaticTableMultiChoiceButtonCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        selectionStyle = .None

        _ = buttonsContainer.subviews.map {
            $0.removeFromSuperview()
        }

        var previousButton: RoundedButton?

        for buttonModel in multiModel.buttons {
            let button = addButtonWithTheme(theme, model: buttonModel)

            button.snp_makeConstraints {
                $0.top.bottom.equalTo(buttonsContainer)

                if let previousButton = previousButton {
                    $0.left.equalTo(previousButton.snp_right).offset(Constants.HorizontalOffset)
                    $0.width.equalTo(previousButton)
                }
                else {
                    $0.left.equalTo(buttonsContainer)
                }
            }
            previousButton = button
        }

        if let previousButton = previousButton {
            previousButton.snp_makeConstraints {
                $0.right.equalTo(buttonsContainer)
            }
        }
    }

    override func createViews() {
        super.createViews()

        buttonsContainer = UIView()
        buttonsContainer.backgroundColor = .clearColor()
        customContentView.addSubview(buttonsContainer)
    }

    override func installConstraints() {
        super.installConstraints()

        buttonsContainer.snp_makeConstraints {
            $0.left.right.equalTo(customContentView)
            $0.centerY.equalTo(customContentView)
            $0.height.equalTo(Constants.Height)
        }
    }

    func addButtonWithTheme(theme: Theme, model: StaticTableMultiChoiceButtonCellModel.ButtonModel) -> RoundedButton {
        let type: RoundedButton.ButtonType

        switch model.style {
            case .Negative:
                type = .RunningNegative
            case .Positive:
                type = .RunningPositive
        }

        let button = RoundedButton(theme: theme, type: type)
        button.setTitle(model.title, forState: .Normal)
        button.addTarget(model.target, action: model.action, forControlEvents: .TouchUpInside)
        buttonsContainer.addSubview(button)

        return button
    }
}
