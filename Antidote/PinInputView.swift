// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

private struct Constants {
    static let DotsSize: CGFloat = 16
    static let ButtonSize: CGFloat = 75
    static let VerticalOffsetSmall: CGFloat = 12
    static let VerticalOffsetBig: CGFloat = 17
    static let HorizontalOffset: CGFloat = 17
}

protocol PinInputViewDelegate: class {
    func pinInputView(view: PinInputView, numericButtonPressed i: Int)
    func pinInputViewDeleteButtonPressed(view: PinInputView)
}

class PinInputView: UIView {
    weak var delegate: PinInputViewDelegate?

    /// Entered numbers. Must be in 0...pinLength range.
    var enteredNumbersCount: Int = 0 {
        didSet {
            enteredNumbersCount = max(enteredNumbersCount, 0)
            enteredNumbersCount = min(enteredNumbersCount, pinLength)

            updateDotsImages()
        }
    }

    var topText: String {
        get {
            return topLabel.text!
        }
        set {
            topLabel.text = newValue
        }
    }

    private let pinLength: Int

    private let topColorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    private let bottomColorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

    private var topLabel: UILabel!
    private var dotsContainer: UIView!
    private var dotsImageViews = [UIImageView]()
    private var numericButtons = [UIButton]()
    private var deleteButton: UIButton!

    init(pinLength: Int, topColor: UIColor, bottomColor: UIColor) {
        self.pinLength = pinLength
        self.topColorComponents = topColor.components()
        self.bottomColorComponents = bottomColor.components()

        super.init(frame: CGRectZero)

        createTopLabel()
        createDotsImageViews()
        createNumericButtons()
        createDeleteButton()

        installConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
        Applies gradient colors to all subviews.
        Call this method after adding PinInputView to superview.
    */
    func applyColors() {
        guard superview != nil else {
            fatalError("superview shouldn't be nil")
        }

        layoutIfNeeded()
        updateButtonColors()
        updateOtherColors()

        updateDotsImages()
    }
}

extension PinInputView {
    func numericButtonPressed(button: UIButton) {
        guard let i = numericButtons.indexOf(button) else {
            return
        }

        delegate?.pinInputView(self, numericButtonPressed: i)
    }

    func deleteButtonPressed(button: UIButton) {
        delegate?.pinInputViewDeleteButtonPressed(self)
    }
}

private extension PinInputView {
    func createTopLabel() {
        topLabel = UILabel()
        topLabel.font = UIFont.antidoteFontWithSize(18.0, weight: .Medium)
        addSubview(topLabel)
    }

    func createDotsImageViews() {
        for _ in 0..<pinLength {
            dotsContainer = UIView()
            dotsContainer.backgroundColor = .clearColor()
            addSubview(dotsContainer)

            let imageView = UIImageView()
            dotsContainer.addSubview(imageView)

            dotsImageViews.append(imageView)
        }
    }

