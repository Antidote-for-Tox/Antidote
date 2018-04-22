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
    func pinInputView(_ view: PinInputView, numericButtonPressed i: Int)
    func pinInputViewDeleteButtonPressed(_ view: PinInputView)
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

    var descriptionText: String? {
        get {
            return descriptionLabel.text
        }
        set {
            descriptionLabel.text = newValue
        }
    }

    fileprivate let pinLength: Int

    fileprivate let topColorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    fileprivate let bottomColorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

    fileprivate var topLabel: UILabel!
    fileprivate var descriptionLabel: UILabel!
    fileprivate var dotsContainer: UIView!
    fileprivate var dotsImageViews = [UIImageView]()
    fileprivate var numericButtons = [UIButton]()
    fileprivate var deleteButton: UIButton!

    init(pinLength: Int, topColor: UIColor, bottomColor: UIColor) {
        self.pinLength = pinLength
        self.topColorComponents = topColor.components()
        self.bottomColorComponents = bottomColor.components()

        super.init(frame: CGRect.zero)

        createLabels()
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
    @objc func numericButtonPressed(_ button: UIButton) {
        guard let i = numericButtons.index(of: button) else {
            return
        }

        delegate?.pinInputView(self, numericButtonPressed: i)
    }

    @objc func deleteButtonPressed(_ button: UIButton) {
        delegate?.pinInputViewDeleteButtonPressed(self)
    }
}

private extension PinInputView {
    func createLabels() {
        topLabel = UILabel()
        topLabel.font = UIFont.antidoteFontWithSize(18.0, weight: .medium)
        addSubview(topLabel)

        descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.antidoteFontWithSize(16.0, weight: .light)
        addSubview(descriptionLabel)
    }

    func createDotsImageViews() {
        for _ in 0..<pinLength {
            dotsContainer = UIView()
            dotsContainer.backgroundColor = .clear
            addSubview(dotsContainer)

            let imageView = UIImageView()
            dotsContainer.addSubview(imageView)

            dotsImageViews.append(imageView)
        }
    }

