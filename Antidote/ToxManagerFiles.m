//
//  ToxManagerFiles.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 23.10.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>

#import "ToxManagerFiles.h"
#import "ToxManager+Private.h"
#import "ToxManagerChats.h"
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

@interface ToxManagerFiles()

@property (strong, nonatomic) NSMutableDictionary *downloadingFiles;
@property (strong, nonatomic) NSMutableDictionary *uploadingFiles;

@end

@implementation ToxManagerFiles

#pragma mark -  Public

- (instancetype)initOnToxQueueWithToxManager:(ToxManager *)manager
{
    NSAssert([manager isOnToxManagerQueue], @"Must be on ToxManager queue");

    self = [super init];

    if (! self) {
        return nil;
    }

    DDLogInfo(@"ToxManagerFiles: registering callbacks");

    self.downloadingFiles = [NSMutableDictionary new];
    self.uploadingFiles = [NSMutableDictionary new];

    tox_callback_file_send_request (manager.tox, fileSendRequestCallback, NULL);
    tox_callback_file_control      (manager.tox, fileControlCallback,     NULL);
    tox_callback_file_data         (manager.tox, fileDataCallback,        NULL);

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pendingFile.state != %d",
                CDMessagePendingFileStateCanceled];

    // mark all pending messages as canceled
    [CoreDataManager messagesWithPredicate:predicate completionQueue:manager.queue completionBlock:^(NSArray *array) {
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
            DDLogWarn(@"ToxManagerFiles: cannot remove tempFileDirectoryPath %@ error %@", tempFileDirectoryPath, error);
        }
    }

    return self;
}

- (void)qAcceptOrRefusePendingFileInMessage:(CDMessage *)message accept:(BOOL)accept
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManagerFiles: accept or refuse pending file %d...", accept);

    BOOL isOutgoingMessage = [Helper isOutgoingMessage:message];

    if (isOutgoingMessage && accept) {
        DDLogError(@"ToxManagerFiles: cannot accept outgoing message %@", message.pendingFile);
        return;
    }

    if (message.pendingFile.state != CDMessagePendingFileStateWaitingConfirmation &&
        message.pendingFile.state != CDMessagePendingFileStateActive)
    {
        DDLogError(@"ToxManagerFiles: accept or refuse... wrong state %@", message.pendingFile);
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

        @synchronized(self.downloadingFiles) {
            self.downloadingFiles[key] = [[ToxDownloadingFile alloc] initWithFilePath:path];
        }
    }
    else {
        messageId = TOX_FILECONTROL_KILL;
        state = CDMessagePendingFileStateCanceled;

        if (isOutgoingMessage) {
            NSString *key = [self keyFromFriendNumber:message.pendingFile.friendNumber
                                           fileNumber:message.pendingFile.fileNumber
                                          downloading:NO];

            @synchronized(self.uploadingFiles) {
                [self.uploadingFiles removeObjectForKey:key];
            }
        }
    }

    tox_file_send_control(
            [ToxManager sharedInstance].tox,
            message.pendingFile.friendNumber,
            isOutgoingMessage ? 0 : 1,
            message.pendingFile.fileNumber,
            messageId,
            NULL,
            0);

    [CoreDataManager editCDMessageAndSendNotificationsWithMessage:message block:^{
        message.pendingFile.state = state;

    } completionQueue:nil completionBlock:nil];

    DDLogInfo(@"ToxManagerFiles: accept or refuse... success");
}

- (CGFloat)synchronizedProgressForFileWithFriendNumber:(uint32_t)friendNumber
                                            fileNumber:(uint8_t)fileNumber
                                            isOutgoing:(BOOL)isOutgoing
{
    NSString *key = [self keyFromFriendNumber:friendNumber fileNumber:fileNumber downloading:!isOutgoing];

    if (isOutgoing) {
        @synchronized(self.uploadingFiles) {
            ToxUploadingFile *file = self.uploadingFiles[key];

            return [self progressFromUploadingFile:file
                                      friendNumber:friendNumber
                                        fileNumber:fileNumber];
        }
    }
    else {
        @synchronized(self.downloadingFiles) {
            ToxDownloadingFile *file = self.downloadingFiles[key];

            return [self progressFromDownloadingFile:file
                                        friendNumber:friendNumber
                                          fileNumber:fileNumber];
        }
    }
}

