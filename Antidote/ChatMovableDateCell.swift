// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

protocol ChatMovableDateCellDelegate: class {
    func chatMovableDateCellCopyPressed(cell: ChatMovableDateCell)
    func chatMovableDateCellDeletePressed(cell: ChatMovableDateCell)
    func chatMovableDateCellMorePressed(cell: ChatMovableDateCell)
}

class ChatMovableDateCell: BaseCell {
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
                if UIView.userInterfaceLayoutDirectionForSemanticContentAttribute(self.semanticContentAttribute) == .RightToLeft {
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

            movableContentViewLeftConstraint.updateOffset(offset)
            layoutIfNeeded()
        }
    }

    private var movableContentViewLeftConstraint: Constraint!
    private var dateLabel: UILabel!

    private var isShowingMenu: Bool = false
    private static var setupOnceToken: dispatch_once_t = 0

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let movableModel = model as? ChatMovableDateCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        dispatch_once(&ChatMovableDateCell.setupOnceToken) {
            var items = UIMenuController.sharedMenuController().menuItems ?? [UIMenuItem]()
            items += [
                UIMenuItem(title: String(localized: "chat_more_menu_item"), action: #selector(self.moreAction))
            ]

            UIMenuController.sharedMenuController().menuItems = items
        }

        dateLabel.text = movableModel.dateString
        dateLabel.textColor = theme.colorForType(.ChatListCellMessage)
    }

    override func createViews() {
        super.createViews()

        movableContentView = UIView()
        movableContentView.backgroundColor = .clearColor()
        contentView.addSubview(movableContentView)

        dateLabel = UILabel()
        dateLabel.font = UIFont.antidoteFontWithSize(12.0, weight: .Light)
        movableContentView.addSubview(dateLabel)

        // Using empty view for multiple selection background.
        multipleSelectionBackgroundView = UIView()
    }

    override func installConstraints() {
        super.installConstraints()

        movableContentView.snp_makeConstraints {
            $0.top.equalTo(contentView)
            movableContentViewLeftConstraint = $0.leading.equalTo(contentView).constraint
            $0.size.equalTo(contentView)
        }

        dateLabel.snp_makeConstraints {
            $0.centerY.equalTo(movableContentView)
            $0.leading.equalTo(movableContentView.snp_trailing)
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        if !editing {
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
    func shouldShowMenu() -> Bool {
        return false
    }

    // Override in subclass to enable menu
    func menuTargetRect() -> CGRect {
        return CGRectZero
    }

    func willShowMenu() {
        isShowingMenu = true
    }

    func willHideMenu() {
        isShowingMenu = false
    }
}

// Methods to make UIMenuController work.
extension ChatMovableDateCell {
    func isMenuActionSupportedByCell(action: Selector) -> Bool {
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

    override func copy(sender: AnyObject?) {
        delegate?.chatMovableDateCellCopyPressed(self)
    }

    override func delete(sender: AnyObject?) {
        delegate?.chatMovableDateCellDeletePressed(self)
    }

    func moreAction() {
        delegate?.chatMovableDateCellMorePressed(self)
    }
}
