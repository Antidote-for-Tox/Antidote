//
//  RunningCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 08/08/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

protocol RunningCoordinatorDelegate: class {
    func runningCoordinatorDidLogout(coordinator: RunningCoordinator, importToxProfileFromURL: NSURL?)
    func runningCoordinatorDeleteProfile(coordinator: RunningCoordinator)
    func runningCoordinatorRecreateCoordinatorsStack(coordinator: RunningCoordinator, options: CoordinatorOptions)
}

class RunningCoordinator {
    private enum InfoObject {
        case ToxManager(manager: OCTManager)
        case ProfileName(name: String)
    }

    weak var delegate: RunningCoordinatorDelegate?

    private let theme: Theme
    private let window: UIWindow

    private var infoObject: InfoObject
    private var options: CoordinatorOptions?

    private var activeSessionCoordinator: ActiveSessionCoordinator?

    private init(theme: Theme, window: UIWindow, infoObject: InfoObject) {
        self.theme = theme
        self.window = window
        self.infoObject = infoObject
    }

    convenience init(theme: Theme, window: UIWindow, toxManager: OCTManager) {
        self.init(theme: theme, window: window, infoObject: .ToxManager(manager: toxManager))
    }

    convenience init(theme: Theme, window: UIWindow, profileName: String) {
        self.init(theme: theme, window: window, infoObject: .ProfileName(name: profileName))
    }
}

extension RunningCoordinator: TopCoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
        self.options = options

        switch infoObject {
            case .ToxManager(let manager):
                startSessionWithToxManager(manager)
            case .ProfileName(let name):
                authorizeWithProfileName(name)
        }
    }

    func handleLocalNotification(notification: UILocalNotification) {
        activeSessionCoordinator?.handleLocalNotification(notification)
    }

    func handleInboxURL(url: NSURL) {
        activeSessionCoordinator?.handleInboxURL(url)
    }
}

extension RunningCoordinator: ActiveSessionCoordinatorDelegate {
    func activeSessionCoordinatorDidLogout(coordinator: ActiveSessionCoordinator, importToxProfileFromURL url: NSURL?) {
        let keychainManager = KeychainManager()
        keychainManager.deleteActiveAccountData()

        delegate?.runningCoordinatorDidLogout(self, importToxProfileFromURL: url)
    }

    func activeSessionCoordinatorDeleteProfile(coordinator: ActiveSessionCoordinator) {
        delegate?.runningCoordinatorDeleteProfile(self)
    }

    func activeSessionCoordinatorRecreateCoordinatorsStack(coordinator: ActiveSessionCoordinator, options: CoordinatorOptions) {
        delegate?.runningCoordinatorRecreateCoordinatorsStack(self, options: options)
    }
}

extension RunningCoordinator: AuthorizationControllerDelegate {
    func authorizationController(controller: AuthorizationController, authorizeWithPassword password: String) {
        let profileName: String

        switch infoObject {
            case .ProfileName(let name):
                profileName = name
            default:
                assert(false, "profile name should be set")
                return
        }

        let hud = JGProgressHUD(style: .Dark)
        hud.showInView(controller.view)
        
        createToxManagerWithProfileName(profileName, password: password, successBlock: { [unowned self] manager -> Void in
            hud.dismiss()
            self.startSessionWithToxManager(manager)

        }, failureBlock: { error -> Void in
            hud.dismiss()
            handleErrorWithType(.CreateOCTManager, error: error)
        })
    }

    func authorizationControllerCancel(controller: AuthorizationController) {
        delegate?.runningCoordinatorDidLogout(self, importToxProfileFromURL: nil)
    }
}

private extension RunningCoordinator {
    func startSessionWithToxManager(manager: OCTManager) {
        activeSessionCoordinator = ActiveSessionCoordinator(theme: theme, window: window, toxManager: manager)
        activeSessionCoordinator?.delegate = self
        activeSessionCoordinator?.startWithOptions(options)
    }

    func authorizeWithProfileName(profileName: String) {
        let keychainManager = KeychainManager()

        if let autoLogin = keychainManager.autoLoginForActiveAccount,
           let password = keychainManager.toxPasswordForActiveAccount {

            if autoLogin {
                tryToAutoLoginWithProfileName(profileName, password: password)
                return
            }
        }

        let controller = AuthorizationController(theme: theme, cancelButtonType: .Logout)
        controller.title = profileName
        controller.delegate = self
        window.rootViewController = UINavigationController(rootViewController: controller)
    }

    func tryToAutoLoginWithProfileName(profileName: String, password: String) {
        createToxManagerWithProfileName(profileName, password: password, successBlock: { [unowned self] manager -> Void in
            self.startSessionWithToxManager(manager)

        }, failureBlock: { [unowned self] error -> Void in
            log("Cannot autologin with profileName \(profileName), error \(error)")

            // Something went wrong during autologin, seems that saved data is broken.
            // Removing it and showing user normal login.
            let keychainManager = KeychainManager()
            keychainManager.deleteActiveAccountData()

            self.authorizeWithProfileName(profileName)
        })
    }

    func createToxManagerWithProfileName(profileName: String,
                                         password: String,
                                         successBlock: (OCTManager -> Void),
                                         failureBlock: (NSError -> Void))
    {
        let path = ProfileManager().pathForProfileWithName(profileName)
        let configuration = OCTManagerConfiguration.configurationWithBaseDirectory(path)!
        
        OCTManager.managerWithConfiguration(configuration,
                                            encryptPassword: password,
                                            successBlock: successBlock,
                                            failureBlock: failureBlock)
    }
}
