//
//  StaticTableController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 21/11/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

class StaticTableController: UIViewController {
    private let theme: Theme
    private let modelArray: [[StaticTableBaseCellModel]]
    private var tableView: UITableView?

    init(theme: Theme, model: [[StaticTableBaseCellModel]]) {
        self.theme = theme
        self.modelArray = model

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
}

extension StaticTableController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = modelArray[indexPath.section][indexPath.row]
        let cell: StaticTableBaseCell

        switch model {
            case _ as StaticTableButtonCellModel:
                cell = tableView.dequeueReusableCellWithIdentifier(StaticTableButtonCell.staticReuseIdentifier) as! StaticTableBaseCell
            case _ as StaticTableAvatarCellModel:
                cell = tableView.dequeueReusableCellWithIdentifier(StaticTableAvatarCell.staticReuseIdentifier) as! StaticTableBaseCell
            case _ as StaticTableDefaultCellModel:
                cell = tableView.dequeueReusableCellWithIdentifier(StaticTableDefaultCell.staticReuseIdentifier) as! StaticTableBaseCell
            case _ as StaticTableChatButtonsCellModel:
                cell = tableView.dequeueReusableCellWithIdentifier(StaticTableChatButtonsCell.staticReuseIdentifier) as! StaticTableBaseCell
            default:
                fatalError("Static model class \(model) has not been implemented")
        }

        cell.setupWithTheme(theme, model: model)

        let isLastRow = (indexPath.row == (modelArray[indexPath.section].count - 1))
        let isLastSection = (indexPath.section == (modelArray.count - 1))

        cell.setBottomSeparatorHidden(!isLastRow || isLastSection)

        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return modelArray.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelArray[section].count
    }
}

extension StaticTableController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let model = modelArray[indexPath.section][indexPath.row]

        switch model {
            case let model as StaticTableSelectableCellModel:
                model.didSelectHandler?()
            default:
                // nop
                break;
        }
    }
}

private extension StaticTableController {
    func createTableView() {
        tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView!.dataSource = self
        tableView!.delegate = self
        tableView!.backgroundColor = theme.colorForType(.NormalBackground)
        tableView!.estimatedRowHeight = 44.0;
        tableView!.separatorStyle = .None;

        view.addSubview(tableView!)

        tableView!.registerClass(StaticTableButtonCell.self, forCellReuseIdentifier: StaticTableButtonCell.staticReuseIdentifier)
        tableView!.registerClass(StaticTableAvatarCell.self, forCellReuseIdentifier: StaticTableAvatarCell.staticReuseIdentifier)
        tableView!.registerClass(StaticTableDefaultCell.self, forCellReuseIdentifier: StaticTableDefaultCell.staticReuseIdentifier)
        tableView!.registerClass(StaticTableChatButtonsCell.self, forCellReuseIdentifier: StaticTableChatButtonsCell.staticReuseIdentifier)
    }

    func installConstraints() {
        tableView!.snp_makeConstraints {
            $0.edges.equalTo(view)
        }
    }
}
