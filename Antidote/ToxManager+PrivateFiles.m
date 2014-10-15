//
//  ToxManager+PrivateFiles.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 15.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>

#import "ToxManager+PrivateFiles.h"
#import "ToxManager+Private.h"
#import "ToxManager+PrivateChat.h"
#import "CoreDataManager+Message.h"
#import "EventsManager.h"
#import "AppDelegate.h"
#import "ToxDownloadingFile.h"
#import "ToxUploadingFile.h"
#import "ProfileManager.h"
#import "CDUser.h"
#import "Helper.h"

void fileSendRequestCallback(Tox *, int32_t, uint8_t, uint64_t, const uint8_t *, uint16_t, void *);
void fileControlCallback(Tox *, int32_t, uint8_t, uint8_t, uint8_t, const uint8_t *, uint16_t, void *);
void fileDataCallback(Tox *, int32_t, uint8_t, const uint8_t *, uint16_t, void *);

@implementation ToxManager (PrivateFiles)

#pragma mark -  Public

- (void)qRegisterFilesCallbacksAndSetup
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager+PrivateFiles: registering callbacks");

    self.privateFiles_downloadingFiles = [NSMutableDictionary new];
    self.privateFiles_uploadingFiles = [NSMutableDictionary new];

    tox_callback_file_send_request (self.tox, fileSendRequestCallback, NULL);
    tox_callback_file_control      (self.tox, fileControlCallback,     NULL);
    tox_callback_file_data         (self.tox, fileDataCallback,        NULL);

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pendingFile.state != %d",
                CDMessagePendingFileStateCanceled];

    // mark all pending messages as canceled
    [CoreDataManager messagesWithPredicate:predicate completionQueue:self.queue completionBlock:^(NSArray *array) {
        for (CDMessage *message in array) {

            [CoreDataManager editCDMessageAndSendNotificationsWithMessage:message block:^{
                message.pendingFile.state = CDMessagePendingFileStateCanceled;
            } completionQueue:nil completionBlock:nil];
        }
    }];

    // remove all temp files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    ProfileManager *profileManager = [ProfileManager sharedInstance];
    NSString *tempFileDirectoryPath = [profileManager fileDirectoryPathForCurrentProfileIsTemporary:YES];

    if ([fileManager fileExistsAtPath:tempFileDirectoryPath]) {
        NSError *error;

        [fileManager removeItemAtPath:tempFileDirectoryPath error:&error];

        if (error) {
            DDLogWarn(@"ToxManager: cannot remove tempFileDirectoryPath %@ error %@", tempFileDirectoryPath, error);
        }
    }
}

- (void)qAcceptOrRefusePendingFileInMessage:(CDMessage *)message accept:(BOOL)accept
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager: accept or refuse pending file %d...", accept);

    BOOL isOutgoingMessage = [Helper isOutgoingMessage:message];

    if (isOutgoingMessage && accept) {
        DDLogError(@"ToxManager: cannot accept outgoing message %@", message.pendingFile);
        return;
    }

    if (message.pendingFile.state != CDMessagePendingFileStateWaitingConfirmation &&
        message.pendingFile.state != CDMessagePendingFileStateActive)
    {
        DDLogError(@"ToxManager: accept or refuse... wrong state %@", message.pendingFile);
        return;
    }

    uint8_t messageId;
    CDMessagePendingFileState state;

    if (accept) {
        messageId = TOX_FILECONTROL_ACCEPT;
        state = CDMessagePendingFileStateActive;

        NSString *key = [self keyFromFriendNumber:message.pendingFile.friendNumber
                                       fileNumber:message.pendingFile.fileNumber
                                      downloading:YES];

        ProfileManager *profileManager = [ProfileManager sharedInstance];
        NSString *path = [profileManager pathInFilesForCurrentProfileFromFileName:message.pendingFile.fileNameOnDisk
                                                                        temporary:YES];

        @synchronized(self.privateFiles_downloadingFiles) {
            self.privateFiles_downloadingFiles[key] = [[ToxDownloadingFile alloc] initWithFilePath:path];
        }
    }
    else {
        messageId = TOX_FILECONTROL_KILL;
        state = CDMessagePendingFileStateCanceled;

        if (isOutgoingMessage) {
            NSString *key = [[ToxManager sharedInstance] keyFromFriendNumber:message.pendingFile.friendNumber
                                                                  fileNumber:message.pendingFile.fileNumber
                                                                 downloading:NO];

            @synchronized(self.privateFiles_uploadingFiles) {
                [self.privateFiles_uploadingFiles removeObjectForKey:key];
            }
        }
    }

    tox_file_send_control(
            self.tox,
            message.pendingFile.friendNumber,
            isOutgoingMessage ? 0 : 1,
            message.pendingFile.fileNumber,
            messageId,
            NULL,
            0);

    [CoreDataManager editCDMessageAndSendNotificationsWithMessage:message block:^{
        message.pendingFile.state = state;

    } completionQueue:nil completionBlock:nil];

    DDLogInfo(@"ToxManager: accept or refuse... success");
}

