//
//  ToxManager+PrivateFiles.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 15.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxManager+PrivateFiles.h"
#import "ToxManager+Private.h"
#import "ToxManager+PrivateChat.h"
#import "CoreDataManager+Message.h"
#import "EventsManager.h"
#import "AppDelegate.h"

void fileSendRequestCallback(Tox *, int32_t, uint8_t, uint64_t, const uint8_t *, uint16_t, void *);
void fileControlCallback(Tox *, int32_t, uint8_t, uint8_t, uint8_t, const uint8_t *, uint16_t, void *);
void fileDataCallback(Tox *, int32_t, uint8_t, const uint8_t *, uint16_t, void *);

@implementation ToxManager (PrivateFiles)

#pragma mark -  Public

- (void)qRegisterFilesCallbacks
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    tox_callback_file_send_request (self.tox, fileSendRequestCallback, NULL);
    tox_callback_file_control      (self.tox, fileControlCallback,     NULL);
    tox_callback_file_data         (self.tox, fileDataCallback,        NULL);
}

- (void)qAcceptOrRefusePendingFileInMessage:(CDMessage *)message accept:(BOOL)accept
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    if (! message.pendingFile.isActive) {
        return;
    }

    uint8_t messageId = 0;

    if (accept) {
        messageId = TOX_FILECONTROL_ACCEPT;
    }
    else {
        messageId = TOX_FILECONTROL_KILL;

        [CoreDataManager editCDMessageAndSendNotificationsWithMessage:message block:^{
            message.pendingFile.isActive = NO;

        } completionQueue:nil completionBlock:nil];
    }

    tox_file_send_control(
            self.tox,
            message.pendingFile.friendNumber,
            1,
            message.pendingFile.fileNumber,
            messageId,
            NULL,
            0);
}

#pragma mark -  Private

- (void)qIncomingFileFromFriend:(ToxFriend *)friend
                       fileName:(NSString *)fileName
                     fileNumber:(uint8_t)fileNumber
                       fileSize:(uint64_t)fileSize
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    __weak ToxManager *weakSelf = self;

    [self qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
        [weakSelf qChatWithUser:user completionBlock:^(CDChat *chat) {
            NSString *documentPath = [weakSelf newDocumentPath];

            [weakSelf qAddPendingFileToChat:chat
                                   fromUser:user
                                 fileNumber:fileNumber
                               friendNumber:friend.id
                                   fileSize:fileSize
                                   fileName:fileName
                               documentPath:documentPath
                            completionBlock:^(CDMessage *cdMessage)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    EventObject *object = [EventObject objectWithType:EventObjectTypeChatIncomingFile
                                                                image:nil
                                                               object:cdMessage];
                    [[EventsManager sharedInstance] addObject:object];

                    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [delegate updateBadgeForTab:AppDelegateTabIndexChats];
                });
            }];
        }];
    }];
}

- (void)qAddPendingFileToChat:(CDChat *)chat
                     fromUser:(CDUser *)user
                   fileNumber:(uint16_t)fileNumber
                 friendNumber:(int32_t)friendNumber
                     fileSize:(uint64_t)fileSize
                     fileName:(NSString *)fileName
                 documentPath:(NSString *)documentPath
              completionBlock:(void (^)(CDMessage *message))completionBlock
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    [CoreDataManager insertMessageWithType:CDMessageTypePendingFile configBlock:^(CDMessage *m) {
        m.date = [[NSDate date] timeIntervalSince1970];
        m.chat = chat;
        m.user = user;

        m.pendingFile.isActive     = YES;
        m.pendingFile.fileNumber   = fileNumber;
        m.pendingFile.friendNumber = friendNumber;
        m.pendingFile.fileSize     = fileSize;
        m.pendingFile.fileName     = fileName;
        m.pendingFile.documentPath = documentPath;
        m.pendingFile.loadedSize   = 0;

        if (m.date > chat.lastMessage.date) {
            m.chatForLastMessageInverse = chat;
        }

    } completionQueue:self.queue completionBlock:completionBlock];
}

- (NSString *)newDocumentPath
{
    CFUUIDRef uuidObj = CFUUIDCreate(NULL);
    NSString *identifier = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuidObj);
    CFRelease(uuidObj);

    return [NSString stringWithFormat:@"Files/%@", identifier];
}

@end

#pragma mark -  C functions

void fileSendRequestCallback(
        Tox *tox,
        int32_t friendnumber,
        uint8_t filenumber,
        uint64_t filesize,
        const uint8_t *filename,
        uint16_t filename_length,
        void *userdata)
{
    NSLog(@"ToxManager: fileSendRequestCallback %d %d %llu %s", friendnumber, filenumber, filesize, filename);

    ToxFriend *friend = [[ToxManager sharedInstance].friendsContainer friendWithId:friendnumber];

    NSString *fileNameString = [[NSString alloc] initWithBytes:filename
                                                        length:filename_length
                                                      encoding:NSUTF8StringEncoding];

    [[ToxManager sharedInstance] qIncomingFileFromFriend:friend
                                                fileName:fileNameString
                                              fileNumber:filenumber
                                                fileSize:filesize];
}

void fileControlCallback(
        Tox *tox,
        int32_t friendnumber,
        uint8_t receive_send,
        uint8_t filenumber,
        uint8_t control_type,
        const uint8_t *data,
        uint16_t length,
        void *userdata)
{
    NSLog(@"ToxManager: fileControlCallback %d %d %d", friendnumber, filenumber, receive_send);
}

void fileDataCallback(
        Tox *tox,
        int32_t friendnumber,
        uint8_t filenumber,
        const uint8_t *data,
        uint16_t length,
        void *userdata)
{
    NSLog(@"ToxManager: fileDataCallback %d %d %d", friendnumber, filenumber, length);

}

