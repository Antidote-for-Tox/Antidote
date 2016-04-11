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
    case RemoveFriend
    case CallToChat
    case ExportProfile
    case DeleteProfile
    case PasswordIsEmpty
    case WrongOldPassword
    case PasswordsDoNotMatch
    case AnswerCall
    case RouteAudioToSpeaker
    case EnableVideoSending
    case CallSwitchCamera
    case ConvertImageToPNG
    case ChangeAvatar
    case SendFileToFriend
    case AcceptIncomingFile
    case CancelFileTransfer
    case PauseFileTransfer
}


/**
    Show alert for given error.

    - Parameters:
      - type: Type of error to handle.
      - error: Optional erro to get code from.
      - retryBlock: If set user will be asked to retry request once again.
 */
func handleErrorWithType(type: ErrorHandlerType, error: NSError? = nil, retryBlock: (Void -> Void)? = nil) {
    switch type {
        case .CannotLoadHTML:
            UIAlertController.showErrorWithMessage(String(localized: "error_internal_message"), retryBlock: retryBlock)
        case .CreateOCTManager:
            let (title, message) = OCTManagerInitError(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .ToxSetInfoCodeName:
            let (title, message) = OCTToxErrorSetInfoCode(rawValue: error!.code)!.nameStrings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .ToxSetInfoCodeStatusMessage:
            let (title, message) = OCTToxErrorSetInfoCode(rawValue: error!.code)!.statusMessageStrings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .ToxAddFriend:
            let (title, message) = OCTToxErrorFriendAdd(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .RemoveFriend:
            let (title, message) = OCTToxErrorFriendDelete(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .CallToChat:
            let (title, message) = OCTToxAVErrorCall(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .ExportProfile:
            UIAlertController.showWithTitle(String(localized: "error_title"), message: error!.localizedDescription, retryBlock: retryBlock)
        case .DeleteProfile:
            UIAlertController.showWithTitle(String(localized: "error_title"), message: error!.localizedDescription, retryBlock: retryBlock)
        case .PasswordIsEmpty:
            UIAlertController.showWithTitle(String(localized: "password_is_empty_error"), retryBlock: retryBlock)
        case .WrongOldPassword:
            UIAlertController.showWithTitle(String(localized: "wrong_old_password"), retryBlock: retryBlock)
        case .PasswordsDoNotMatch:
            UIAlertController.showWithTitle(String(localized: "passwords_do_not_match"), retryBlock: retryBlock)
        case .AnswerCall:
            let (title, message) = OCTToxAVErrorAnswer(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .RouteAudioToSpeaker:
            UIAlertController.showWithTitle(String(localized: "error_title"), message: String(localized: "error_internal_message"), retryBlock: retryBlock)
        case .EnableVideoSending:
            UIAlertController.showWithTitle(String(localized: "error_title"), message: String(localized: "error_internal_message"), retryBlock: retryBlock)
        case .CallSwitchCamera:
            UIAlertController.showWithTitle(String(localized: "error_title"), message: String(localized: "error_internal_message"), retryBlock: retryBlock)
        case .ConvertImageToPNG:
            UIAlertController.showWithTitle(String(localized: "error_title"), message: String(localized: "change_avatar_error_convert_image"), retryBlock: retryBlock)
        case .ChangeAvatar:
            let (title, message) = OCTSetUserAvatarError(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .SendFileToFriend:
            let (title, message) = OCTSendFileError(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .AcceptIncomingFile:
            let (title, message) = OCTAcceptFileError(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .CancelFileTransfer:
            let (title, message) = OCTFileTransferError(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .PauseFileTransfer:
            let (title, message) = OCTFileTransferError(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
    }
}

extension OCTManagerInitError {
    func strings() -> (title: String, message: String) {
        switch self {
            case .PassphraseFailed:
                return (String(localized: "error_wrong_password_title"),
                        String(localized: "error_wrong_password_message"))
            case .CannotImportToxSave:
                return (String(localized: "error_import_not_exist_title"),
                        String(localized: "error_import_not_exist_message"))
            case .DecryptNull:
                return (String(localized: "error_decrypt_title"),
                        String(localized: "error_decrypt_empty_data_message"))
            case .DecryptBadFormat:
                return (String(localized: "error_decrypt_title"),
                        String(localized: "error_decrypt_bad_format_message"))
            case .DecryptFailed:
                return (String(localized: "error_decrypt_title"),
                        String(localized: "error_decrypt_wrong_password_message"))
            case .CreateToxUnknown:
                return (String(localized: "error_title"),
                        String(localized: "error_general_unknown_message"))
            case .CreateToxMemoryError:
                return (String(localized: "error_title"),
                        String(localized: "error_general_no_memory_message"))
            case .CreateToxPortAlloc:
                return (String(localized: "error_title"),
                        String(localized: "error_general_bind_port_message"))
            case .CreateToxProxyBadType:
                return (String(localized: "error_proxy_title"),
                        String(localized: "error_internal_message"))
            case .CreateToxProxyBadHost:
                return (String(localized: "error_proxy_title"),
                        String(localized: "error_proxy_invalid_address_message"))
            case .CreateToxProxyBadPort:
                return (String(localized: "error_proxy_title"),
                        String(localized: "error_proxy_invalid_port_message"))
            case .CreateToxProxyNotFound:
                return (String(localized: "error_proxy_title"),
                        String(localized: "error_proxy_host_not_resolved_message"))
            case .CreateToxEncrypted:
                return (String(localized: "error_title"),
                        String(localized: "error_general_profile_encrypted_message"))
            case .CreateToxBadFormat:
                return (String(localized: "error_title"),
                        String(localized: "error_general_bad_format_message"))
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
                        String(localized: "error_name_too_long"))
        }
    }

    func statusMessageStrings() -> (title: String, message: String) {
        switch self {
            case .Unknow:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
            case .TooLong:
                return (String(localized: "error_title"),
                        String(localized: "error_status_message_too_long"))
        }
    }
}

extension OCTToxErrorFriendAdd {
    func strings() -> (title: String, message: String) {
        switch self {
            case .TooLong:
                return (String(localized: "error_title"),
                        String(localized: "error_contact_request_too_long"))
            case .NoMessage:
                return (String(localized: "error_title"),
                        String(localized: "error_contact_request_no_message"))
            case .OwnKey:
                return (String(localized: "error_title"),
                        String(localized: "error_contact_request_own_key"))
            case .AlreadySent:
                return (String(localized: "error_title"),
                        String(localized: "error_contact_request_already_sent"))
            case .BadChecksum:
                return (String(localized: "error_title"),
                        String(localized: "error_contact_request_bad_checksum"))
            case .SetNewNospam:
                return (String(localized: "error_title"),
                        String(localized: "error_contact_request_new_nospam"))
            case .Malloc:
                fallthrough
            case .Unknown:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
        }
    }
}

extension OCTToxErrorFriendDelete {
    func strings() -> (title: String, message: String) {
        switch self {
            case .NotFound:
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
                        String(localized: "call_error_contact_is_offline"))
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

extension OCTToxAVErrorAnswer {
    func strings() -> (title: String, message: String) {
        switch self {
            case .FriendNotCalling:
                return (String(localized: "error_title"),
                        String(localized: "call_error_no_active_call"))
            case .CodecInitialization:
                fallthrough
            case .Sync:
                fallthrough
            case .InvalidBitRate:
                fallthrough
            case .Unknown:
                fallthrough
            case .FriendNotFound:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
        }
    }
}

extension OCTSetUserAvatarError {
    func strings() -> (title: String, message: String) {
        switch self {
            case .TooBig:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
        }
    }
}

extension OCTSendFileError {
    func strings() -> (title: String, message: String) {
        switch self {
            case .InternalError:
                fallthrough
            case .CannotReadFile:
                fallthrough
            case .CannotSaveFileToUploads:
                fallthrough
            case .NameTooLong:
                fallthrough
            case .FriendNotFound:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
            case .FriendNotConnected:
                return (String(localized: "error_title"),
                        String(localized: "error_contact_not_connected"))
            case .TooMany:
                return (String(localized: "error_title"),
                        String(localized: "error_too_many_files"))
        }
    }
}

extension OCTAcceptFileError {
    func strings() -> (title: String, message: String) {
        switch self {
            case .InternalError:
                fallthrough
            case .CannotWriteToFile:
                fallthrough
            case .FriendNotFound:
                fallthrough
            case .WrongMessage:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
            case .FriendNotConnected:
                return (String(localized: "error_title"),
                        String(localized: "error_contact_not_connected"))
        }
    }
}

extension OCTFileTransferError {
    func strings() -> (title: String, message: String) {
        switch self {
            case .WrongMessage:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
        }
    }
}
