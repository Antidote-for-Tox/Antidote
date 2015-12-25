//
//  NotificationWindow.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 25/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let AnimationDuration = 0.3
    static let ConnectingBlinkPeriod = 1.0
}

class NotificationWindow: UIWindow {
    private let theme: Theme

    private var connectingView: UIView!
    private var connectingViewTopConstraint: Constraint!

    init(theme: Theme) {
        self.theme = theme

        super.init(frame: UIScreen.mainScreen().bounds)

        windowLevel = UIWindowLevelStatusBar + 1
        makeKeyAndVisible()

        createRootViewController()
        createConnectingView()
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
        let showPreparation = {
            self.connectingView.hidden = false
        }

        let showBlock = {
            self.connectingViewTopConstraint.updateOffset(0.0)
            self.layoutIfNeeded()
        }

        let showCompletion = {}

        let hidePreparation = {}

        let hideBlock = {
            self.connectingViewTopConstraint.updateOffset(-self.connectingView.frame.size.height)
            self.layoutIfNeeded()
        }

        let hideCompletion = {
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
        connectingView!.backgroundColor = theme.colorForType(.ConnectingBackground)
        addSubview(connectingView!)

        let label = UILabel()
        label.textColor = theme.colorForType(.ConnectingText)
        label.backgroundColor = .clearColor()
        label.text = String(localized: "connecting_label")
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(12.0, weight: UIFontWeightLight)
        connectingView!.addSubview(label)

        label.alpha = 0.0
        UIView.animateWithDuration(Constants.ConnectingBlinkPeriod, delay: 0.0, options: [.Repeat, .Autoreverse], animations: {
            label.alpha = 1.0
        }, completion: nil)

        connectingView!.snp_makeConstraints{ (make) -> Void in
            connectingViewTopConstraint = make.top.equalTo(self).constraint
            make.left.right.equalTo(self)
            make.height.equalTo(UIApplication.sharedApplication().statusBarFrame.size.height)
        }

        label.snp_makeConstraints{ (make) -> Void in
            make.edges.equalTo(connectingView!)
        }
    }
}
