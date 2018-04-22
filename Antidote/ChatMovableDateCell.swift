// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

protocol ChatMovableDateCellDelegate: class {
    func chatMovableDateCellCopyPressed(_ cell: ChatMovableDateCell)
    func chatMovableDateCellDeletePressed(_ cell: ChatMovableDateCell)
    func chatMovableDateCellMorePressed(_ cell: ChatMovableDateCell)
}

class ChatMovableDateCell: BaseCell {
    private static var __once: () = {
            var items = UIMenuController.shared.menuItems ?? [UIMenuItem]()
            items += [
                UIMenuItem(title: String(localized: "chat_more_menu_item"), action: #selector(moreAction))
            ]

            UIMenuController.shared.menuItems = items
        }()
    weak var delegate: ChatMovableDateCellDelegate?

    var canBeCopied = false

    /**
        Superview for content that should move while panning table to the left.
     */
    var movableContentView: UIView!

    var movableOffset: CGFloat = 0 {
        didSet {
            var offset = movableOffset

            if #available(iOS 9.0, *) {
                if UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == .rightToLeft {
                    offset = -offset
                }
            }

            if offset > 0.0 {
                offset = 0.0
            }

            let minOffset = -dateLabel.frame.size.width - 5.0

            if offset < minOffset {
                offset = minOffset
            }

            movableContentViewLeftConstraint.update(offset: offset)
            layoutIfNeeded()
        }
    }

    fileprivate var movableContentViewLeftConstraint: Constraint!
    fileprivate var dateLabel: UILabel!

    fileprivate var isShowingMenu: Bool = false
    fileprivate static var setupOnceToken: Int = 0

    override func setupWithTheme(_ theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let movableModel = model as? ChatMovableDateCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        _ = ChatMovableDateCell.__once

        dateLabel.text = movableModel.dateString
        dateLabel.textColor = theme.colorForType(.ChatListCellMessage)
    }

    override func createViews() {
        super.createViews()

        movableContentView = UIView()
        movableContentView.backgroundColor = .clear
        contentView.addSubview(movableContentView)

        dateLabel = UILabel()
        dateLabel.font = UIFont.antidoteFontWithSize(12.0, weight: .light)
        movableContentView.addSubview(dateLabel)

        // Using empty view for multiple selection background.
        multipleSelectionBackgroundView = UIView()
    }

    override func installConstraints() {
        super.installConstraints()

        movableContentView.snp.makeConstraints {
            $0.top.equalTo(contentView)
            movableContentViewLeftConstraint = $0.leading.equalTo(contentView).constraint
            $0.size.equalTo(contentView)
        }

        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(movableContentView)
            $0.leading.equalTo(movableContentView.snp.trailing)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if !isEditing {
            // don't call super in case of editing to avoid background change
            return
        }

        super.setSelected(selected, animated: animated)
    }
}

// Accessibility
extension ChatMovableDateCell {
    override var isAccessibilityElement: Bool {
        get {
            return true
        }
        set {}
    }

    override var accessibilityValue: String? {
        get {
            return dateLabel.text!
        }
        set {}
    }
}

extension ChatMovableDateCell: ChatEditable {
    // Override in subclass to enable menu
    @objc func shouldShowMenu() -> Bool {
        return false
    }

    // Override in subclass to enable menu
    @objc func menuTargetRect() -> CGRect {
        return CGRect.zero
    }

    @objc func willShowMenu() {
        isShowingMenu = true
    }

    @objc func willHideMenu() {
        isShowingMenu = false
    }
}

// Methods to make UIMenuController work.
extension ChatMovableDateCell {
    func isMenuActionSupportedByCell(_ action: Selector) -> Bool {
        switch action {
            case #selector(copy(_:)):
                return canBeCopied
            case #selector(delete(_:)):
                return true
            case #selector(moreAction):
                return true
            default:
                return false
        }
    }

    override func copy(_ sender: Any?) {
        delegate?.chatMovableDateCellCopyPressed(self)
    }

    override func delete(_ sender: Any?) {
        delegate?.chatMovableDateCellDeletePressed(self)
    }

    @objc func moreAction() {
        delegate?.chatMovableDateCellMorePressed(self)
    }
}
