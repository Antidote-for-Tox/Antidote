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
        let image = UIImage(named: "login-logo")!.imageWithRenderingMode(.AlwaysTemplate)

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
        mainContainerView.snp_makeConstraints { (make) -> Void in
            mainContainerViewTopConstraint = make.top.equalTo(view).constraint
            make.left.right.equalTo(view)
            make.height.equalTo(view)
        }

        logoImageView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(mainContainerView)
            make.top.equalTo(mainContainerView.snp_centerY).offset(PrivateConstants.LogoTopOffset)
            make.height.equalTo(PrivateConstants.LogoHeight)
        }

        contentContainerView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(logoImageView.snp_bottom).offset(Constants.VerticalOffset)
            make.bottom.equalTo(mainContainerView)
            make.left.right.equalTo(mainContainerView)
        }
    }
}
