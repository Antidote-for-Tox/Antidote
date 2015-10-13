//
//  LoginLogoController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 10/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let LogoTopOffset = -200.0
    static let LogoBottomOffset = 40.0
    static let LogoHeight = 100.0
}

class LoginLogoController: LoginBaseController {
    var logoImageView: UIImageView!

    /**
     * Use this container to add subviews in subclasses.
     */
    var containerView: UIView!

    override func loadView() {
        super.loadView()

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
    func createLogoImageView() {
        let image = UIImage(named: "login-logo")!.imageWithRenderingMode(.AlwaysTemplate)

        logoImageView = UIImageView(image: image)
        logoImageView.tintColor = theme.colorForType(.LoginToxLogo)
        logoImageView.contentMode = .ScaleAspectFit
        view.addSubview(logoImageView)
    }

    func createContainerView() {
        containerView = UIView()
        containerView.backgroundColor = .clearColor()
        view.addSubview(containerView)
    }

    func installConstraints() {
        logoImageView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(view)
            make.top.equalTo(view.snp_centerY).offset(Constants.LogoTopOffset)
            make.height.equalTo(Constants.LogoHeight)
        }

        containerView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(logoImageView.snp_bottom).offset(Constants.LogoBottomOffset)
            make.left.right.equalTo(view)
        }
    }
}
