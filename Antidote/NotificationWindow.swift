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
    private let theme: Theme

    private var connectingView: UIView!
    private var connectingViewLabel: UILabel!
    private var connectingViewTopConstraint: Constraint!

    init(theme: Theme) {
        self.theme = theme

        super.init(frame: UIScreen.mainScreen().bounds)

        windowLevel = UIWindowLevelStatusBar + 500
        backgroundColor = .clearColor()
        hidden = false

        createRootViewController()
        createConnectingView()
        startConnectingViewAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        for subview in subviews {
            let converted = convertPoint(point, toView: subview)

            if subview.hitTest(converted, withEvent: event) != nil {
                return true
            }
        }

        return false
    }

    func showConnectingView(show: Bool, animated: Bool) {
        let showPreparation = { [unowned self] in
            self.connectingView.hidden = false
        }

        let showBlock = { [unowned self] in
            self.connectingViewTopConstraint.updateOffset(0.0)
            self.layoutIfNeeded()

            self.startConnectingViewAnimation()
        }

        let showCompletion = {}

        let hidePreparation = {}

        let hideBlock = { [unowned self] in
            self.connectingViewTopConstraint.updateOffset(-self.connectingView.frame.size.height)
            self.layoutIfNeeded()
            self.connectingViewLabel.layer.removeAllAnimations()
        }

        let hideCompletion = { [unowned self] in
            self.connectingView.hidden = true
        }

        show ? showPreparation() : hidePreparation()

        if animated {
            UIView.animateWithDuration(Constants.AnimationDuration, animations: {
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
        rootViewController!.view.backgroundColor = .clearColor()
    }

    func createConnectingView() {
        connectingView = UIView()
        connectingView.backgroundColor = theme.colorForType(.ConnectingBackground)
        addSubview(connectingView)

        connectingViewLabel = UILabel()
        connectingViewLabel.textColor = theme.colorForType(.ConnectingText)
        connectingViewLabel.backgroundColor = .clearColor()
        connectingViewLabel.text = String(localized: "connecting_label")
        connectingViewLabel.textAlignment = .Center
        connectingViewLabel.font = UIFont.antidoteFontWithSize(12.0, weight: .Light)
        connectingView.addSubview(connectingViewLabel)

        connectingView.snp_makeConstraints {
            connectingViewTopConstraint = $0.top.equalTo(self).constraint
            $0.leading.trailing.equalTo(self)
            $0.height.equalTo(UIApplication.sharedApplication().statusBarFrame.size.height)
        }

        connectingViewLabel.snp_makeConstraints {
            $0.edges.equalTo(connectingView)
        }
    }

    func startConnectingViewAnimation() {
        connectingViewLabel.alpha = 0.0
        UIView.animateWithDuration(Constants.ConnectingBlinkPeriod, delay: 0.0, options: [.Repeat, .Autoreverse], animations: {
            self.connectingViewLabel.alpha = 1.0
        }, completion: nil)
    }

    func stopConnectingViewAnimation() {
        stopConnectingViewAnimation()
    }
}
