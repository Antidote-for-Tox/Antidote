// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
                    $0.leading.equalTo(previousButton.snp_trailing).offset(Constants.HorizontalOffset)
                    $0.width.equalTo(previousButton)
                }
                else {
                    $0.leading.equalTo(buttonsContainer)
                }
            }
            previousButton = button
        }

        if let previousButton = previousButton {
            previousButton.snp_makeConstraints {
                $0.trailing.equalTo(buttonsContainer)
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
            $0.leading.trailing.equalTo(customContentView)
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
