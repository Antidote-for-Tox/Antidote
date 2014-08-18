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
#import "ToxDownloadingFile.h"

void fileSendRequestCallback(Tox *, int32_t, uint8_t, uint64_t, const uint8_t *, uint16_t, void *);
void fileControlCallback(Tox *, int32_t, uint8_t, uint8_t, uint8_t, const uint8_t *, uint16_t, void *);
void fileDataCallback(Tox *, int32_t, uint8_t, const uint8_t *, uint16_t, void *);

@implementation ToxManager (PrivateFiles)

#pragma mark -  Public

- (void)qRegisterFilesCallbacksAndSetup
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager: registering callbacks");

    self.privateFiles_downloadingFiles = [NSMutableDictionary new];

    tox_callback_file_send_request (self.tox, fileSendRequestCallback, NULL);
    tox_callback_file_control      (self.tox, fileControlCallback,     NULL);
    tox_callback_file_data         (self.tox, fileDataCallback,        NULL);
}

- (void)qAcceptOrRefusePendingFileInMessage:(CDMessage *)message accept:(BOOL)accept
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager: accept or refuse pending file %d...", accept);

    if (message.pendingFile.state != CDMessagePendingFileStateWaitingConfirmation) {
        DDLogError(@"ToxManager: accept or refuse... wrong state %@", message.pendingFile);

        return;
    }

    uint8_t messageId;
    CDMessagePendingFileState state;

    if (accept) {
        messageId = TOX_FILECONTROL_ACCEPT;
        state = CDMessagePendingFileStateActive;

        NSString *key = [self keyFromFriendNumber:message.pendingFile.friendNumber
                                       fileNumber:message.pendingFile.fileNumber];

        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        path = [path stringByAppendingPathComponent:message.pendingFile.documentPath];

        self.privateFiles_downloadingFiles[key] = [[ToxDownloadingFile alloc] initWithFilePath:path];
    }
    else {
        messageId = TOX_FILECONTROL_KILL;
        state = CDMessagePendingFileStateCanceled;
    }

    tox_file_send_control(
            self.tox,
            message.pendingFile.friendNumber,
            1,
            message.pendingFile.fileNumber,
            messageId,
            NULL,
            0);

    [CoreDataManager editCDMessageAndSendNotificationsWithMessage:message block:^{
        message.pendingFile.state = state;

    } completionQueue:nil completionBlock:nil];

    DDLogInfo(@"ToxManager: accept or refuse... success");
}

#pragma mark -  Private

- (void)qIncomingFileFromFriend:(ToxFriend *)friend
                       fileName:(NSString *)fileName
                     fileNumber:(uint8_t)fileNumber
                       fileSize:(uint64_t)fileSize
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager: incoming file from friend id %d, filenumber %d", friend.id, fileNumber);

    __weak ToxManager *weakSelf = self;

    [self qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
        [weakSelf qChatWithUser:user completionBlock:^(CDChat *chat) {
            NSString *documentPath = [weakSelf newDocumentPathWithExtension:[fileName pathExtension]];

            DDLogInfo(@"ToxManager: creating new document path %@", documentPath);

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

- (void)qIncomingFileFinishedDownloadingWithFriendNumber:(int32_t)friendNumber fileNumber:(uint8_t)fileNumber
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager: incoming file finished downloading from friend id %d, filenumber %d",
            friendNumber, fileNumber);

    NSString *key = [self keyFromFriendNumber:friendNumber fileNumber:fileNumber];

    ToxDownloadingFile *file = self.privateFiles_downloadingFiles[key];
    [file finishDownloading];

    [self.privateFiles_downloadingFiles removeObjectForKey:key];

    tox_file_send_control(self.tox, friendNumber, 1, fileNumber, TOX_FILECONTROL_FINISHED, NULL, 0);

    NSPredicate *predicate = [NSPredicate predicateWithFormat:
        @"pendingFile.fileNumber == %d AND pendingFile.friendNumber == %d", fileNumber, friendNumber];

    [CoreDataManager messagesWithPredicate:predicate completionQueue:self.queue completionBlock:^(NSArray *array) {
        if (! array.count) {
            return;
        }

        CDMessage *message = [array lastObject];

        [CoreDataManager movePendingFileToFileForMessage:message completionQueue:nil completionBlock:nil];
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

    DDLogInfo(@"ToxManager: adding pending file to CoreData");

    [CoreDataManager insertMessageWithType:CDMessageTypePendingFile configBlock:^(CDMessage *m) {
        m.date = [[NSDate date] timeIntervalSince1970];
        m.chat = chat;
        m.user = user;

        m.pendingFile.state        = CDMessagePendingFileStateWaitingConfirmation;
        m.pendingFile.fileNumber   = fileNumber;
        m.pendingFile.friendNumber = friendNumber;
        m.pendingFile.fileSize     = fileSize;
        m.pendingFile.fileName     = fileName;
        m.pendingFile.documentPath = documentPath;

        if (m.date > chat.lastMessage.date) {
            m.chatForLastMessageInverse = chat;
        }

    } completionQueue:self.queue completionBlock:completionBlock];
}

- (NSString *)newDocumentPathWithExtension:(NSString *)extension
{
    CFUUIDRef uuidObj = CFUUIDCreate(NULL);
    NSString *identifier = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuidObj);
    CFRelease(uuidObj);

    return [[NSString stringWithFormat:@"Files/%@", identifier] stringByAppendingPathExtension:extension];
}

- (NSString *)keyFromFriendNumber:(uint32_t)friendNumber fileNumber:(uint8_t)fileNumber
{
    return [NSString stringWithFormat:@"%d-%d", friendNumber, fileNumber];
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
    DDLogCVerbose(@"ToxManager+PrivateFiles: fileSendRequestCallback with friendnumber %d filenumber %d filesize %llu",
            friendnumber, filenumber, filesize);

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
    DDLogCVerbose(@"ToxManager+PrivateFiles: fileControlCallback with friendnumber %d filenumber %d receiveSend %d controlType %d",
            friendnumber, filenumber, receive_send, control_type);

    if (receive_send == 0) {
        if (control_type == TOX_FILECONTROL_FINISHED) {
            [[ToxManager sharedInstance] qIncomingFileFinishedDownloadingWithFriendNumber:friendnumber
                                                                               fileNumber:filenumber];
        }
    }
}

void fileDataCallback(
        Tox *tox,
        int32_t friendnumber,
        uint8_t filenumber,
        const uint8_t *data,
        uint16_t length,
        void *userdata)
{
    NSString *key = [[ToxManager sharedInstance] keyFromFriendNumber:friendnumber fileNumber:filenumber];

    ToxDownloadingFile *file = [ToxManager sharedInstance].privateFiles_downloadingFiles[key];

    if (! file) {
        return;
    }

    BOOL didSaveOnDisk;

    [file appendData:[NSData dataWithBytes:data length:length] didSavedOnDisk:&didSaveOnDisk];

    if (didSaveOnDisk) {
        CGFloat saved = file.savedLength;
        CGFloat remaining = tox_file_data_remaining([ToxManager sharedInstance].tox, friendnumber, filenumber, 1);

        CGFloat total = saved + remaining;

        CGFloat progress = total ? saved/total : 0.0;

        dispatch_async(dispatch_get_main_queue(), ^{
            [[ToxManager sharedInstance].fileProgressDelegate toxManagerProgressChanged:progress
                                                           forPendingFileWithFileNumber:filenumber
                                                                           friendNumber:friendnumber];
        });
    }
}

