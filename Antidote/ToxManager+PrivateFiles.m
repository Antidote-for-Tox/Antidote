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

#pragma mark -  Private

- (void)qIncomingFileWithName:(NSString *)name
                   fromFriend:(ToxFriend *)friend
                   fileNumber:(uint8_t)filenumber
                     fileSize:(uint64_t)filesize
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    __weak ToxManager *weakSelf = self;

    [self qUserFromClientId:friend.clientId completionBlock:^(CDUser *user) {
        [weakSelf qChatWithUser:user completionBlock:^(CDChat *chat) {
            [weakSelf qAddFileWithPathFileName:nil
                                          name:name
                                 isFullyLoaded:NO
                                        toChat:chat
                                      fromUser:user
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

- (void)qAddFileWithPathFileName:(NSString *)pathFileName
                            name:(NSString *)name
                   isFullyLoaded:(BOOL)isFullyLoaded
                          toChat:(CDChat *)chat
                        fromUser:(CDUser *)user
                 completionBlock:(void (^)(CDMessage *message))completionBlock
{
    NSAssert(dispatch_get_specific(kIsOnToxManagerQueue), @"Must be on ToxManager queue");

    [CoreDataManager insertMessageWithType:CDMessageTypeFile configBlock:^(CDMessage *m) {
        m.file.name = name;
        m.file.pathFileName = pathFileName;
        m.file.isFullyLoaded = isFullyLoaded;
        m.date = [[NSDate date] timeIntervalSince1970];
        m.user = user;
        m.chat = chat;

        if (m.date > chat.lastMessage.date) {
            m.chatForLastMessageInverse = chat;
        }

    } completionQueue:self.queue completionBlock:completionBlock];
}

@end

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

    NSString *nameString = [[NSString alloc] initWithBytes:filename
                                                    length:filename_length
                                                  encoding:NSUTF8StringEncoding];

    [[ToxManager sharedInstance] qIncomingFileWithName:nameString
                                            fromFriend:friend
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

