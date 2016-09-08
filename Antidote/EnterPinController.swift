//
//  EnterPinController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02/09/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation
import SnapKit
import AudioToolbox

private struct Constants {
    static let PinLength = 4
}

protocol EnterPinControllerDelegate: class {
    func enterPinController(controller: EnterPinController, successWithPin pin: String)
}

class EnterPinController: UIViewController {
    enum State {
        case ValidatePin(validPin: String)
        case SetPin
        case ConfirmPin(validPin: String)
    }

    weak var delegate: EnterPinControllerDelegate?

    private let theme: Theme
    private let state: State

    private var pinInputView: PinInputView!

    private var enteredString: String = ""

    init(theme: Theme, state: State) {
        self.theme = theme
        self.state = state

        super.init(nibName: nil, bundle: nil)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        createViews()
        installConstraints()

        pinInputView.applyColors()
    }
}

extension EnterPinController: PinInputViewDelegate {
    func pinInputView(view: PinInputView, numericButtonPressed i: Int) {
        guard enteredString.characters.count < Constants.PinLength else {
            return
        }

        enteredString += "\(i)"

        if enteredString.characters.count == Constants.PinLength {
            switch state {
                case .ValidatePin(let validPin):
                     if enteredString == validPin {
                         delegate?.enterPinController(self, successWithPin: enteredString)
                     }
                     else {
                         enteredString = ""
                         pinInputView.topText = String(localized: "pin_incorrect")
                         AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                     }
                case .SetPin:
                     break
                case .ConfirmPin(_):
                     break
            }
        }

        view.enteredNumbersCount = enteredString.characters.count
    }

    func pinInputViewDeleteButtonPressed(view: PinInputView) {
        guard enteredString.characters.count > 0 else {
            return
        }

        enteredString = String(enteredString.characters.dropLast())
        view.enteredNumbersCount = enteredString.characters.count
    }
}

private extension EnterPinController {
    func createViews() {
        pinInputView = PinInputView(pinLength: Constants.PinLength, topColor: .greenColor(), bottomColor: .blueColor())
        pinInputView.delegate = self
        view.addSubview(pinInputView)

        switch state {
            case .ValidatePin:
                pinInputView.topText = String(localized: "pin_enter_to_unlock")
            case .SetPin:
                pinInputView.topText = String(localized: "pin_set")
            case .ConfirmPin:
                pinInputView.topText = String(localized: "pin_confirm")
        }
    }

    func installConstraints() {
        pinInputView.snp_makeConstraints {
            $0.center.equalTo(view)
        }
    }
}
