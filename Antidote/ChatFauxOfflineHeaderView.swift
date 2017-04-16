// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SnapKit

fileprivate struct Constants {
    static let verticalOffset = 7.0
    static let maxLabelWidth: CGFloat = 280.0
}

class ChatFauxOfflineHeaderView: UIView {
    fileprivate var label: UILabel!

    init(theme: Theme) {
        super.init(frame: CGRect.zero)

        backgroundColor = theme.colorForType(.NormalBackground)
        createViews(theme: theme)
        installConstraints()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ChatFauxOfflineHeaderView {
    func createViews(theme: Theme) {
        label = UILabel()
        label.text = String(localized: "chat_pending_faux_offline_messages")
        label.font = UIFont.antidoteFontWithSize(14.0, weight: .medium)
        label.textAlignment = .center
        label.textColor = theme.colorForType(.ChatInformationText)
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = Constants.maxLabelWidth
        addSubview(label)
    }

    func installConstraints() {
        label.snp.makeConstraints {
            $0.top.equalTo(self).offset(Constants.verticalOffset)
            $0.bottom.equalTo(self).offset(-Constants.verticalOffset)
            $0.centerX.equalTo(self)
            $0.width.equalTo(Constants.maxLabelWidth)
        }
    }
}