    func createNumericButtons() {
        for i in 0...9 {
            let button = UIButton()
            button.setTitle("\(i)", for: UIControlState())
            button.titleLabel?.font = UIFont.systemFont(ofSize: 28.0)
            button.addTarget(self, action: #selector(PinInputView.numericButtonPressed(_:)), for: .touchUpInside)
            addSubview(button)

            numericButtons.append(button)
        }
    }

    func createDeleteButton() {
        deleteButton = UIButton(type: .system)
        // No localication on purpose
        deleteButton.setTitle("Delete", for: UIControlState())
        deleteButton.titleLabel?.font = .systemFont(ofSize: 20.0)
        deleteButton.addTarget(self, action: #selector(PinInputView.deleteButtonPressed(_:)), for: .touchUpInside)
        addSubview(deleteButton)
    }

    func installConstraints() {
        topLabel.snp.makeConstraints {
            $0.top.equalTo(self)
            $0.centerX.equalTo(self)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(topLabel.snp.bottom).offset(Constants.VerticalOffsetSmall)
            $0.centerX.equalTo(self)
        }

        installConstraintsForDotsViews()
        installConstraintsForZeroButton()
        installConstraintsForNumericButtons()

        deleteButton.snp.makeConstraints {
            $0.centerX.equalTo(numericButtons[9])
            $0.centerY.equalTo(numericButtons[0])
        }
    }

    func installConstraintsForDotsViews() {
        dotsContainer.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(Constants.VerticalOffsetBig)
            $0.centerX.equalTo(self)
        }

        for i in 0..<dotsImageViews.count {
            let imageView = dotsImageViews[i]

            imageView.snp.makeConstraints {
                $0.top.equalTo(dotsContainer)
                $0.bottom.equalTo(dotsContainer)
                $0.size.equalTo(Constants.DotsSize)

                if i == 0 {
                    $0.left.equalTo(dotsContainer)
                }
                else {
                    $0.left.equalTo(dotsImageViews[i - 1].snp.right).offset(Constants.DotsSize)
                }

                if i == (dotsImageViews.count - 1) {
                    $0.right.equalTo(dotsContainer)
                }
            }
        }
    }

    func installConstraintsForZeroButton() {
        numericButtons[0].snp.makeConstraints {
            $0.top.equalTo(numericButtons[8].snp.bottom).offset(Constants.VerticalOffsetSmall)
            $0.bottom.equalTo(self)

            $0.centerX.equalTo(numericButtons[8])
            $0.size.equalTo(Constants.ButtonSize)
        }
    }

    func installConstraintsForNumericButtons() {
        for i in 1...9 {
            let button = numericButtons[i]

            button.snp.makeConstraints {
                $0.size.equalTo(Constants.ButtonSize)

                switch i % 3 {
                case 1:
                    $0.left.equalTo(self)
                case 2:
                    $0.left.equalTo(numericButtons[i - 1].snp.right).offset(Constants.HorizontalOffset)
                default:
                    $0.left.equalTo(numericButtons[i - 1].snp.right).offset(Constants.HorizontalOffset)
                    $0.right.equalTo(self)
                }

                if i <= 3 {
                    $0.top.equalTo(dotsContainer.snp.bottom).offset(Constants.VerticalOffsetBig)
                }
                else if i <= 6 {
                    $0.top.equalTo(numericButtons[i - 3].snp.bottom).offset(Constants.VerticalOffsetSmall)
                }
                else {
                    $0.top.equalTo(numericButtons[i - 3].snp.bottom).offset(Constants.VerticalOffsetSmall)
                }
            }
        }
    }

    func updateButtonColors() {
        for button in numericButtons {
            let topColor = gradientColorAtPointY(button.frame.minY)
            let centerColor = gradientColorAtPointY(button.center.y)
            let bottomColor = gradientColorAtPointY(button.frame.maxY)

            let image = gradientCircleImage(topColor: topColor,
                                            bottomColor: bottomColor,
                                            size: Constants.ButtonSize,
                                            filled: false)
            let highlightedImage = gradientCircleImage(topColor: topColor,
                                                       bottomColor: bottomColor,
                                                       size: Constants.ButtonSize,
                                                       filled: true)

            button.setBackgroundImage(image, for: UIControlState())
            button.setBackgroundImage(highlightedImage, for: .highlighted)

            button.setTitleColor(centerColor, for: UIControlState())
            button.setTitleColor(.white, for: .highlighted)
        }
    }

    func updateOtherColors() {
        topLabel.textColor = gradientColorAtPointY(topLabel.center.y)
        descriptionLabel.textColor = gradientColorAtPointY(descriptionLabel.center.y)
        deleteButton.setTitleColor(gradientColorAtPointY(deleteButton.center.y), for: UIControlState())
    }

    func updateDotsImages() {
        let topColor = gradientColorAtPointY(dotsImageViews[0].frame.minY)
        let bottomColor = gradientColorAtPointY(dotsImageViews[0].frame.maxY)

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

    func gradientColorAtPointY(_ y: CGFloat) -> UIColor {
        guard self.frame.size.height > 0 else {
            log("PinInputView should not be nil")
            return .clear
        }

        guard y >= 0 && y <= self.frame.size.height else {
            log("Point y \(y) is outside of view")
            return .clear
        }

        let percent = y / self.frame.size.height

        let red = topColorComponents.red + percent * (bottomColorComponents.red - topColorComponents.red)
        let green = topColorComponents.green + percent * (bottomColorComponents.green - topColorComponents.green)
        let blue = topColorComponents.blue + percent * (bottomColorComponents.blue - topColorComponents.blue)
        let alpha = topColorComponents.alpha + percent * (bottomColorComponents.alpha - topColorComponents.alpha)

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    func gradientCircleImage(topColor: UIColor, bottomColor: UIColor, size: CGFloat, filled: Bool) -> UIImage {
        let radius = size * UIScreen.main.scale / 2

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size.width = 2 * radius
        gradientLayer.frame.size.height = 2 * radius
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.masksToBounds = true
        gradientLayer.cornerRadius = radius

        if !filled {
            // apply mask
            let lineWidth: CGFloat = 2.0

            let path = UIBezierPath()
            path.addArc(withCenter: CGPoint(x: radius, y: radius),
                                radius: radius - lineWidth,
                                startAngle: 0.0,
                                endAngle: CGFloat(2 * M_PI),
                                clockwise: true)

            let mask = CAShapeLayer()
            mask.frame = gradientLayer.frame
            mask.path = path.cgPath
            mask.lineWidth = lineWidth
            mask.fillColor = UIColor.clear.cgColor
            mask.strokeColor = UIColor.black.cgColor

            gradientLayer.mask = mask
        }
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
