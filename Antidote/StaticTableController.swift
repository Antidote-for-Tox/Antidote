// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

class StaticTableController: UIViewController {
    fileprivate let theme: Theme
    fileprivate let tableViewStyle: UITableViewStyle
    fileprivate var modelArray: [[StaticTableBaseCellModel]]
    fileprivate let footerArray: [String?]?

    fileprivate var tableView: UITableView?

    init(theme: Theme, style: UITableViewStyle, model: [[StaticTableBaseCellModel]], footers: [String?]? = nil) {
        self.theme = theme
        self.tableViewStyle = style
        self.modelArray = model
        self.footerArray = footers

        super.init(nibName: nil, bundle: nil)

        edgesForExtendedLayout = UIRectEdge()
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

    func updateModelArray(_ model: [[StaticTableBaseCellModel]]) {
        modelArray = model
        reloadTableView()
    }
}

extension StaticTableController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            case .plain:
                cell.setBottomSeparatorHidden(!isLastRow || isLastSection)
            case .grouped:
                cell.setBottomSeparatorHidden(isLastRow)

        }

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return modelArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArray[section].count
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let cell = tableView.cellForRow(at: indexPath) as? StaticTableBaseCell else {
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
        tableView = UITableView(frame: CGRect.zero, style: tableViewStyle)
        tableView!.dataSource = self
        tableView!.delegate = self
        tableView!.estimatedRowHeight = 44.0;
        tableView!.separatorStyle = .none;

        switch tableViewStyle {
            case .plain:
                tableView!.backgroundColor = theme.colorForType(.NormalBackground)
            case .grouped:
                tableView!.backgroundColor = theme.colorForType(.SettingsBackground)
        }

        view.addSubview(tableView!)

        tableView!.register(StaticTableButtonCell.self, forCellReuseIdentifier: StaticTableButtonCell.staticReuseIdentifier)
        tableView!.register(StaticTableAvatarCell.self, forCellReuseIdentifier: StaticTableAvatarCell.staticReuseIdentifier)
        tableView!.register(StaticTableDefaultCell.self, forCellReuseIdentifier: StaticTableDefaultCell.staticReuseIdentifier)
        tableView!.register(StaticTableChatButtonsCell.self, forCellReuseIdentifier: StaticTableChatButtonsCell.staticReuseIdentifier)
        tableView!.register(StaticTableSwitchCell.self, forCellReuseIdentifier: StaticTableSwitchCell.staticReuseIdentifier)
        tableView!.register(StaticTableInfoCell.self, forCellReuseIdentifier: StaticTableInfoCell.staticReuseIdentifier)
        tableView!.register(StaticTableMultiChoiceButtonCell.self, forCellReuseIdentifier: StaticTableMultiChoiceButtonCell.staticReuseIdentifier)
    }

    func installConstraints() {
        tableView!.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
    }

    func dequeueCellForClass(_ identifier: String) -> StaticTableBaseCell {
        return tableView!.dequeueReusableCell(withIdentifier: identifier) as! StaticTableBaseCell
    }
}
