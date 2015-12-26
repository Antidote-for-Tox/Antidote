//
//  QRScannerAimView.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 26/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

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
