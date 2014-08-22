//
//  ToxManager+PrivateFiles.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 15.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxManager.h"

@interface ToxManager (PrivateFiles)

- (void)qRegisterFilesCallbacksAndSetup;

- (void)qAcceptOrRefusePendingFileInMessage:(CDMessage *)message accept:(BOOL)accept;

- (CGFloat)synchronizedProgressForFileWithFriendNumber:(uint32_t)friendNumber fileNumber:(uint8_t)fileNumber;

- (void)qTogglePauseForPendingFileInMessage:(CDMessage *)message;

@end

