//
//  StatusNavigationBar.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 06/11/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let StatusViewHeight: CGFloat = 30.0
    static let AnimationDuration: NSTimeInterval = 0.3
    static let ConnectingLabelBlinkPeriod: NSTimeInterval = 1.0
}

class StatusNavigationBar: UINavigationBar {
    private var theme: Theme!
    private weak var navigationController: UINavigationController!

    private var didConfigure: Bool = false

    private var statusView: UIView?
    private var statusLabel: UILabel!
    private var statusViewVisible: Bool = false

    /**
     * Call this method to configure status view. Otherwise it won't work.
     */
    func configureWithTheme(theme: Theme, navigationController: UINavigationController) {
        if didConfigure {
            return
        }
        didConfigure = true
        clipsToBounds = true

        self.theme = theme
        self.navigationController = navigationController
        createStatusView()
    }

    func showStatusView() {
        statusViewVisible = true

        updateTitleVerticalPositionTo(-Constants.StatusViewHeight)
        layoutSuperviewAnimated()
    }

    func hideStatusView() {
        statusViewVisible = false

        updateTitleVerticalPositionTo(0.0)
        layoutSuperviewAnimated()
    }

    override func sizeThatFits(size: CGSize) -> CGSize {
        var fits = super.sizeThatFits(size)

        if statusViewVisible {
            fits.height += Constants.StatusViewHeight
        }

        return fits
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let theStatusView = statusView {
            theStatusView.frame.origin.y = self.frame.size.height
            theStatusView.frame.size.width = self.frame.size.width
            theStatusView.frame.size.height = Constants.StatusViewHeight

            if statusViewVisible {
                theStatusView.frame.origin.y -= Constants.StatusViewHeight
            }
        }
    }
}

private extension StatusNavigationBar {
    func createStatusView() {
        statusView = UIView()
        statusView!.backgroundColor = theme.colorForType(.ConnectingBackground)
        addSubview(statusView!)

        statusLabel = UILabel()
        statusLabel.text = String(localized: "connecting_label")
        statusLabel.textColor = theme.colorForType(.ConnectingText)
        statusLabel.backgroundColor = .clearColor()
        statusLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightLight)
        statusView!.addSubview(statusLabel)

        statusLabel.snp_makeConstraints{ (make) -> Void in
            make.center.equalTo(statusView!)
        }
    }

    func updateTitleVerticalPositionTo(position: CGFloat) {
        setTitleVerticalPositionAdjustment(position, forBarMetrics: .Default)
        setTitleVerticalPositionAdjustment(position, forBarMetrics: .Compact)
        setTitleVerticalPositionAdjustment(position, forBarMetrics: .DefaultPrompt)
        setTitleVerticalPositionAdjustment(position, forBarMetrics: .CompactPrompt)
    }

    func layoutSuperviewAnimated() {
        // TODO This is really dirty.
        UIView.animateWithDuration(Constants.AnimationDuration, animations:{
            self.navigationController.setNavigationBarHidden(true, animated:false)
            self.navigationController.setNavigationBarHidden(false, animated:false)
        })
    }
}
