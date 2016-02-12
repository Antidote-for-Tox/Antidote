//
//  UserStatusView.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 20/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

class UserStatusView: StaticBackgroundView {
    struct Constants {
        static let DefaultSize = 12.0
    }

    private var roundView: StaticBackgroundView?

    var theme: Theme? {
        didSet {
            userStatusWasUpdated()
        }
    }

    var showExternalCircle: Bool = true {
        didSet {
            userStatusWasUpdated()
        }
    }

    var userStatus: UserStatus = .Offline {
        didSet {
            userStatusWasUpdated()
        }
    }

    init() {
        super.init(frame: CGRectZero)

        createRoundView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        userStatusWasUpdated()
    }

    override var frame: CGRect {
        didSet {
            userStatusWasUpdated()
        }
    }
}

private extension UserStatusView {
    func createRoundView() {
        roundView = StaticBackgroundView()
        roundView!.layer.masksToBounds = true
        addSubview(roundView!)

        roundView!.snp_makeConstraints {
            $0.center.equalTo(self)
            $0.size.equalTo(self).offset(-2.0)
        }
    }

    func userStatusWasUpdated() {
        if let theme = theme {
            switch userStatus {
                case .Offline:
                    roundView?.setStaticBackgroundColor(theme.colorForType(.OfflineStatus))
                case .Online:
                    roundView?.setStaticBackgroundColor(theme.colorForType(.OnlineStatus))
                case .Away:
                    roundView?.setStaticBackgroundColor(theme.colorForType(.AwayStatus))
                case .Busy:
                    roundView?.setStaticBackgroundColor(theme.colorForType(.BusyStatus))
            }

            let background = showExternalCircle ? theme.colorForType(.StatusBackground) : .clearColor()
            setStaticBackgroundColor(background)
        }

        layer.cornerRadius = frame.size.width / 2

        roundView?.layer.cornerRadius = roundView!.frame.size.width / 2
    }
}