- (void)qTogglePauseForPendingFileInMessage:(CDMessage *)message
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManagerFiles: toggle pause for pending file...");

    if (! message.pendingFile) {
        DDLogWarn(@"ToxManagerFiles: toggle pause for pending file... wrong message, quiting");
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
        DDLogWarn(@"ToxManagerFiles: toggle pause for pending file... wrong status, quiting");
        return;
    }

    tox_file_send_control(
            [ToxManager sharedInstance].tox,
            message.pendingFile.friendNumber,
            1,
            message.pendingFile.fileNumber,
            messageId,
            NULL,
            0);

    [CoreDataManager editCDMessageAndSendNotificationsWithMessage:message block:^{
        message.pendingFile.state = newState;

    } completionQueue:nil completionBlock:nil];

    DDLogInfo(@"ToxManagerFiles: toggle pause for pending file... success, pause = %d",
            messageId == TOX_FILECONTROL_PAUSE);
}

- (void)qUploadData:(NSData *)data withFileName:(NSString *)originalFileName toChat:(CDChat *)chat
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManagerFiles: upload data with fileName %@, size %lu", originalFileName, (unsigned long)data.length);

    if (chat.users.count > 1) {
        DDLogError(@"ToxManagerFiles: send message... group chats aren't supported yet");
        return;
    }

    const uint64_t fileSize = data.length;
    NSString *filePath = nil;
    NSString *fileNameOnDisk = [self uniqueFileNameOnDiskWithExtension:[originalFileName pathExtension]];
    {
        // save file on disk
        DDLogInfo(@"ToxManagerFiles: saving data on disk with fileName %@", fileNameOnDisk);

        ProfileManager *profileManager = [ProfileManager sharedInstance];
        filePath = [profileManager pathInFilesForCurrentProfileFromFileName:fileNameOnDisk temporary:NO];

        [[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent]
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];

        [data writeToFile:filePath atomically:YES];
    }

    CDUser *user = [chat.users anyObject];
    ToxFriend *friend = [[ToxManager sharedInstance].friendsContainer friendWithClientId:user.clientId];

    const char *cFileName = [originalFileName cStringUsingEncoding:NSUTF8StringEncoding];
    uint16_t cFileNameLength = [originalFileName lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

    int fileNumber = tox_new_file_sender(
            [ToxManager sharedInstance].tox,
            friend.id,
            fileSize,
            (const uint8_t *)cFileName,
            cFileNameLength);

    __weak ToxManagerFiles *weakSelf = self;

    NSString *key = [self keyFromFriendNumber:friend.id fileNumber:fileNumber downloading:NO];

    int portionSize = tox_file_data_size([ToxManager sharedInstance].tox, friend.id);

    @synchronized(self.uploadingFiles) {
        self.uploadingFiles[key] = [[ToxUploadingFile alloc] initWithFilePath:filePath portionSize:portionSize];
    }

    [[ToxManager sharedInstance].managerChats qUserFromClientId:[[ToxManager sharedInstance] qClientId]
                                                completionBlock:^(CDUser *currentUser)
    {
        [[ToxManager sharedInstance].managerChats qChatWithUser:user completionBlock:^(CDChat *chat) {
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
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManagerFiles: incoming file from friend id %d, filenumber %d", friend.id, fileNumber);

    __weak ToxManagerFiles *weakSelf = self;

    [[ToxManager sharedInstance].managerChats qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
        [[ToxManager sharedInstance].managerChats qChatWithUser:user completionBlock:^(CDChat *chat) {
            NSString *fileNameOnDisk = [weakSelf uniqueFileNameOnDiskWithExtension:[originalFileName pathExtension]];

            DDLogInfo(@"ToxManagerFiles: creating new document with fileNameOnDisk %@", fileNameOnDisk);

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
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManagerFiles: incoming file finished downloading from friend id %d, filenumber %d",
            friendNumber, fileNumber);

    NSString *key = [self keyFromFriendNumber:friendNumber
                                   fileNumber:fileNumber
                                  downloading:YES];

    @synchronized(self.downloadingFiles) {
        ToxDownloadingFile *file = self.downloadingFiles[key];
        [file finishDownloading];

        [self.downloadingFiles removeObjectForKey:key];
    }

    tox_file_send_control(
            [ToxManager sharedInstance].tox,
            friendNumber,
            1,
            fileNumber,
            TOX_FILECONTROL_FINISHED,
            NULL,
            0);

    NSPredicate *predicate = [NSPredicate predicateWithFormat:
        @"pendingFile.fileNumber == %d AND pendingFile.friendNumber == %d", fileNumber, friendNumber];

    [CoreDataManager messagesWithPredicate:predicate
                           completionQueue:[ToxManager sharedInstance].queue
                           completionBlock:^(NSArray *array)
    {
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
            DDLogError(@"ToxManagerFiles: cannot create directory at path %@ error %@",
                    [newPath stringByDeletingLastPathComponent], error);
            return;
        }

        [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];

        if (error) {
            DDLogError(@"ToxManagerFiles: cannot move file from path %@ to newPath %@ error %@", oldPath, newPath, error);
            return;
        }

        [CoreDataManager movePendingFileToFileForMessage:message
                                         completionQueue:nil
                                         completionBlock:nil];
    }];
}

- (void)qFileTransferAcceptedWithFriendNumber:(int32_t)friendNumber fileNumber:(uint8_t)fileNumber
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManagerFiles: friend accepted uploading file %d, starting upload", fileNumber);

    [self qChangeUploadingPendingFileStateTo:CDMessagePendingFileStateActive
                            withFriendNumber:friendNumber
                                  fileNumber:fileNumber];

    NSString *key = [self keyFromFriendNumber:friendNumber fileNumber:fileNumber downloading:NO];

    @synchronized(self.uploadingFiles) {
        ToxUploadingFile *file = self.uploadingFiles[key];
        file.paused = NO;
    }

    [self qUploadNextFileChunkWithFriendNumber:friendNumber fileNumber:fileNumber];
}

- (void)qUploadNextFileChunkWithFriendNumber:(int32_t)friendNumber fileNumber:(uint8_t)fileNumber
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    NSString *key = [self keyFromFriendNumber:friendNumber fileNumber:fileNumber downloading:NO];

    ToxUploadingFile *file;
    @synchronized(self.uploadingFiles) {
        file = self.uploadingFiles[key];
    }

    if (! file) {
        DDLogInfo(@"ToxManagerFiles: no file with key %@ found, quiting", key);
        return;
    }

    if (file.paused) {
        DDLogInfo(@"ToxManagerFiles: file for key %@ is paused, quiting", key);
        return;
    }

    uint8_t buffer[file.portionSize];

    BOOL (^checkLength)(uint16_t) = ^(uint16_t length) {
        if (! length) {
            tox_file_send_control(
                    [ToxManager sharedInstance].tox,
                    friendNumber,
                    0,
                    fileNumber,
                    TOX_FILECONTROL_FINISHED,
                    NULL,
                    0);

            DDLogInfo(@"ToxManagerFiles: file successfully sended with key %@", key);

            return NO;
        }

        return YES;
    };

    uint16_t length = [file nextPortionOfBytes:&buffer];
    if (! checkLength(length)) {
        return;
    }

    const uint32_t toxDoInterval = tox_do_interval([ToxManager sharedInstance].tox);
    NSDate *startDate = [NSDate date];

    while (tox_file_send_data([ToxManager sharedInstance].tox, friendNumber, fileNumber, buffer, length) == 0) {
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

        CGFloat progress = [self progressFromUploadingFile:file friendNumber:friendNumber fileNumber:fileNumber];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ToxManager sharedInstance].fileProgressDelegate toxManagerProgressChanged:progress
                                                           forPendingFileWithFileNumber:fileNumber
                                                                           friendNumber:friendNumber];
        });
    }

    file.numberOfFailuresInARow++;

    if (file.numberOfFailuresInARow > kToxUploadingFilesMaxNumberOfFailures) {
        DDLogWarn(@"ToxManagerFiles: too many failures in a row while uploading file %@, removing it",
                key);

        @synchronized(self.uploadingFiles) {
            [self.uploadingFiles removeObjectForKey:key];
        }
        [self qChangeUploadingPendingFileStateTo:CDMessagePendingFileStateCanceled
                                withFriendNumber:friendNumber
                                      fileNumber:fileNumber];

        return;
    }

    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, toxDoInterval * USEC_PER_SEC);

    dispatch_after(time, [ToxManager sharedInstance].queue, ^{
        [self qUploadNextFileChunkWithFriendNumber:friendNumber fileNumber:fileNumber];
    });
}