- (CGFloat)synchronizedProgressForFileWithFriendNumber:(uint32_t)friendNumber
                                            fileNumber:(uint8_t)fileNumber
                                            isOutgoing:(BOOL)isOutgoing
{
    NSString *key = [[ToxManager sharedInstance] keyFromFriendNumber:friendNumber
                                                          fileNumber:fileNumber
                                                         downloading:!isOutgoing];

    if (isOutgoing) {
        @synchronized(self.privateFiles_uploadingFiles) {
            ToxUploadingFile *file = self.privateFiles_uploadingFiles[key];

            return [self progressFromUploadingFile:file
                                      friendNumber:friendNumber
                                        fileNumber:fileNumber];
        }
    }
    else {
        @synchronized(self.privateFiles_downloadingFiles) {
            ToxDownloadingFile *file = self.privateFiles_downloadingFiles[key];

            return [self progressFromDownloadingFile:file
                                        friendNumber:friendNumber
                                          fileNumber:fileNumber];
        }
    }
}

- (void)qTogglePauseForPendingFileInMessage:(CDMessage *)message
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager: toggle pause for pending file...");

    if (! message.pendingFile) {
        DDLogWarn(@"ToxManager: toggle pause for pending file... wrong message, quiting");
        return;
    }

    uint8_t messageId;
    CDMessagePendingFileState newState;

    if (message.pendingFile.state == CDMessagePendingFileStateActive) {
        messageId = TOX_FILECONTROL_PAUSE;
        newState = CDMessagePendingFileStatePaused;
    }
    else if (message.pendingFile.state == CDMessagePendingFileStatePaused) {
        messageId = TOX_FILECONTROL_ACCEPT;
        newState = CDMessagePendingFileStateActive;
    }
    else {
        DDLogWarn(@"ToxManager: toggle pause for pending file... wrong status, quiting");
        return;
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
        message.pendingFile.state = newState;

    } completionQueue:nil completionBlock:nil];

    DDLogInfo(@"ToxManager: toggle pause for pending file... success, pause = %d",
            messageId == TOX_FILECONTROL_PAUSE);
}

