// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class QRScannerAimView: UIView {
    fileprivate let dashLayer: CAShapeLayer

    init(theme: Theme) {
        dashLayer = CAShapeLayer()

        super.init(frame: CGRect.zero)

        configureDashLayer(theme)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var frame: CGRect {
        didSet {
            dashLayer.path = UIBezierPath(rect: bounds).cgPath
            dashLayer.frame = bounds
        }
    }
}

private extension QRScannerAimView {
    func configureDashLayer(_ theme: Theme) {
        dashLayer.strokeColor = theme.colorForType(.LinkText).cgColor
        dashLayer.fillColor = UIColor.clear.cgColor
        dashLayer.lineDashPattern = [20, 5]
        dashLayer.lineWidth = 2.0
        layer.addSublayer(dashLayer)
    }
}
