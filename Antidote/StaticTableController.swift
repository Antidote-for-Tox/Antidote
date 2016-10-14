// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

class StaticTableController: UIViewController {
    private let theme: Theme
    private let tableViewStyle: UITableViewStyle
    private var modelArray: [[StaticTableBaseCellModel]]
    private let footerArray: [String?]?

    private var tableView: UITableView?

    init(theme: Theme, style: UITableViewStyle, model: [[StaticTableBaseCellModel]], footers: [String?]? = nil) {
        self.theme = theme
        self.tableViewStyle = style
        self.modelArray = model
        self.footerArray = footers

        super.init(nibName: nil, bundle: nil)

        edgesForExtendedLayout = .None
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        createTableView()

        installConstraints()
    }

    func reloadTableView() {
        tableView?.reloadData()
    }

    func updateModelArray(model: [[StaticTableBaseCellModel]]) {
        modelArray = model
        reloadTableView()
    }
}

extension StaticTableController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = modelArray[indexPath.section][indexPath.row]
        let cell: StaticTableBaseCell

        switch model {
            case _ as StaticTableButtonCellModel:
                cell = dequeueCellForClass(StaticTableButtonCell.staticReuseIdentifier)
            case _ as StaticTableAvatarCellModel:
                cell = dequeueCellForClass(StaticTableAvatarCell.staticReuseIdentifier)
            case _ as StaticTableDefaultCellModel:
                cell = dequeueCellForClass(StaticTableDefaultCell.staticReuseIdentifier)
            case _ as StaticTableChatButtonsCellModel:
                cell = dequeueCellForClass(StaticTableChatButtonsCell.staticReuseIdentifier)
            case _ as StaticTableSwitchCellModel:
                cell = dequeueCellForClass(StaticTableSwitchCell.staticReuseIdentifier)
            case _ as StaticTableInfoCellModel:
                cell = dequeueCellForClass(StaticTableInfoCell.staticReuseIdentifier)
            case _ as StaticTableMultiChoiceButtonCellModel:
                cell = dequeueCellForClass(StaticTableMultiChoiceButtonCell.staticReuseIdentifier)
            default:
                fatalError("Static model class \(model) has not been implemented")
        }

        cell.setupWithTheme(theme, model: model)

        let isLastRow = (indexPath.row == (modelArray[indexPath.section].count - 1))
        let isLastSection = (indexPath.section == (modelArray.count - 1))

        switch tableViewStyle {
            case .Plain:
                cell.setBottomSeparatorHidden(!isLastRow || isLastSection)
            case .Grouped:
                cell.setBottomSeparatorHidden(isLastRow)

        }

        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return modelArray.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArray[section].count
    }

    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let array = footerArray else {
            return nil
        }

        guard section < array.count else {
            return nil
        }

        return array[section]
    }
}

extension StaticTableController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? StaticTableBaseCell else {
            return
        }

        let model = modelArray[indexPath.section][indexPath.row]

        switch model {
            case let model as StaticTableSelectableCellModel:
                model.didSelectHandler?(cell)
            default:
                // nop
                break;
        }
    }
}

private extension StaticTableController {
    func createTableView() {
        tableView = UITableView(frame: CGRectZero, style: tableViewStyle)
        tableView!.dataSource = self
        tableView!.delegate = self
        tableView!.estimatedRowHeight = 44.0;
        tableView!.separatorStyle = .None;

        switch tableViewStyle {
            case .Plain:
                tableView!.backgroundColor = theme.colorForType(.NormalBackground)
            case .Grouped:
                tableView!.backgroundColor = theme.colorForType(.SettingsBackground)
        }

        view.addSubview(tableView!)

        tableView!.registerClass(StaticTableButtonCell.self, forCellReuseIdentifier: StaticTableButtonCell.staticReuseIdentifier)
        tableView!.registerClass(StaticTableAvatarCell.self, forCellReuseIdentifier: StaticTableAvatarCell.staticReuseIdentifier)
        tableView!.registerClass(StaticTableDefaultCell.self, forCellReuseIdentifier: StaticTableDefaultCell.staticReuseIdentifier)
        tableView!.registerClass(StaticTableChatButtonsCell.self, forCellReuseIdentifier: StaticTableChatButtonsCell.staticReuseIdentifier)
        tableView!.registerClass(StaticTableSwitchCell.self, forCellReuseIdentifier: StaticTableSwitchCell.staticReuseIdentifier)
        tableView!.registerClass(StaticTableInfoCell.self, forCellReuseIdentifier: StaticTableInfoCell.staticReuseIdentifier)
        tableView!.registerClass(StaticTableMultiChoiceButtonCell.self, forCellReuseIdentifier: StaticTableMultiChoiceButtonCell.staticReuseIdentifier)
    }

    func installConstraints() {
        tableView!.snp_makeConstraints {
            $0.edges.equalTo(view)
        }
    }

    func dequeueCellForClass(identifier: String) -> StaticTableBaseCell {
        return tableView!.dequeueReusableCellWithIdentifier(identifier) as! StaticTableBaseCell
    }
}
