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

    static let NotificationAnimationDuration = 0.3
    static let NotificationContainerHeight = 44.0
}

class NotificationWindow: UIWindow {
    private let theme: Theme

    private var connectingView: UIView!
    private var connectingViewTopConstraint: Constraint!

    private var notificationContainer: UIView!
    private var previousNotificationViewWithTopConstraint: (NotificationView, Constraint)?

    init(theme: Theme) {
        self.theme = theme

        super.init(frame: UIScreen.mainScreen().bounds)

        windowLevel = UIWindowLevelStatusBar + 1
        makeKeyAndVisible()

        createRootViewController()
        createConnectingView()
        createNotificationContainer()
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

    /**
        Pushes notification view from top. Previous notification view (if any) will be replaced with passed one.
        If nil is passed, simply removes previous view.
     */
    func pushNotificationView(next: NotificationView?) {
        if let (previous, topConstraint) = previousNotificationViewWithTopConstraint {
            hideNotificationView(previous, topConstraint: topConstraint)
            previousNotificationViewWithTopConstraint = nil
        }

        if let next = next {
            let topConstraint = showNotificationView(next)
            previousNotificationViewWithTopConstraint = (next, topConstraint)
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

        connectingView!.snp_makeConstraints {
            connectingViewTopConstraint = $0.top.equalTo(self).constraint
            $0.left.right.equalTo(self)
            $0.height.equalTo(UIApplication.sharedApplication().statusBarFrame.size.height)
        }

        label.snp_makeConstraints {
            $0.edges.equalTo(connectingView!)
        }
    }

    func createNotificationContainer() {
        notificationContainer = UIView()
        notificationContainer.backgroundColor = .clearColor()
        notificationContainer.clipsToBounds = true
        addSubview(notificationContainer)

        notificationContainer.snp_makeConstraints {
            $0.top.equalTo(connectingView.snp_bottom)
            $0.left.right.equalTo(self)
            $0.height.equalTo(Constants.NotificationContainerHeight)
        }
    }

    /**
        Returns view's top constraint.
     */
    func showNotificationView(view: NotificationView) -> Constraint {
        notificationContainer.addSubview(view)

        var topConstraint: Constraint!

        view.snp_makeConstraints {
            topConstraint = $0.top.equalTo(notificationContainer).offset(-Constants.NotificationContainerHeight).constraint
            $0.left.right.equalTo(notificationContainer)
            $0.height.equalTo(notificationContainer)
        }
        notificationContainer.layoutIfNeeded()

        UIView.animateWithDuration(Constants.NotificationAnimationDuration) { [unowned self] in
            topConstraint.updateOffset(0.0)
            self.notificationContainer.layoutIfNeeded()
        }

        return topConstraint
    }

    func hideNotificationView(view: NotificationView, topConstraint: Constraint) {
        UIView.animateWithDuration(Constants.NotificationAnimationDuration, animations: { [unowned self] in
            topConstraint.updateOffset(Constants.NotificationContainerHeight)
            self.notificationContainer.layoutIfNeeded()
        }, completion: { finished in
            view.removeFromSuperview()
        })
    }
}