- (void)qUploadData:(NSData *)data withFileName:(NSString *)originalFileName toChat:(CDChat *)chat
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager: upload data with fileName %@, size %lu", originalFileName, (unsigned long)data.length);

    if (chat.users.count > 1) {
        DDLogError(@"ToxManager: send message... group chats aren't supported yet");
        return;
    }

    const uint64_t fileSize = data.length;
    NSString *filePath = nil;
    NSString *fileNameOnDisk = [self uniqueFileNameOnDiskWithExtension:[originalFileName pathExtension]];
    {
        // save file on disk
        DDLogInfo(@"ToxManager: saving data on disk with fileName %@", fileNameOnDisk);

        ProfileManager *profileManager = [ProfileManager sharedInstance];
        filePath = [profileManager pathInFilesForCurrentProfileFromFileName:fileNameOnDisk temporary:NO];

        [[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];

        [data writeToFile:filePath atomically:YES];
    }

    CDUser *user = [chat.users anyObject];
    ToxFriend *friend = [self.friendsContainer friendWithClientId:user.clientId];

    const char *cFileName = [originalFileName cStringUsingEncoding:NSUTF8StringEncoding];
    uint16_t cFileNameLength = [originalFileName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

    int fileNumber = tox_new_file_sender(self.tox, friend.id, fileSize, (const uint8_t *)cFileName, cFileNameLength);

    __weak ToxManager *weakSelf = self;

    NSString *key = [[ToxManager sharedInstance] keyFromFriendNumber:friend.id
                                                          fileNumber:fileNumber
                                                         downloading:NO];

    int portionSize = tox_file_data_size(self.tox, friend.id);

    @synchronized(self.privateFiles_uploadingFiles) {
        self.privateFiles_uploadingFiles[key] = [[ToxUploadingFile alloc] initWithFilePath:filePath
                                                                               portionSize:portionSize];
    }

    [self qUserFromClientId:[self qClientId] completionBlock:^(CDUser *currentUser) {
        [weakSelf qChatWithUser:user completionBlock:^(CDChat *chat) {
            [weakSelf qAddPendingFileToChat:chat
                                   fromUser:currentUser
                                 fileNumber:fileNumber
                               friendNumber:friend.id
                                   fileSize:fileSize
                           originalFileName:originalFileName
                             fileNameOnDisk:fileNameOnDisk
                            completionBlock:nil];
        }];
    }];
}

#pragma mark -  Private

- (void)qIncomingFileFromFriend:(ToxFriend *)friend
               originalFileName:(NSString *)originalFileName
                     fileNumber:(uint8_t)fileNumber
                       fileSize:(uint64_t)fileSize
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager: incoming file from friend id %d, filenumber %d", friend.id, fileNumber);

    __weak ToxManager *weakSelf = self;

    [self qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
        [weakSelf qChatWithUser:user completionBlock:^(CDChat *chat) {
            NSString *fileNameOnDisk = [weakSelf uniqueFileNameOnDiskWithExtension:[originalFileName pathExtension]];

            DDLogInfo(@"ToxManager: creating new document with fileNameOnDisk %@", fileNameOnDisk);

            [weakSelf qAddPendingFileToChat:chat
                                   fromUser:user
                                 fileNumber:fileNumber
                               friendNumber:friend.id
                                   fileSize:fileSize
                           originalFileName:originalFileName
                             fileNameOnDisk:fileNameOnDisk
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

    NSString *key = [self keyFromFriendNumber:friendNumber
                                   fileNumber:fileNumber
                                  downloading:YES];

    @synchronized(self.privateFiles_downloadingFiles) {
        ToxDownloadingFile *file = self.privateFiles_downloadingFiles[key];
        [file finishDownloading];

        [self.privateFiles_downloadingFiles removeObjectForKey:key];
    }

    tox_file_send_control(self.tox, friendNumber, 1, fileNumber, TOX_FILECONTROL_FINISHED, NULL, 0);

    NSPredicate *predicate = [NSPredicate predicateWithFormat:
        @"pendingFile.fileNumber == %d AND pendingFile.friendNumber == %d", fileNumber, friendNumber];

    [CoreDataManager messagesWithPredicate:predicate completionQueue:self.queue completionBlock:^(NSArray *array) {
        if (! array.count) {
            return;
        }

        CDMessage *message = [array lastObject];

        ProfileManager *profileManager = [ProfileManager sharedInstance];
        NSString *oldPath = [profileManager pathInFilesForCurrentProfileFromFileName:message.pendingFile.fileNameOnDisk
                                                                           temporary:YES];
        NSString *newPath = [profileManager pathInFilesForCurrentProfileFromFileName:message.pendingFile.fileNameOnDisk
                                                                           temporary:NO];

        NSError *error = nil;

        [[NSFileManager defaultManager] createDirectoryAtPath:[newPath stringByDeletingLastPathComponent]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];

        if (error) {
            DDLogError(@"ToxManager: cannot create directory at path %@ error %@",
                    [newPath stringByDeletingLastPathComponent], error);
            return;
        }

        [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];

        if (error) {
            DDLogError(@"ToxManager: cannot move file from path %@ to newPath %@ error %@", oldPath, newPath, error);
            return;
        }

        [CoreDataManager movePendingFileToFileForMessage:message
                                         completionQueue:nil
                                         completionBlock:nil];
    }];
}

- (void)qFileTransferAcceptedWithFriendNumber:(int32_t)friendNumber fileNumber:(uint8_t)fileNumber
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager+PrivateFiles: friend accepted uploading file %d, starting upload", fileNumber);

    [self qChangeUploadingPendingFileStateTo:CDMessagePendingFileStateActive
                            withFriendNumber:friendNumber
                                  fileNumber:fileNumber];

    NSString *key = [[ToxManager sharedInstance] keyFromFriendNumber:friendNumber
                                                          fileNumber:fileNumber
                                                         downloading:NO];

    @synchronized(self.privateFiles_uploadingFiles) {
        ToxUploadingFile *file = self.privateFiles_uploadingFiles[key];
        file.paused = NO;
    }

    [self qUploadNextFileChunkWithFriendNumber:friendNumber fileNumber:fileNumber];
}

- (void)qUploadNextFileChunkWithFriendNumber:(int32_t)friendNumber fileNumber:(uint8_t)fileNumber
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    NSString *key = [[ToxManager sharedInstance] keyFromFriendNumber:friendNumber
                                                          fileNumber:fileNumber
                                                         downloading:NO];

    ToxUploadingFile *file;
    @synchronized(self.privateFiles_uploadingFiles) {
        file = self.privateFiles_uploadingFiles[key];
    }

    if (! file) {
        DDLogInfo(@"ToxManager+PrivateFiles: no file with key %@ found, quiting", key);
        return;
    }

    if (file.paused) {
        DDLogInfo(@"ToxManager+PrivateFiles: file for key %@ is paused, quiting", key);
        return;
    }

    uint8_t buffer[file.portionSize];

    BOOL (^checkLength)(uint16_t) = ^(uint16_t length) {
        if (! length) {
            tox_file_send_control(self.tox, friendNumber, 0, fileNumber, TOX_FILECONTROL_FINISHED, NULL, 0);

            DDLogInfo(@"ToxManager+PrivateFiles: file successfully sended with key %@", key);

            return NO;
        }

        return YES;
    };

    uint16_t length = [file nextPortionOfBytes:&buffer];
    if (! checkLength(length)) {
        return;
    }

    const uint32_t toxDoInterval = tox_do_interval(self.tox);
    NSDate *startDate = [NSDate date];

    while (tox_file_send_data(self.tox, friendNumber, fileNumber, buffer, length) == 0) {
        file.numberOfFailuresInARow = 0;
        [file goForwardOnLength:length];

        length = [file nextPortionOfBytes:&buffer];
        if (! checkLength(length)) {
            return;
        }

        // letting tox_do run
        if ([[NSDate date] timeIntervalSinceDate:startDate] >= toxDoInterval) {
            break;
        }
    }

    NSDate *now = [NSDate date];
    if ([now timeIntervalSinceDate:file.lastUIUpdateDate] > kToxUploadingFilesUIUpdateInterval) {
        file.lastUIUpdateDate = now;

        CGFloat progress = [[ToxManager sharedInstance] progressFromUploadingFile:file
                                                                     friendNumber:friendNumber
                                                                       fileNumber:fileNumber];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ToxManager sharedInstance].fileProgressDelegate toxManagerProgressChanged:progress
                                                           forPendingFileWithFileNumber:fileNumber
                                                                           friendNumber:friendNumber];
        });
    }

    file.numberOfFailuresInARow++;

    if (file.numberOfFailuresInARow > kToxUploadingFilesMaxNumberOfFailures) {
        DDLogWarn(@"ToxManager+PrivateFiles: too many failures in a row while uploading file %@, removing it",
                key);

        @synchronized(self.privateFiles_uploadingFiles) {
            [self.privateFiles_uploadingFiles removeObjectForKey:key];
        }
        [self qChangeUploadingPendingFileStateTo:CDMessagePendingFileStateCanceled
                                withFriendNumber:friendNumber
                                      fileNumber:fileNumber];

        return;
    }

    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, toxDoInterval * USEC_PER_SEC);

    dispatch_after(time, self.queue, ^{
        [self qUploadNextFileChunkWithFriendNumber:friendNumber fileNumber:fileNumber];
    });
}