    func createNumericButtons() {
        for i in 0...9 {
            let button = UIButton()
            button.setTitle("\(i)", forState: .Normal)
            button.titleLabel?.font = UIFont.systemFontOfSize(28.0)
            button.addTarget(self, action: #selector(PinInputView.numericButtonPressed(_:)), forControlEvents: .TouchUpInside)
            addSubview(button)

            numericButtons.append(button)
        }
    }

    func createDeleteButton() {
        deleteButton = UIButton(type: .System)
        // No localication on purpose
        deleteButton.setTitle("Delete", forState: .Normal)
        deleteButton.titleLabel?.font = .systemFontOfSize(20.0)
        deleteButton.addTarget(self, action: #selector(PinInputView.deleteButtonPressed(_:)), forControlEvents: .TouchUpInside)
        addSubview(deleteButton)
    }

    func installConstraints() {
        topLabel.snp_makeConstraints {
            $0.top.equalTo(self)
            $0.centerX.equalTo(self)
        }

        installConstraintsForDotsViews()
        installConstraintsForZeroButton()
        installConstraintsForNumericButtons()

        deleteButton.snp_makeConstraints {
            $0.centerX.equalTo(numericButtons[9])
            $0.centerY.equalTo(numericButtons[0])
        }
    }

    func installConstraintsForDotsViews() {
        dotsContainer.snp_makeConstraints {
            $0.top.equalTo(topLabel.snp_bottom).offset(Constants.VerticalOffsetBig)
            $0.centerX.equalTo(self)
        }

        for i in 0..<dotsImageViews.count {
            let imageView = dotsImageViews[i]

            imageView.snp_makeConstraints {
                $0.top.equalTo(dotsContainer)
                $0.bottom.equalTo(dotsContainer)
                $0.size.equalTo(Constants.DotsSize)

                if i == 0 {
                    $0.left.equalTo(dotsContainer)
                }
                else {
                    $0.left.equalTo(dotsImageViews[i - 1].snp_right).offset(Constants.DotsSize)
                }

                if i == (dotsImageViews.count - 1) {
                    $0.right.equalTo(dotsContainer)
                }
            }
        }
    }

    func installConstraintsForZeroButton() {
        numericButtons[0].snp_makeConstraints {
            $0.top.equalTo(numericButtons[8].snp_bottom).offset(Constants.VerticalOffsetSmall)
            $0.bottom.equalTo(self)

            $0.centerX.equalTo(numericButtons[8])
            $0.size.equalTo(Constants.ButtonSize)
        }
    }

    func installConstraintsForNumericButtons() {
        for i in 1...9 {
            let button = numericButtons[i]

            button.snp_makeConstraints {
                $0.size.equalTo(Constants.ButtonSize)

                switch i % 3 {
                case 1:
                    $0.left.equalTo(self)
                case 2:
                    $0.left.equalTo(numericButtons[i - 1].snp_right).offset(Constants.HorizontalOffset)
                default:
                    $0.left.equalTo(numericButtons[i - 1].snp_right).offset(Constants.HorizontalOffset)
                    $0.right.equalTo(self)
                }

                if i <= 3 {
                    $0.top.equalTo(dotsContainer.snp_bottom).offset(Constants.VerticalOffsetBig)
                }
                else if i <= 6 {
                    $0.top.equalTo(numericButtons[i - 3].snp_bottom).offset(Constants.VerticalOffsetSmall)
                }
                else {
                    $0.top.equalTo(numericButtons[i - 3].snp_bottom).offset(Constants.VerticalOffsetSmall)
                }
            }
        }
    }

    func updateButtonColors() {
        for button in numericButtons {
            let topColor = gradientColorAtPointY(CGRectGetMinY(button.frame))
            let centerColor = gradientColorAtPointY(button.center.y)
            let bottomColor = gradientColorAtPointY(CGRectGetMaxY(button.frame))

            let image = gradientCircleImage(topColor: topColor,
                                            bottomColor: bottomColor,
                                            size: Constants.ButtonSize,
                                            filled: false)
            let highlightedImage = gradientCircleImage(topColor: topColor,
                                                       bottomColor: bottomColor,
                                                       size: Constants.ButtonSize,
                                                       filled: true)

            button.setBackgroundImage(image, forState: .Normal)
            button.setBackgroundImage(highlightedImage, forState: .Highlighted)

            button.setTitleColor(centerColor, forState: .Normal)
            button.setTitleColor(.whiteColor(), forState: .Highlighted)
        }
    }

    func updateOtherColors() {
        topLabel.textColor = gradientColorAtPointY(topLabel.center.y)
        deleteButton.setTitleColor(gradientColorAtPointY(deleteButton.center.y), forState: .Normal)
    }

    func updateDotsImages() {
        let topColor = gradientColorAtPointY(CGRectGetMinY(dotsImageViews[0].frame))
        let bottomColor = gradientColorAtPointY(CGRectGetMaxY(dotsImageViews[0].frame))

        let empty = gradientCircleImage(topColor: topColor,
                                        bottomColor: bottomColor,
                                        size: Constants.DotsSize,
                                        filled: false)
        let filled = gradientCircleImage(topColor: topColor,
                                        bottomColor: bottomColor,
                                        size: Constants.DotsSize,
                                        filled: true)

        for i in 0..<dotsImageViews.count {
            let imageView = dotsImageViews[i]
            imageView.image = (i < enteredNumbersCount) ? filled : empty
        }
    }

    func gradientColorAtPointY(y: CGFloat) -> UIColor {
        guard self.frame.size.height > 0 else {
            log("PinInputView should not be nil")
            return .clearColor()
        }

        guard y >= 0 && y <= self.frame.size.height else {
            log("Point y \(y) is outside of view")
            return .clearColor()
        }

        let percent = y / self.frame.size.height

        let red = topColorComponents.red + percent * (bottomColorComponents.red - topColorComponents.red)
        let green = topColorComponents.green + percent * (bottomColorComponents.green - topColorComponents.green)
        let blue = topColorComponents.blue + percent * (bottomColorComponents.blue - topColorComponents.blue)
        let alpha = topColorComponents.alpha + percent * (bottomColorComponents.alpha - topColorComponents.alpha)

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    func gradientCircleImage(topColor topColor: UIColor, bottomColor: UIColor, size: CGFloat, filled: Bool) -> UIImage {
        let radius = size * UIScreen.mainScreen().scale / 2

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size.width = 2 * radius
        gradientLayer.frame.size.height = 2 * radius
        gradientLayer.colors = [topColor.CGColor, bottomColor.CGColor]
        gradientLayer.masksToBounds = true
        gradientLayer.cornerRadius = radius

        if !filled {
            // apply mask
            let lineWidth: CGFloat = 2.0

            let path = UIBezierPath()
            path.addArcWithCenter(CGPoint(x: radius, y: radius),
                                radius: radius - lineWidth,
                                startAngle: 0.0,
                                endAngle: CGFloat(2 * M_PI),
                                clockwise: true)

            let mask = CAShapeLayer()
            mask.frame = gradientLayer.frame
            mask.path = path.CGPath
            mask.lineWidth = lineWidth
            mask.fillColor = UIColor.clearColor().CGColor
            mask.strokeColor = UIColor.blackColor().CGColor

            gradientLayer.mask = mask
        }
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