- (void)qFinishUploadingWithFriendNumber:(int32_t)friendNumber fileNumber:(uint8_t)fileNumber
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    NSString *key = [self keyFromFriendNumber:friendNumber fileNumber:fileNumber downloading:NO];

    ToxUploadingFile *file;
    @synchronized(self.uploadingFiles) {
        file = self.uploadingFiles[key];

        [file finishUploading];
        [self.uploadingFiles removeObjectForKey:key];
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:
        @"pendingFile.fileNumber == %d AND pendingFile.friendNumber == %d", fileNumber, friendNumber];

    [CoreDataManager messagesWithPredicate:predicate
                           completionQueue:[ToxManager sharedInstance].queue
                           completionBlock:^(NSArray *array)
    {
        if (! array.count) {
            return;
        }

        CDMessage *message = [array lastObject];

        [CoreDataManager movePendingFileToFileForMessage:message completionQueue:nil completionBlock:nil];
    }];
}

- (void)qUploadPausedWithFriendNumber:(uint32_t)friendNumber fileNumber:(uint16_t)fileNumber
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    [self qChangeUploadingPendingFileStateTo:CDMessagePendingFileStatePaused
                            withFriendNumber:friendNumber
                                  fileNumber:fileNumber];

    NSString *key = [self keyFromFriendNumber:friendNumber fileNumber:fileNumber downloading:NO];

    @synchronized(self.uploadingFiles) {
        ToxUploadingFile *file = self.uploadingFiles[key];
        file.paused = YES;
    }
}

