//
//  ErrorHandler.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 30/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ErrorHandler.h"
#import "OCTToxConstants.h"

#define ELOCALIZED(string) NSLocalizedString(string, @"ErrorHandler")
#define INTERNAL_ERROR ELOCALIZED(@"Internal error")

@implementation ErrorHandler

#pragma mark -  Public

- (void)handleError:(NSError *)error type:(ErrorHandlerType)type
{
    DDLogWarn(@"ErrorHandler: handling type %lu, error %@", type, error);

    switch (type) {
        case ErrorHandlerTypeSetUserName:
            [self handleSetUserNameError:error];
            break;
        case ErrorHandlerTypeSetUserStatus:
            [self handleSetUserStatusError:error];
            break;
        case ErrorHandlerTypeSendFriendRequest:
            [self handleSendFriendRequestError:error];
            break;
        case ErrorHandlerTypeApproveFriendRequest:
            [self handleApproveFriendRequestError:error];
            break;
        case ErrorHandlerTypeRemoveFriend:
            [self handleRemoveFriendError:error];
            break;
        case ErrorHandlerTypeSendMessage:
            [self handleSendMessageError:error];
            break;
        case ErrorHandlerTypeDeleteProfile:
            [self handleDeleteProfileError:error];
            break;
        case ErrorHandlerTypeRenameProfile:
            [self handleRenameProfileError:error];
            break;
        case ErrorHandlerTypeOpenFileFromOtherApp:
            [self handleOpenFileFromOtherAppError:error];
            break;
        case ErrorHandlerTypeExportProfile:
            [self handleExportProfileError:error];
            break;
    }
}

#pragma mark -  Private

- (void)showErrorWithMessage:(NSString *)message
{
    DDLogWarn(@"ErrorHandler: showing message \"%@\"", message);

    [[[UIAlertView alloc] initWithTitle:ELOCALIZED(@"Error")
                                message:message
                               delegate:nil
                      cancelButtonTitle:ELOCALIZED(@"OK")
                      otherButtonTitles:nil] show];
}

- (void)handleSetUserNameError:(NSError *)error
{
    OCTToxErrorSetInfoCode code = error.code;
    NSString *message;

    switch (code) {
        case OCTToxErrorSetInfoCodeTooLong:
            message = ELOCALIZED(@"Name is too long");
            break;
        case OCTToxErrorSetInfoCodeUnknow:
            message = INTERNAL_ERROR;
            break;
    }

    [self showErrorWithMessage:message];
}

- (void)handleSetUserStatusError:(NSError *)error
{
    OCTToxErrorSetInfoCode code = error.code;
    NSString *message;

    switch (code) {
        case OCTToxErrorSetInfoCodeTooLong:
            message = ELOCALIZED(@"Status message is too long");
            break;
        case OCTToxErrorSetInfoCodeUnknow:
            message = INTERNAL_ERROR;
            break;
    }

    [self showErrorWithMessage:message];
}

- (void)handleSendFriendRequestError:(NSError *)error
{
    OCTToxErrorFriendAdd code = error.code;
    NSString *message;

    switch (code) {
        case OCTToxErrorFriendAddTooLong:
            message = ELOCALIZED(@"Message is too long");
            break;
        case OCTToxErrorFriendAddNoMessage:
            message = ELOCALIZED(@"No message specified");
            break;
        case OCTToxErrorFriendAddOwnKey:
            message = ELOCALIZED(@"Cannot add myself to friend list");
            break;
        case OCTToxErrorFriendAddAlreadySent:
            message = ELOCALIZED(@"Friend request was already sent");
            break;
        case OCTToxErrorFriendAddBadChecksum:
            message = ELOCALIZED(@"Bad checksum, please check entered Tox ID");
            break;
        case OCTToxErrorFriendAddSetNewNospam:
            message = ELOCALIZED(@"Bad nospam value, please check entered Tox ID");
            break;
        case OCTToxErrorFriendAddMalloc:
        case OCTToxErrorFriendAddUnknown:
            message = INTERNAL_ERROR;
            break;
    }

    [self showErrorWithMessage:message];
}

- (void)handleApproveFriendRequestError:(NSError *)error
{
    OCTToxErrorFriendAdd code = error.code;
    NSString *message;

    switch (code) {
        case OCTToxErrorFriendAddTooLong:
        case OCTToxErrorFriendAddNoMessage:
        case OCTToxErrorFriendAddOwnKey:
        case OCTToxErrorFriendAddAlreadySent:
        case OCTToxErrorFriendAddBadChecksum:
        case OCTToxErrorFriendAddSetNewNospam:
        case OCTToxErrorFriendAddMalloc:
        case OCTToxErrorFriendAddUnknown:
            message = INTERNAL_ERROR;
            break;
    }

    [self showErrorWithMessage:message];
}

- (void)handleRemoveFriendError:(NSError *)error
{
    OCTToxErrorFriendDelete code = error.code;
    NSString *message;

    switch (code) {
        case OCTToxErrorFriendDeleteNotFound:
            message = INTERNAL_ERROR;
            break;
    }

    [self showErrorWithMessage:message];
}

- (void)handleSendMessageError:(NSError *)error
{
    OCTToxErrorFriendSendMessage code = error.code;
    NSString *message;

    switch (code) {
        case OCTToxErrorFriendSendMessageTooLong:
            message = ELOCALIZED(@"Message is too long");
            break;
        case OCTToxErrorFriendSendMessageEmpty:
            message = ELOCALIZED(@"Cannot send empty message");
            break;
        case OCTToxErrorFriendSendMessageFriendNotConnected:
            message = ELOCALIZED(@"Friend is not connected");
            break;
        case OCTToxErrorFriendSendMessageUnknown:
        case OCTToxErrorFriendSendMessageFriendNotFound:
        case OCTToxErrorFriendSendMessageAlloc:
            message = INTERNAL_ERROR;
            break;
    }

    [self showErrorWithMessage:message];
}

- (void)handleDeleteProfileError:(NSError *)error
{
    [self showErrorWithMessage:[error localizedDescription]];
}

- (void)handleRenameProfileError:(NSError *)error
{
    NSString *message = INTERNAL_ERROR;

    if (error.code == NSFileWriteInvalidFileNameError) {
        message = ELOCALIZED(@"Invalid name");
    }
    else if (error.code == NSFileWriteFileExistsError) {
        message = ELOCALIZED(@"Profile with this name already exists");
    }

    [self showErrorWithMessage:message];
}

- (void)handleOpenFileFromOtherAppError:(NSError *)error
{
    [self showErrorWithMessage:[error localizedDescription]];
}

- (void)handleExportProfileError:(NSError *)error
{
    [self showErrorWithMessage:[error localizedDescription]];
}

@end
