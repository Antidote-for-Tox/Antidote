//
//  ErrorHandling.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 26/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

enum ErrorHandlerType {
    case CannotLoadHTML
    case CreateOCTManager
}


func handleErrorWithType(type: ErrorHandlerType, error: NSError? = nil) {
    switch type {
        case .CannotLoadHTML:
            UIAlertView.showErrorWithMessage(String(localized: "error_file_not_found"))
        case .CreateOCTManager:
            let (title, message) = OCTManagerInitError(rawValue: error!.code)!.strings()
            UIAlertView.showWithTitle(title, message: message)
    }
}

extension OCTManagerInitError {
    func strings() -> (title: String, message: String) {
        switch self {
            case .PassphraseFailed:
                return (String(localized: "manager_error_wrong_password_title"),
                        String(localized: "manager_error_wrong_password_message"))
            case .CannotImportToxSave:
                return (String(localized: "manager_error_import_not_exist_title"),
                        String(localized: "manager_error_import_not_exist_message"))
            case .DecryptNull:
                return (String(localized: "manager_error_decrypt_title"),
                        String(localized: "manager_error_decrypt_empty_data_message"))
            case .DecryptBadFormat:
                return (String(localized: "manager_error_decrypt_title"),
                        String(localized: "manager_error_decrypt_bad_format_message"))
            case .DecryptFailed:
                return (String(localized: "manager_error_decrypt_title"),
                        String(localized: "manager_error_decrypt_wrong_password_message"))
            case .CreateToxUnknown:
                return (String(localized: "manager_error_general_title"),
                        String(localized: "manager_error_general_unknown_message"))
            case .CreateToxMemoryError:
                return (String(localized: "manager_error_general_title"),
                        String(localized: "manager_error_general_no_memory_message"))
            case .CreateToxPortAlloc:
                return (String(localized: "manager_error_general_title"),
                        String(localized: "manager_error_general_bind_port_message"))
            case .CreateToxProxyBadType:
                return (String(localized: "manager_error_proxy_title"),
                        String(localized: "manager_error_proxy_internal_message"))
            case .CreateToxProxyBadHost:
                return (String(localized: "manager_error_proxy_title"),
                        String(localized: "manager_error_proxy_invalid_address_message"))
            case .CreateToxProxyBadPort:
                return (String(localized: "manager_error_proxy_title"),
                        String(localized: "manager_error_proxy_invalid_port_message"))
            case .CreateToxProxyNotFound:
                return (String(localized: "manager_error_proxy_title"),
                        String(localized: "manager_error_proxy_host_not_resolved_message"))
            case .CreateToxEncrypted:
                return (String(localized: "manager_error_general_title"),
                        String(localized: "manager_error_general_profile_encrypted_message"))
            case .CreateToxBadFormat:
                return (String(localized: "manager_error_general_title"),
                        String(localized: "manager_error_general_bad_format_message"))
        }
    }
}
