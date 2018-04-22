// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

enum ErrorHandlerType {
    case cannotLoadHTML
    case createOCTManager
    case toxSetInfoCodeName
    case toxSetInfoCodeStatusMessage
    case toxAddFriend
    case removeFriend
    case callToChat
    case exportProfile
    case deleteProfile
    case passwordIsEmpty
    case wrongOldPassword
    case passwordsDoNotMatch
    case answerCall
    case routeAudioToSpeaker
    case enableVideoSending
    case callSwitchCamera
    case convertImageToPNG
    case changeAvatar
    case sendFileToFriend
    case acceptIncomingFile
    case cancelFileTransfer
    case pauseFileTransfer
    case pinLogOut
}


/**
    Show alert for given error.

    - Parameters:
      - type: Type of error to handle.
      - error: Optional erro to get code from.
      - retryBlock: If set user will be asked to retry request once again.
 */
func handleErrorWithType(_ type: ErrorHandlerType, error: NSError? = nil, retryBlock: (() -> Void)? = nil) {
    switch type {
        case .cannotLoadHTML:
            UIAlertController.showErrorWithMessage(String(localized: "error_internal_message"), retryBlock: retryBlock)
        case .createOCTManager:
            let (title, message) = OCTManagerInitError(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .toxSetInfoCodeName:
            let (title, message) = OCTToxErrorSetInfoCode(rawValue: error!.code)!.nameStrings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .toxSetInfoCodeStatusMessage:
            let (title, message) = OCTToxErrorSetInfoCode(rawValue: error!.code)!.statusMessageStrings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .toxAddFriend:
            let (title, message) = OCTToxErrorFriendAdd(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .removeFriend:
            let (title, message) = OCTToxErrorFriendDelete(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .callToChat:
            let (title, message) = OCTToxAVErrorCall(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .exportProfile:
            UIAlertController.showWithTitle(String(localized: "error_title"), message: error!.localizedDescription, retryBlock: retryBlock)
        case .deleteProfile:
            UIAlertController.showWithTitle(String(localized: "error_title"), message: error!.localizedDescription, retryBlock: retryBlock)
        case .passwordIsEmpty:
            UIAlertController.showWithTitle(String(localized: "password_is_empty_error"), retryBlock: retryBlock)
        case .wrongOldPassword:
            UIAlertController.showWithTitle(String(localized: "wrong_old_password"), retryBlock: retryBlock)
        case .passwordsDoNotMatch:
            UIAlertController.showWithTitle(String(localized: "passwords_do_not_match"), retryBlock: retryBlock)
        case .answerCall:
            let (title, message) = OCTToxAVErrorAnswer(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .routeAudioToSpeaker:
            UIAlertController.showWithTitle(String(localized: "error_title"), message: String(localized: "error_internal_message"), retryBlock: retryBlock)
        case .enableVideoSending:
            UIAlertController.showWithTitle(String(localized: "error_title"), message: String(localized: "error_internal_message"), retryBlock: retryBlock)
        case .callSwitchCamera:
            UIAlertController.showWithTitle(String(localized: "error_title"), message: String(localized: "error_internal_message"), retryBlock: retryBlock)
        case .convertImageToPNG:
            UIAlertController.showWithTitle(String(localized: "error_title"), message: String(localized: "change_avatar_error_convert_image"), retryBlock: retryBlock)
        case .changeAvatar:
            let (title, message) = OCTSetUserAvatarError(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .sendFileToFriend:
            let (title, message) = OCTSendFileError(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .acceptIncomingFile:
            let (title, message) = OCTAcceptFileError(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .cancelFileTransfer:
            let (title, message) = OCTFileTransferError(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .pauseFileTransfer:
            let (title, message) = OCTFileTransferError(rawValue: error!.code)!.strings()
            UIAlertController.showWithTitle(title, message: message, retryBlock: retryBlock)
        case .pinLogOut:
            UIAlertController.showWithTitle(String(localized: "error_title"), message: String(localized: "pin_logout_message"), retryBlock: retryBlock)
    }
}

extension OCTManagerInitError {
    func strings() -> (title: String, message: String) {
        switch self {
            case .passphraseFailed:
                return (String(localized: "error_wrong_password_title"),
                        String(localized: "error_wrong_password_message"))
            case .cannotImportToxSave:
                return (String(localized: "error_import_not_exist_title"),
                        String(localized: "error_import_not_exist_message"))
            case .databaseKeyCannotCreateKey:
                fallthrough
            case .databaseKeyCannotReadKey:
                fallthrough
            case .databaseKeyMigrationToEncryptedFailed:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
            case .toxFileDecryptNull:
                fallthrough
            case .databaseKeyDecryptNull:
                return (String(localized: "error_decrypt_title"),
                        String(localized: "error_decrypt_empty_data_message"))
            case .toxFileDecryptBadFormat:
                fallthrough
            case .databaseKeyDecryptBadFormat:
                return (String(localized: "error_decrypt_title"),
                        String(localized: "error_decrypt_bad_format_message"))
            case .toxFileDecryptFailed:
                fallthrough
            case .databaseKeyDecryptFailed:
                return (String(localized: "error_decrypt_title"),
                        String(localized: "error_decrypt_wrong_password_message"))
            case .createToxUnknown:
                return (String(localized: "error_title"),
                        String(localized: "error_general_unknown_message"))
            case .createToxMemoryError:
                return (String(localized: "error_title"),
                        String(localized: "error_general_no_memory_message"))
            case .createToxPortAlloc:
                return (String(localized: "error_title"),
                        String(localized: "error_general_bind_port_message"))
            case .createToxProxyBadType:
                return (String(localized: "error_proxy_title"),
                        String(localized: "error_internal_message"))
            case .createToxProxyBadHost:
                return (String(localized: "error_proxy_title"),
                        String(localized: "error_proxy_invalid_address_message"))
            case .createToxProxyBadPort:
                return (String(localized: "error_proxy_title"),
                        String(localized: "error_proxy_invalid_port_message"))
            case .createToxProxyNotFound:
                return (String(localized: "error_proxy_title"),
                        String(localized: "error_proxy_host_not_resolved_message"))
            case .createToxEncrypted:
                return (String(localized: "error_title"),
                        String(localized: "error_general_profile_encrypted_message"))
            case .createToxBadFormat:
                return (String(localized: "error_title"),
                        String(localized: "error_general_bad_format_message"))
        }
    }
}

extension OCTToxErrorSetInfoCode {
    func nameStrings() -> (title: String, message: String) {
        switch self {
            case .unknow:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
            case .tooLong:
                return (String(localized: "error_title"),
                        String(localized: "error_name_too_long"))
        }
    }

    func statusMessageStrings() -> (title: String, message: String) {
        switch self {
            case .unknow:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
            case .tooLong:
                return (String(localized: "error_title"),
                        String(localized: "error_status_message_too_long"))
        }
    }
}

extension OCTToxErrorFriendAdd {
    func strings() -> (title: String, message: String) {
        switch self {
            case .tooLong:
                return (String(localized: "error_title"),
                        String(localized: "error_contact_request_too_long"))
            case .noMessage:
                return (String(localized: "error_title"),
                        String(localized: "error_contact_request_no_message"))
            case .ownKey:
                return (String(localized: "error_title"),
                        String(localized: "error_contact_request_own_key"))
            case .alreadySent:
                return (String(localized: "error_title"),
                        String(localized: "error_contact_request_already_sent"))
            case .badChecksum:
                return (String(localized: "error_title"),
                        String(localized: "error_contact_request_bad_checksum"))
            case .setNewNospam:
                return (String(localized: "error_title"),
                        String(localized: "error_contact_request_new_nospam"))
            case .malloc:
                fallthrough
            case .unknown:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
        }
    }
}

extension OCTToxErrorFriendDelete {
    func strings() -> (title: String, message: String) {
        switch self {
            case .notFound:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
        }
    }
}

extension OCTToxAVErrorCall {
    func strings() -> (title: String, message: String) {
        switch self {
            case .alreadyInCall:
                return (String(localized: "error_title"),
                        String(localized: "call_error_already_in_call"))
            case .friendNotConnected:
                return (String(localized: "error_title"),
                        String(localized: "call_error_contact_is_offline"))
            case .friendNotFound:
                fallthrough
            case .invalidBitRate:
                fallthrough
            case .malloc:
                fallthrough
            case .sync:
                fallthrough
            case .unknown:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
        }
    }
}

extension OCTToxAVErrorAnswer {
    func strings() -> (title: String, message: String) {
        switch self {
            case .friendNotCalling:
                return (String(localized: "error_title"),
                        String(localized: "call_error_no_active_call"))
            case .codecInitialization:
                fallthrough
            case .sync:
                fallthrough
            case .invalidBitRate:
                fallthrough
            case .unknown:
                fallthrough
            case .friendNotFound:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
        }
    }
}

extension OCTSetUserAvatarError {
    func strings() -> (title: String, message: String) {
        switch self {
            case .tooBig:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
        }
    }
}

extension OCTSendFileError {
    func strings() -> (title: String, message: String) {
        switch self {
            case .internalError:
                fallthrough
            case .cannotReadFile:
                fallthrough
            case .cannotSaveFileToUploads:
                fallthrough
            case .nameTooLong:
                fallthrough
            case .friendNotFound:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
            case .friendNotConnected:
                return (String(localized: "error_title"),
                        String(localized: "error_contact_not_connected"))
            case .tooMany:
                return (String(localized: "error_title"),
                        String(localized: "error_too_many_files"))
        }
    }
}

extension OCTAcceptFileError {
    func strings() -> (title: String, message: String) {
        switch self {
            case .internalError:
                fallthrough
            case .cannotWriteToFile:
                fallthrough
            case .friendNotFound:
                fallthrough
            case .wrongMessage:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
            case .friendNotConnected:
                return (String(localized: "error_title"),
                        String(localized: "error_contact_not_connected"))
        }
    }
}

extension OCTFileTransferError {
    func strings() -> (title: String, message: String) {
        switch self {
            case .wrongMessage:
                return (String(localized: "error_title"),
                        String(localized: "error_internal_message"))
        }
    }
}
