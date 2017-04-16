// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SnapKit

fileprivate struct Constants {
    static let verticalOffset = 7.0
    static let horizontalOffset = 20.0

    static let animationStepDuration = 0.7
}

class ChatTypingHeaderView: UIView {
    fileprivate let theme: Theme

    fileprivate var bubbleView: BubbleView!
    fileprivate var label: UILabel!

    fileprivate var animationTimer: Timer?
    fileprivate var animationStep: Int = 0

    init(theme: Theme) {
        self.theme = theme

        super.init(frame: CGRect.zero)

        createViews()
        installConstraints()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimation() {
        animationTimer = Timer.scheduledTimer(timeInterval: Constants.animationStepDuration, closure: {[weak self] _ -> Void in
            guard let sself = self else {
                return
            }

            sself.animationStep += 1
            if sself.animationStep > 2 {
                sself.animationStep = 0
            }

            sself.updateDotsString()
        }, repeats: true)
    }

    func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }

}

private extension ChatTypingHeaderView {
    func createViews() {
        bubbleView = BubbleView()
        bubbleView.text = "      "
        bubbleView.backgroundColor = theme.colorForType(.ChatIncomingBubble)
        bubbleView.isUserInteractionEnabled = false
        addSubview(bubbleView)

        label = UILabel()
        addSubview(label)

        updateDotsString()
    }

    func installConstraints() {
        bubbleView.snp.makeConstraints() {
            $0.top.equalTo(self).offset(Constants.verticalOffset)
            $0.bottom.equalTo(self).offset(-Constants.verticalOffset)
            $0.leading.equalTo(self).offset(Constants.horizontalOffset)
        }

        label.snp.makeConstraints() {
            $0.center.equalTo(bubbleView)
        }
    }

    func updateDotsString() {
        let mutable = NSMutableAttributedString()
        let font = UIFont.systemFont(ofSize: 22.0)
        let colorNormal = theme.colorForType(.ChatInformationText)
        let colorSelected = colorNormal.darkerColor().darkerColor()

        for i in 0..<3 {
            let color = (i == animationStep) ? colorSelected : colorNormal
            mutable.append(NSMutableAttributedString(string: "•",
                                                     attributes: [NSFontAttributeName : font,
                                                                  NSForegroundColorAttributeName: color]))
        }

        label.attributedText = mutable
    }
}
