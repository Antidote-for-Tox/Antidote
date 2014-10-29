//
//  ToxManagerFiles.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 23.10.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ToxManager.h"

@interface ToxManagerFiles : NSObject

- (instancetype)initOnToxQueue;

- (void)qAcceptOrRefusePendingFileInMessage:(CDMessage *)message accept:(BOOL)accept;
- (void)qTogglePauseForPendingFileInMessage:(CDMessage *)message;

- (void)qUploadData:(NSData *)data withFileName:(NSString *)fileName toChat:(CDChat *)chat;

- (CGFloat)synchronizedProgressForFileWithFriendNumber:(uint32_t)friendNumber
                                            fileNumber:(uint8_t)fileNumber
                                            isOutgoing:(BOOL)isOutgoing;


@end