- (void)qUploadKilledWithFriendNumber:(uint32_t)friendNumber fileNumber:(uint16_t)fileNumber
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    [self qChangeUploadingPendingFileStateTo:CDMessagePendingFileStateCanceled
                            withFriendNumber:friendNumber
                                  fileNumber:fileNumber];

    NSString *key = [self keyFromFriendNumber:friendNumber fileNumber:fileNumber downloading:NO];

    @synchronized(self.uploadingFiles) {
        [self.uploadingFiles removeObjectForKey:key];
    }
}

- (void)qChangeUploadingPendingFileStateTo:(CDMessagePendingFileState)state
                          withFriendNumber:(int32_t)friendNumber
                                fileNumber:(uint8_t)fileNumber
{
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    NSPredicate *predicate = [NSPredicate predicateWithFormat:
        @"pendingFile.fileNumber == %d AND pendingFile.friendNumber == %d", fileNumber, friendNumber];

    [CoreDataManager messagesWithPredicate:predicate
                           completionQueue:[ToxManager sharedInstance].queue
                           completionBlock:^(NSArray *array)
    {
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
    NSAssert([[ToxManager sharedInstance] isOnToxManagerQueue], @"Must be on ToxManager queue");

    DDLogInfo(@"ToxManagerFiles: adding pending file to CoreData");

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

    } completionQueue:[ToxManager sharedInstance].queue completionBlock:completionBlock];
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
    DDLogCVerbose(@"ToxManagerFiles: fileSendRequestCallback with friendnumber %d filenumber %d filesize %llu",
            friendnumber, filenumber, filesize);

    ToxFriend *friend = [[ToxManager sharedInstance].friendsContainer friendWithId:friendnumber];

    NSString *fileNameString = [[NSString alloc] initWithBytes:filename
                                                        length:filename_length
                                                      encoding:NSUTF8StringEncoding];

    dispatch_async([ToxManager sharedInstance].queue, ^{
        [[ToxManager sharedInstance].managerFiles qIncomingFileFromFriend:friend
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
    DDLogCVerbose(@"ToxManagerFiles: fileControlCallback with friendnumber %d filenumber %d receiveSend %d controlType %d",
            friendnumber, filenumber, receive_send, control_type);

    dispatch_async([ToxManager sharedInstance].queue, ^{
        if (receive_send == 0) {
            if (control_type == TOX_FILECONTROL_FINISHED) {
                [[ToxManager sharedInstance].managerFiles qIncomingFileFinishedDownloadingWithFriendNumber:friendnumber
                                                                                   fileNumber:filenumber];
            }
        }
        else if (receive_send == 1) {
            if (control_type == TOX_FILECONTROL_ACCEPT) {
                [[ToxManager sharedInstance].managerFiles qFileTransferAcceptedWithFriendNumber:friendnumber
                                                                                     fileNumber:filenumber];
            }
            else if (control_type == TOX_FILECONTROL_FINISHED) {
                [[ToxManager sharedInstance].managerFiles qFinishUploadingWithFriendNumber:friendnumber
                                                                                fileNumber:filenumber];
            }
            else if (control_type == TOX_FILECONTROL_PAUSE) {
                [[ToxManager sharedInstance].managerFiles qUploadPausedWithFriendNumber:friendnumber
                                                                             fileNumber:filenumber];
            }
            else if (control_type == TOX_FILECONTROL_KILL) {
                [[ToxManager sharedInstance].managerFiles qUploadKilledWithFriendNumber:friendnumber
                                                                             fileNumber:filenumber];
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
        NSString *key = [[ToxManager sharedInstance].managerFiles keyFromFriendNumber:friendnumber
                                                                           fileNumber:filenumber
                                                                          downloading:YES];
        ToxDownloadingFile *file;

        @synchronized([ToxManager sharedInstance].managerFiles.downloadingFiles) {
            file = [ToxManager sharedInstance].managerFiles.downloadingFiles[key];
        }

        if (! file) {
            return;
        }

        BOOL didSaveOnDisk;

        [file appendData:nsData didSavedOnDisk:&didSaveOnDisk];

        if (didSaveOnDisk) {
            CGFloat progress = [[ToxManager sharedInstance].managerFiles progressFromDownloadingFile:file
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

