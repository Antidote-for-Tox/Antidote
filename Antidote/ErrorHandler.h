//
//  ErrorHandler.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 30/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ErrorHandlerType) {
    ErrorHandlerTypeSetUserName,
    ErrorHandlerTypeSetUserStatus,

    ErrorHandlerTypeSendFriendRequest,
    ErrorHandlerTypeApproveFriendRequest,
    ErrorHandlerTypeRemoveFriend,

    ErrorHandlerTypeSendMessage,

    ErrorHandlerTypeDeleteProfile,
    ErrorHandlerTypeRenameProfile,

    ErrorHandlerTypeOpenFileFromOtherApp,

    ErrorHandlerTypeExportProfile,
};

@interface ErrorHandler : NSObject

- (void)handleError:(NSError *)error type:(ErrorHandlerType)type;

@end
