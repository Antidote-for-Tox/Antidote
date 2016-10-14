// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class QRScannerAimView: UIView {
    private let dashLayer: CAShapeLayer

    init(theme: Theme) {
        dashLayer = CAShapeLayer()

        super.init(frame: CGRectZero)

        configureDashLayer(theme)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var frame: CGRect {
        didSet {
            dashLayer.path = UIBezierPath(rect: bounds).CGPath
            dashLayer.frame = bounds
        }
    }
}

private extension QRScannerAimView {
    func configureDashLayer(theme: Theme) {
        dashLayer.strokeColor = theme.colorForType(.LinkText).CGColor
        dashLayer.fillColor = UIColor.clearColor().CGColor
        dashLayer.lineDashPattern = [20, 5]
        dashLayer.lineWidth = 2.0
        layer.addSublayer(dashLayer)
    }
}
