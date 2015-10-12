//
//  LoginLogoController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 10/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

class LoginLogoController: LoginBaseController {
    var logoImageView: UIImageView!
    var containerView: UIView!

    override func loadView() {
        super.loadView()

        createLogoImageView()
        createContainerView()

        installConstraints()
    }
}

private extension LoginLogoController {
    func createLogoImageView() {
        let image = UIImage(named: "login-logo")!.imageWithRenderingMode(.AlwaysTemplate)

        logoImageView = UIImageView(image: image)
        logoImageView.tintColor = theme.colorForType(.LoginToxLogo)
        logoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        view.addSubview(logoImageView)
    }

    func createContainerView() {
        containerView = UIView()
        containerView.backgroundColor = UIColor.clearColor()
        view.addSubview(containerView)
    }

    func installConstraints() {
        // logoImageView
    }
}
