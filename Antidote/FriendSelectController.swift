// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

protocol FriendSelectControllerDelegate: class {
    func friendSelectController(_ controller: FriendSelectController, didSelectFriend friend: OCTFriend)
    func friendSelectControllerCancel(_ controller: FriendSelectController)
}

class FriendSelectController: UIViewController {
    weak var delegate: FriendSelectControllerDelegate?

    var userInfo: AnyObject?

    fileprivate let theme: Theme

    fileprivate let dataSource: FriendListDataSource

    fileprivate var placeholderView: UITextView!
    fileprivate var tableView: UITableView!

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects, userInfo: AnyObject? = nil) {
        self.theme = theme
        self.userInfo = userInfo

        let friends = submanagerObjects.friends()
        self.dataSource = FriendListDataSource(theme: theme, friends: friends)

        super.init(nibName: nil, bundle: nil)

        dataSource.delegate = self

        addNavigationButtons()

        edgesForExtendedLayout = UIRectEdge()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        createTableView()
        createPlaceholderView()
        installConstraints()

        updateViewsVisibility()
    }
}

extension FriendSelectController {
    func cancelButtonPressed() {
        delegate?.friendSelectControllerCancel(self)
    }
}

extension FriendSelectController: FriendListDataSourceDelegate {
    func friendListDataSourceBeginUpdates() {
        tableView.beginUpdates()
    }

    func friendListDataSourceEndUpdates() {
        self.tableView.endUpdates()
        updateViewsVisibility()
    }

    func friendListDataSourceInsertRowsAtIndexPaths(_ indexPaths: [IndexPath]) {
        tableView.insertRows(at: indexPaths, with: .automatic)
    }

    func friendListDataSourceDeleteRowsAtIndexPaths(_ indexPaths: [IndexPath]) {
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }

    func friendListDataSourceReloadRowsAtIndexPaths(_ indexPaths: [IndexPath]) {
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }

    func friendListDataSourceInsertSections(_ sections: IndexSet) {
        tableView.insertSections(sections, with: .automatic)
    }

    func friendListDataSourceDeleteSections(_ sections: IndexSet) {
        tableView.deleteSections(sections, with: .automatic)
    }

    func friendListDataSourceReloadSections(_ sections: IndexSet) {
        tableView.reloadSections(sections, with: .automatic)
    }

    func friendListDataSourceReloadTable() {
        tableView.reloadData()
    }
}

extension FriendSelectController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendListCell.staticReuseIdentifier) as! FriendListCell
        let model = dataSource.modelAtIndexPath(indexPath)

        cell.setupWithTheme(theme, model: model)

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfRowsInSection(section)
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return dataSource.sectionIndexTitles()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.titleForHeaderInSection(section)
    }
}

extension FriendSelectController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch dataSource.objectAtIndexPath(indexPath) {
            case .request:
                // nop
                break
            case .friend(let friend):
                delegate?.friendSelectController(self, didSelectFriend: friend)
        }
    }
}

private extension FriendSelectController {
    func addNavigationButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(FriendSelectController.cancelButtonPressed))
    }

    func updateViewsVisibility() {
        var isEmpty = true

        for section in 0..<dataSource.numberOfSections() {
            if dataSource.numberOfRowsInSection(section) > 0 {
                isEmpty = false
                break
            }
        }

        placeholderView.isHidden = !isEmpty
    }

    func createTableView() {
        tableView = UITableView()
        tableView.estimatedRowHeight = 44.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = theme.colorForType(.NormalBackground)
        tableView.sectionIndexColor = theme.colorForType(.LinkText)
        // removing separators on empty lines
        tableView.tableFooterView = UIView()

        view.addSubview(tableView)

        tableView.register(FriendListCell.self, forCellReuseIdentifier: FriendListCell.staticReuseIdentifier)
    }

    func createPlaceholderView() {
        placeholderView = UITextView()
        placeholderView.text = String(localized: "contact_no_contacts")
        placeholderView.isEditable = false
        placeholderView.isScrollEnabled = false
        placeholderView.textAlignment = .center
        view.addSubview(placeholderView)
    }

    func installConstraints() {
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }

        placeholderView.snp.makeConstraints {
            $0.center.equalTo(view)
            $0.size.equalTo(placeholderView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)))
        }
    }
}
