//
//  LoginLogoController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 10/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct PrivateConstants {
    static let LogoTopOffset = -200.0
    static let LogoHeight = 100.0
}

class LoginLogoController: LoginBaseController {
    /**
     * Main view, which is used as container for all subviews.
     */
    var mainContainerView: UIView!
    var mainContainerViewTopConstraint: Constraint!

    var logoImageView: UIImageView!

    /**
     * Use this container to add subviews in subclasses.
     * Is placed under logo.
     */
    var contentContainerView: UIView!

    override func loadView() {
        super.loadView()

        createMainContainerView()
        createLogoImageView()
        createContainerView()

        installConstraints()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated:animated)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated:animated)
    }
}

private extension LoginLogoController {
    func createMainContainerView() {
        mainContainerView = UIView()
        mainContainerView.backgroundColor = .clearColor()
        view.addSubview(mainContainerView)
    }

    func createLogoImageView() {
        let image = UIImage.templateNamed("login-logo")

        logoImageView = UIImageView(image: image)
        logoImageView.tintColor = theme.colorForType(.LoginToxLogo)
        logoImageView.contentMode = .ScaleAspectFit
        mainContainerView.addSubview(logoImageView)
    }

    func createContainerView() {
        contentContainerView = UIView()
        contentContainerView.backgroundColor = .clearColor()
        mainContainerView.addSubview(contentContainerView)
    }

    func installConstraints() {
        mainContainerView.snp_makeConstraints {
            mainContainerViewTopConstraint = $0.top.equalTo(view).constraint
            $0.leading.trailing.equalTo(view)
            $0.height.equalTo(view)
        }

        logoImageView.snp_makeConstraints {
            $0.centerX.equalTo(mainContainerView)
            $0.top.equalTo(mainContainerView.snp_centerY).offset(PrivateConstants.LogoTopOffset)
            $0.height.equalTo(PrivateConstants.LogoHeight)
        }

        contentContainerView.snp_makeConstraints {
            $0.top.equalTo(logoImageView.snp_bottom).offset(Constants.VerticalOffset)
            $0.bottom.equalTo(mainContainerView)
            $0.leading.trailing.equalTo(mainContainerView)
        }
    }
}
