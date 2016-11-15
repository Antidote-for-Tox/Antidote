// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

private struct Constants {
    static let TopContainerHeight = 80.0
    static let CallerLabelTopOffset = 20.0
    static let InfoLabelBottomOffset = -5.0
    static let LabelHorizontalOffset = 20.0
}

class CallBaseController: UIViewController {
    let theme: Theme

    let callerName: String

    var topContainer: UIView!
    var callerLabel: UILabel!
    var infoLabel: UILabel!

    fileprivate var topContainerTopConstraint: Constraint!

    init(theme: Theme, callerName: String) {
        self.theme = theme
        self.callerName = callerName

        super.init(nibName: nil, bundle: nil)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(.clear)

        addBlurredBackground()
        createTopViews()
        installConstraints()
    }

    /**
        Prepare for removal by disabling all active views.
     */
    func prepareForRemoval() {
        infoLabel.text = String(localized: "call_ended")
    }

    func toggleTopContainer(hidden: Bool) {
        let offset = hidden ? -topContainer.frame.size.height : 0.0
        topContainerTopConstraint.update(offset: offset)
    }
}

private extension CallBaseController {
    func addBlurredBackground() {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        effectView.frame = view.bounds

        view.insertSubview(effectView, at: 0)
        effectView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
    }

    func createTopViews() {
        topContainer = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.addSubview(topContainer)

        callerLabel = UILabel()
        callerLabel.text = callerName
        callerLabel.textColor = theme.colorForType(.CallTextColor)
        callerLabel.textAlignment = .center
        callerLabel.font = UIFont.systemFont(ofSize: 20.0)
        topContainer.addSubview(callerLabel)

        infoLabel = UILabel()
        infoLabel.textColor = theme.colorForType(.CallTextColor)
        infoLabel.textAlignment = .center
        infoLabel.font = UIFont.antidoteFontWithSize(18.0, weight: .light)
        topContainer.addSubview(infoLabel)
    }

    func installConstraints() {
        topContainer.snp.makeConstraints {
            topContainerTopConstraint = $0.top.equalTo(view).constraint
            $0.top.leading.trailing.equalTo(view)
            $0.height.equalTo(Constants.TopContainerHeight)
        }

        callerLabel.snp.makeConstraints {
            $0.top.equalTo(topContainer).offset(Constants.CallerLabelTopOffset)
            $0.leading.equalTo(topContainer).offset(Constants.LabelHorizontalOffset)
            $0.trailing.equalTo(topContainer).offset(-Constants.LabelHorizontalOffset)
        }

        infoLabel.snp.makeConstraints {
            $0.bottom.equalTo(topContainer).offset(Constants.InfoLabelBottomOffset)
            $0.leading.equalTo(topContainer).offset(Constants.LabelHorizontalOffset)
            $0.trailing.equalTo(topContainer).offset(-Constants.LabelHorizontalOffset)
        }
    }
}
