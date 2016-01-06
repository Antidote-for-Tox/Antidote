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
    case ToxSetInfoCodeName
    case ToxSetInfoCodeStatusMessage
    case ToxAddFriend
    case CallToChat
}


func handleErrorWithType(type: ErrorHandlerType, error: NSError? = nil) {
    switch type {
        case .CannotLoadHTML:
            UIAlertView.showErrorWithMessage(String(localized: "error_file_not_found"))
        case .CreateOCTManager:
            let (title, message) = OCTManagerInitError(rawValue: error!.code)!.strings()
            UIAlertView.showWithTitle(title, message: message)
        case .ToxSetInfoCodeName:
            let (title, message) = OCTToxErrorSetInfoCode(rawValue: error!.code)!.nameStrings()
            UIAlertView.showWithTitle(title, message: message)
        case .ToxSetInfoCodeStatusMessage:
            let (title, message) = OCTToxErrorSetInfoCode(rawValue: error!.code)!.statusMessageStrings()
            UIAlertView.showWithTitle(title, message: message)
        case .ToxAddFriend:
            let (title, message) = OCTToxErrorFriendAdd(rawValue: error!.code)!.strings()
            UIAlertView.showWithTitle(title, message: message)
        case .CallToChat:
            let (title, message) = OCTToxAVErrorCall(rawValue: error!.code)!.strings()
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
                        String(localized: "error_internal_message"))
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

extension OCTToxErrorSetInfoCode {
    func nameStrings() -> (title: String, message: String) {
        switch self {
            case .Unknow:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
            case .TooLong:
                return (String(localized: "error_title"),
                        String(localized: "tox_error_name_too_long"))
        }
    }

    func statusMessageStrings() -> (title: String, message: String) {
        switch self {
            case .Unknow:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
            case .TooLong:
                return (String(localized: "error_title"),
                        String(localized: "tox_error_status_message_too_long"))
        }
    }
}

extension OCTToxErrorFriendAdd {
    func strings() -> (title: String, message: String) {
        switch self {
            case .TooLong:
                return (String(localized: "error_title"),
                        String(localized: "tox_error_friend_request_too_long"))
            case .NoMessage:
                return (String(localized: "error_title"),
                        String(localized: "tox_error_friend_request_no_message"))
            case .OwnKey:
                return (String(localized: "error_title"),
                        String(localized: "tox_error_friend_request_own_key"))
            case .AlreadySent:
                return (String(localized: "error_title"),
                        String(localized: "tox_error_friend_request_already_sent"))
            case .BadChecksum:
                return (String(localized: "error_title"),
                        String(localized: "tox_error_friend_request_bad_checksum"))
            case .SetNewNospam:
                return (String(localized: "error_title"),
                        String(localized: "tox_error_friend_request_new_nospam"))
            case .Malloc:
                fallthrough
            case .Unknown:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
        }
    }
}

extension OCTToxAVErrorCall {
    func strings() -> (title: String, message: String) {
        switch self {
            case .AlreadyInCall:
                return (String(localized: "error_title"),
                        String(localized: "call_error_already_in_call"))
            case .FriendNotConnected:
                return (String(localized: "error_title"),
                        String(localized: "call_error_friend_is_offline"))
            case .FriendNotFound:
                fallthrough
            case .InvalidBitRate:
                fallthrough
            case .Malloc:
                fallthrough
            case .Sync:
                fallthrough
            case .Unknown:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
        }
    }
}