- (void)qFinishUploadingWithFriendNumber:(int32_t)friendNumber fileNumber:(uint8_t)fileNumber
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    NSString *key = [[ToxManager sharedInstance] keyFromFriendNumber:friendNumber
                                                          fileNumber:fileNumber
                                                         downloading:NO];

    ToxUploadingFile *file;
    @synchronized(self.privateFiles_uploadingFiles) {
        file = self.privateFiles_uploadingFiles[key];

        [file finishUploading];
        [self.privateFiles_uploadingFiles removeObjectForKey:key];
    }

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

- (void)qUploadPausedWithFriendNumber:(uint32_t)friendNumber fileNumber:(uint16_t)fileNumber
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    [self qChangeUploadingPendingFileStateTo:CDMessagePendingFileStatePaused
                            withFriendNumber:friendNumber
                                  fileNumber:fileNumber];

    NSString *key = [[ToxManager sharedInstance] keyFromFriendNumber:friendNumber
                                                          fileNumber:fileNumber
                                                         downloading:NO];

    @synchronized(self.privateFiles_uploadingFiles) {
        ToxUploadingFile *file = self.privateFiles_uploadingFiles[key];
        file.paused = YES;
    }
}

- (void)qUploadKilledWithFriendNumber:(uint32_t)friendNumber fileNumber:(uint16_t)fileNumber
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    [self qChangeUploadingPendingFileStateTo:CDMessagePendingFileStateCanceled
                            withFriendNumber:friendNumber
                                  fileNumber:fileNumber];

    NSString *key = [[ToxManager sharedInstance] keyFromFriendNumber:friendNumber
                                                          fileNumber:fileNumber
                                                         downloading:NO];

    @synchronized(self.privateFiles_uploadingFiles) {
        [self.privateFiles_uploadingFiles removeObjectForKey:key];
    }
}

