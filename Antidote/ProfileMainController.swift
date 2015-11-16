//
//  ProfileMainController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02/11/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

protocol ProfileMainControllerDelegate: class {
    func profileMainControllerLogout(controller: ProfileMainController)
}

class ProfileMainController: UIViewController {
    weak var delegate: ProfileMainControllerDelegate?

    let theme: Theme

    init(theme: Theme) {
        self.theme = theme

        super.init(nibName: nil, bundle: nil)

        edgesForExtendedLayout = .None
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        loadViewWithBackgroundColor(theme.colorForType(.NormalBackground))

        let button = UIButton()
        button.setTitle("logout", forState: .Normal)
        button.setTitleColor(.blackColor(), forState: .Normal)
        button.addTarget(self, action: "buttonPressed", forControlEvents: .TouchUpInside)
        button.frame = CGRect(x: 30, y: 150, width: 200, height: 50)
        view.addSubview(button)
    }

    func buttonPressed() {
        delegate?.profileMainControllerLogout(self)
    }
}
