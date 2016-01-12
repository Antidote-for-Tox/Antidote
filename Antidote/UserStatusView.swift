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
    private var roundView: StaticBackgroundView!

    var theme: Theme? {
        didSet {
            userStatusWasUpdated()
        }
    }

    var userStatus: UserStatus {
        didSet {
            userStatusWasUpdated()
        }
    }

    init() {
        userStatus = .Offline

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
}

private extension UserStatusView {
    func createRoundView() {
        roundView = StaticBackgroundView()
        roundView.layer.masksToBounds = true
        addSubview(roundView)

        roundView.snp_makeConstraints {
            $0.center.equalTo(self)
            $0.size.equalTo(self).offset(-2.0)
        }
    }

    func userStatusWasUpdated() {
        switch userStatus {
            case .Offline:
                roundView.setStaticBackgroundColor(theme?.colorForType(.OfflineStatus))
            case .Online:
                roundView.setStaticBackgroundColor(theme?.colorForType(.OnlineStatus))
            case .Away:
                roundView.setStaticBackgroundColor(theme?.colorForType(.AwayStatus))
            case .Busy:
                roundView.setStaticBackgroundColor(theme?.colorForType(.BusyStatus))
        }

        setStaticBackgroundColor(theme?.colorForType(.StatusBackground))
        layer.cornerRadius = frame.size.width / 2

        roundView.layer.cornerRadius = roundView.frame.size.width / 2
    }
}