- (void)qChangeUploadingPendingFileStateTo:(CDMessagePendingFileState)state
                          withFriendNumber:(int32_t)friendNumber
                                fileNumber:(uint8_t)fileNumber
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    NSPredicate *predicate = [NSPredicate predicateWithFormat:
        @"pendingFile.fileNumber == %d AND pendingFile.friendNumber == %d", fileNumber, friendNumber];

    [CoreDataManager messagesWithPredicate:predicate completionQueue:self.queue completionBlock:^(NSArray *array) {
        if (! array.count) {
            return;
        }

        CDMessage *message = [array lastObject];

        [CoreDataManager editCDMessageAndSendNotificationsWithMessage:message block:^{
            message.pendingFile.state = state;
        } completionQueue:nil completionBlock:nil];
    }];
}

- (void)qAddPendingFileToChat:(CDChat *)chat
                     fromUser:(CDUser *)user
                   fileNumber:(uint16_t)fileNumber
                 friendNumber:(int32_t)friendNumber
                     fileSize:(uint64_t)fileSize
             originalFileName:(NSString *)originalFileName
               fileNameOnDisk:(NSString *)fileNameOnDisk
              completionBlock:(void (^)(CDMessage *message))completionBlock
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManager: adding pending file to CoreData");

    NSTimeInterval dateInterval = [[NSDate date] timeIntervalSince1970];

    NSString *fileUTI = nil;
    NSString *extension = [originalFileName pathExtension];

    if (extension) {
        fileUTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(
                kUTTagClassFilenameExtension,
                (__bridge CFStringRef)extension,
                NULL);
    }

    [CoreDataManager insertMessageWithType:CDMessageTypePendingFile configBlock:^(CDMessage *m) {
        m.date = dateInterval;
        m.chat = chat;
        m.user = user;

        m.pendingFile.state            = CDMessagePendingFileStateWaitingConfirmation;
        m.pendingFile.fileNumber       = fileNumber;
        m.pendingFile.friendNumber     = friendNumber;
        m.pendingFile.fileSize         = fileSize;
        m.pendingFile.originalFileName = originalFileName;
        m.pendingFile.fileNameOnDisk   = fileNameOnDisk;
        m.pendingFile.fileUTI          = fileUTI;

        if (m.date > chat.lastMessage.date) {
            m.chatForLastMessageInverse = chat;
        }

    } completionQueue:self.queue completionBlock:completionBlock];
}

