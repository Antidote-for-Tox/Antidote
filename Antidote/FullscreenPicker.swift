//
//  FullscreenPicker.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 21/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let AnimationDuration = 0.3
    static let ToolbarHeight: CGFloat = 44.0
}

protocol FullscreenPickerDelegate: class {
    func fullscreenPicker(picker: FullscreenPicker, willDismissWithSelectedIndex index: Int)
}

class FullscreenPicker: UIView {
    weak var delegate: FullscreenPickerDelegate?

    private var theme: Theme

    private var blackoutButton: UIButton!
    private var toolbar: UIToolbar!
    private var picker: UIPickerView!

    private var pickerBottomConstraint: Constraint!

    private let stringsArray: [String]

    init(theme: Theme, strings: [String], selectedIndex: Int) {
        self.theme = theme
        self.stringsArray = strings

        super.init(frame: CGRectZero)

        configureSelf()
        createSubviews()
        installConstraints()

        picker.selectRow(selectedIndex, inComponent: 0, animated: false)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showAnimatedInView(view: UIView) {
        view.addSubview(self)

        snp_makeConstraints{ (make) -> Void in
            make.edges.equalTo(view)
        }

        show()
    }
}

// MARK: Actions
extension FullscreenPicker {
    func doneButtonPressed() {
        delegate?.fullscreenPicker(self, willDismissWithSelectedIndex: picker.selectedRowInComponent(0))
        hide()
    }
}

extension FullscreenPicker: UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stringsArray.count
    }
}

extension FullscreenPicker: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return stringsArray[row]
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        picker.reloadAllComponents()
    }
}

private extension FullscreenPicker {
    func configureSelf() {
        backgroundColor = .clearColor()
    }

    func createSubviews() {
        blackoutButton = UIButton()
        blackoutButton.backgroundColor = theme.colorForType(.TranslucentBackground)
        blackoutButton.addTarget(self, action: "doneButtonPressed", forControlEvents:.TouchUpInside)
        addSubview(blackoutButton)

        toolbar = UIToolbar()
        toolbar.tintColor = theme.colorForType(.LoginButtonText)
        toolbar.barTintColor = theme.loginNavigationBarColor
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil),
            UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneButtonPressed")
        ]
        addSubview(toolbar)

        picker = UIPickerView()
        // Picker is always white, despite choosen theme
        picker.backgroundColor = .whiteColor()
        picker.delegate = self
        picker.dataSource = self
        addSubview(picker)
    }

    func installConstraints() {
        blackoutButton.snp_makeConstraints{ (make) -> Void in
            make.edges.equalTo(self)
        }

        toolbar.snp_makeConstraints{ (make) -> Void in
            make.bottom.equalTo(self.picker.snp_top)
            make.height.equalTo(Constants.ToolbarHeight)
            make.width.equalTo(self)
        }

        picker.snp_makeConstraints{ (make) -> Void in
            make.width.equalTo(self)
            pickerBottomConstraint = make.bottom.equalTo(self).constraint
        }
    }

    func show() {
        blackoutButton.alpha = 0.0
        pickerBottomConstraint.updateOffset(picker.frame.size.height + Constants.ToolbarHeight)

        layoutIfNeeded()

        UIView.animateWithDuration(Constants.AnimationDuration) {
            self.blackoutButton.alpha = 1.0
            self.pickerBottomConstraint.updateOffset(0.0)

            self.layoutIfNeeded()
        }
    }

    func hide() {
        UIView.animateWithDuration(Constants.AnimationDuration, animations: {
            self.blackoutButton.alpha = 0.0
            self.pickerBottomConstraint.updateOffset(self.picker.frame.size.height + Constants.ToolbarHeight)

            self.layoutIfNeeded()
        }, completion: { finished in
            self.removeFromSuperview()
        })
    }
}
