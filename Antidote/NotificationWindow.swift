// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

private struct Constants {
    static let AnimationDuration = 0.3
    static let ConnectingBlinkPeriod = 1.0
}

class NotificationWindow: UIWindow {
    fileprivate let theme: Theme

    fileprivate var connectingView: UIView!
    fileprivate var connectingViewLabel: UILabel!
    fileprivate var connectingViewTopConstraint: Constraint!

    init(theme: Theme) {
        self.theme = theme

        super.init(frame: UIScreen.main.bounds)

        windowLevel = UIWindowLevelStatusBar + 500
        backgroundColor = .clear
        isHidden = false

        createRootViewController()
        createConnectingView()
        startConnectingViewAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            let converted = convert(point, to: subview)

            if subview.hitTest(converted, with: event) != nil {
                return true
            }
        }

        return false
    }

    func showConnectingView(_ show: Bool, animated: Bool) {
        let showPreparation = { [unowned self] in
            self.connectingView.isHidden = false
        }

        let showBlock = { [unowned self] in
            self.connectingViewTopConstraint.update(offset: 0.0)
            self.layoutIfNeeded()

            self.startConnectingViewAnimation()
        }

        let showCompletion = {}

        let hidePreparation = {}

        let hideBlock = { [unowned self] in
            self.connectingViewTopConstraint.update(offset: -self.connectingView.frame.size.height)
            self.layoutIfNeeded()
            self.connectingViewLabel.layer.removeAllAnimations()
        }

        let hideCompletion = { [unowned self] in
            self.connectingView.isHidden = true
        }

        show ? showPreparation() : hidePreparation()

        if animated {
            UIView.animate(withDuration: Constants.AnimationDuration, animations: {
                show ? showBlock() : hideBlock()
            }, completion: { finished in
                show ? showCompletion() : hideCompletion()
            })
        }
        else {
            show ? showBlock() : hideBlock()
            show ? showCompletion() : hideCompletion()
        }
    }
}

private extension NotificationWindow {
    func createRootViewController() {
        rootViewController = UIViewController()
        rootViewController!.view = ViewPassingGestures()
        rootViewController!.view.backgroundColor = .clear
    }

    func createConnectingView() {
        connectingView = UIView()
        connectingView.backgroundColor = theme.colorForType(.ConnectingBackground)
        addSubview(connectingView)

        connectingViewLabel = UILabel()
        connectingViewLabel.textColor = theme.colorForType(.ConnectingText)
        connectingViewLabel.backgroundColor = .clear
        connectingViewLabel.text = String(localized: "connecting_label")
        connectingViewLabel.textAlignment = .center
        connectingViewLabel.font = UIFont.antidoteFontWithSize(12.0, weight: .light)
        connectingView.addSubview(connectingViewLabel)

        connectingView.snp.makeConstraints {
            connectingViewTopConstraint = $0.top.equalTo(self).constraint
            $0.leading.trailing.equalTo(self)
            $0.height.equalTo(UIApplication.shared.statusBarFrame.size.height)
        }

        connectingViewLabel.snp.makeConstraints {
            $0.edges.equalTo(connectingView)
        }
    }

    func startConnectingViewAnimation() {
        connectingViewLabel.alpha = 0.0
        UIView.animate(withDuration: Constants.ConnectingBlinkPeriod, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.connectingViewLabel.alpha = 1.0
        }, completion: nil)
    }

    func stopConnectingViewAnimation() {
        stopConnectingViewAnimation()
    }
}