- (NSString *)uniqueFileNameOnDiskWithExtension:(NSString *)extension
{
    return [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:extension];
}

- (NSString *)keyFromFriendNumber:(uint32_t)friendNumber
                       fileNumber:(uint8_t)fileNumber
                      downloading:(BOOL)downloading
{
    return [NSString stringWithFormat:@"%d-%d-%d", friendNumber, fileNumber, downloading];
}

- (CGFloat)progressFromDownloadingFile:(ToxDownloadingFile *)file
                          friendNumber:(uint32_t)friendNumber
                            fileNumber:(uint8_t)fileNumber
{
    const CGFloat saved = file.savedLength;
    const CGFloat remaining = tox_file_data_remaining([ToxManager sharedInstance].tox, friendNumber, fileNumber, 1);

    const CGFloat total = saved + remaining;

    return total ? saved/total : 0.0;
}

- (CGFloat)progressFromUploadingFile:(ToxUploadingFile *)file
                        friendNumber:(uint32_t)friendNumber
                          fileNumber:(uint8_t)fileNumber
{
    const CGFloat uploaded = [file uploadedLength];
    const CGFloat total = file.fileSize;

    return total ? uploaded/total : 0.0;
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

    dispatch_async([ToxManager sharedInstance].queue, ^{
        [[ToxManager sharedInstance] qIncomingFileFromFriend:friend
                                            originalFileName:fileNameString
                                                  fileNumber:filenumber
                                                    fileSize:filesize];
    });
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

    dispatch_async([ToxManager sharedInstance].queue, ^{
        if (receive_send == 0) {
            if (control_type == TOX_FILECONTROL_FINISHED) {
                [[ToxManager sharedInstance] qIncomingFileFinishedDownloadingWithFriendNumber:friendnumber
                                                                                   fileNumber:filenumber];
            }
        }
        else if (receive_send == 1) {
            if (control_type == TOX_FILECONTROL_ACCEPT) {
                [[ToxManager sharedInstance] qFileTransferAcceptedWithFriendNumber:friendnumber
                                                                        fileNumber:filenumber];
            }
            else if (control_type == TOX_FILECONTROL_FINISHED) {
                [[ToxManager sharedInstance] qFinishUploadingWithFriendNumber:friendnumber fileNumber:filenumber];
            }
            else if (control_type == TOX_FILECONTROL_PAUSE) {
                [[ToxManager sharedInstance] qUploadPausedWithFriendNumber:friendnumber fileNumber:filenumber];
            }
            else if (control_type == TOX_FILECONTROL_KILL) {
                [[ToxManager sharedInstance] qUploadKilledWithFriendNumber:friendnumber fileNumber:filenumber];
            }
        }
    });
}

void fileDataCallback(
        Tox *tox,
        int32_t friendnumber,
        uint8_t filenumber,
        const uint8_t *data,
        uint16_t length,
        void *userdata)
{
    NSData *nsData = [NSData dataWithBytes:data length:length];

    dispatch_async([ToxManager sharedInstance].queue, ^{
        NSString *key = [[ToxManager sharedInstance] keyFromFriendNumber:friendnumber
                                                              fileNumber:filenumber
                                                             downloading:YES];
        ToxDownloadingFile *file;

        @synchronized([ToxManager sharedInstance].privateFiles_downloadingFiles) {
            file = [ToxManager sharedInstance].privateFiles_downloadingFiles[key];
        }

        if (! file) {
            return;
        }

        BOOL didSaveOnDisk;

        [file appendData:nsData didSavedOnDisk:&didSaveOnDisk];

        if (didSaveOnDisk) {
            CGFloat progress = [[ToxManager sharedInstance] progressFromDownloadingFile:file
                                                                           friendNumber:friendnumber
                                                                             fileNumber:filenumber];

            dispatch_async(dispatch_get_main_queue(), ^{
                [[ToxManager sharedInstance].fileProgressDelegate toxManagerProgressChanged:progress
                                                               forPendingFileWithFileNumber:filenumber
                                                                               friendNumber:friendnumber];
            });
        }
    });
}

