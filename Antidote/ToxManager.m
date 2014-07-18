//
//  ToxManager.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 18.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxManager.h"
#import "tox.h"

uint8_t *hex_string_to_bin(char *hex_string);
void friendRequestCallback(Tox *tox, const uint8_t * public_key, const uint8_t * data, uint16_t length, void *userdata);
void friendMessageCallback(Tox *tox, int32_t friendnumber, const uint8_t *message, uint16_t length, void *userdata);
void nameChangeCallback(Tox *tox, int32_t friendnumber, const uint8_t *newname, uint16_t length, void *userdata);
void statusMessageCallback(Tox *tox, int32_t friendnumber, const uint8_t *newstatus, uint16_t length, void *userdata);
void userStatusCallback(Tox *tox, int32_t friendnumber, uint8_t status, void *userdata);
void typingChangeCallback(Tox *tox, int32_t friendnumber, uint8_t isTyping, void *userdata);
void readReceiptCallback(Tox *tox, int32_t friendnumber, uint32_t receipt, void *userdata);
void connectionStatusCallback(Tox *tox, int32_t friendnumber, uint8_t status, void *userdata);

@interface ToxManager()

@property (assign, nonatomic, readonly) Tox *tox;

@property (strong, nonatomic, readonly) dispatch_queue_t queue;

@property (strong, nonatomic) dispatch_source_t timer;
@property (assign, nonatomic) uint32_t timerMillisecondsUpdateInterval;

@property (assign, nonatomic) BOOL isConnected;

@end


@implementation ToxManager

#pragma mark -  Lifecycle

- (id)init
{
    return nil;
}

- (id)initPrivate
{
    self = [super init];

    if (self) {
        _tox = tox_new(TOX_ENABLE_IPV6_DEFAULT);

        _queue = dispatch_queue_create("ToxManager queue", NULL);

        tox_callback_friend_request(_tox, friendRequestCallback, NULL);
        tox_callback_friend_message(_tox, friendMessageCallback, NULL);
        tox_callback_name_change(_tox, nameChangeCallback, NULL);
        tox_callback_status_message(_tox, statusMessageCallback, NULL);
        tox_callback_user_status(_tox, userStatusCallback, NULL);
        tox_callback_typing_change(_tox, typingChangeCallback, NULL);
        tox_callback_read_receipt(_tox, readReceiptCallback, NULL);
        tox_callback_connection_status(_tox, connectionStatusCallback, NULL);
    }

    return self;
}

- (void)dealloc
{
    tox_kill(_tox);

    dispatch_source_cancel(self.timer);
    self.timer = nil;
}

+ (instancetype)sharedInstance
{
    static ToxManager *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[ToxManager alloc] initPrivate];
    });

    return instance;
}

#pragma mark -  Public

- (void)bootstrapWithAddress:(NSString *)address port:(NSUInteger)port publicKey:(NSString *)publicKey
{
    uint8_t *pub_key = hex_string_to_bin((char *)publicKey.UTF8String);
    tox_bootstrap_from_address(self.tox, address.UTF8String, 1, htons(port), pub_key);
    free(pub_key);

    [self maybeStartTimer];
}

#pragma mark -  Private

- (void)maybeStartTimer
{
    if (self.timer) {
        return;
    }

    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);

    [self updateTimerInterval:tox_do_interval(self.tox)];

    __weak ToxManager *weakSelf = self;

    dispatch_source_set_event_handler(self.timer, ^{
        tox_do(weakSelf.tox);

        int isConnected = tox_isconnected(weakSelf.tox);

        if (isConnected != weakSelf.isConnected) {
            weakSelf.isConnected = isConnected;
            NSLog(@"Connected changed to %d", isConnected);
        }

        uint32_t newInterval = tox_do_interval(weakSelf.tox);

        if (newInterval != weakSelf.timerMillisecondsUpdateInterval) {
            [weakSelf updateTimerInterval:newInterval];
        }
    });
    dispatch_resume(self.timer);
}

- (void)updateTimerInterval:(uint32_t)newInterval
{
    self.timerMillisecondsUpdateInterval = newInterval;

    uint64_t actualInterval = newInterval * (NSEC_PER_SEC / 1000);

    dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), actualInterval, actualInterval / 5);
}

@end

#pragma mark -  C functions

// From toxcore/testing/misc_tools.c
// You are responsible for freeing the return value!
uint8_t *hex_string_to_bin(char *hex_string)
{
    // byte is represented by exactly 2 hex digits, so lenth of binary string
    // is half of that of the hex one. only hex string with even length
    // valid. the more proper implementation would be to check if strlen(hex_string)
    // is odd and return error code if it is. we assume strlen is even. if it's not
    // then the last byte just won't be written in 'ret'.
    size_t i, len = strlen(hex_string) / 2;
    uint8_t *ret = malloc(len);
    char *pos = hex_string;

    for (i = 0; i < len; ++i, pos += 2)
        sscanf(pos, "%2hhx", &ret[i]);

    return ret;
}

void friendRequestCallback(Tox *tox, const uint8_t * publicKey, const uint8_t * data, uint16_t length, void *userdata)
{
    NSLog(@"friendRequestCallback, publicKey %s", publicKey);
}

void friendMessageCallback(Tox *tox, int32_t friendnumber, const uint8_t *message, uint16_t length, void *userdata)
{
    NSLog(@"friendMessageCallback %d %s", friendnumber, message);
}

void nameChangeCallback(Tox *tox, int32_t friendnumber, const uint8_t *newname, uint16_t length, void *userdata)
{
    NSLog(@"nameChangeCallback %d %s", friendnumber, newname);
}

void statusMessageCallback(Tox *tox, int32_t friendnumber, const uint8_t *newstatus, uint16_t length, void *userdata)
{
    NSLog(@"statusMessageCallback %d %s", friendnumber, newstatus);
}

void userStatusCallback(Tox *tox, int32_t friendnumber, uint8_t status, void *userdata)
{
    NSLog(@"userStatusCallback %d %d", friendnumber, status);
}

void typingChangeCallback(Tox *tox, int32_t friendnumber, uint8_t isTyping, void *userdata)
{
    NSLog(@"typingChangeCallback %d %d", friendnumber, isTyping);
}

void readReceiptCallback(Tox *tox, int32_t friendnumber, uint32_t receipt, void *userdata)
{
    NSLog(@"readReceiptCallback %d %d", friendnumber, receipt);
}

void connectionStatusCallback(Tox *tox, int32_t friendnumber, uint8_t status, void *userdata)
{
    NSLog(@"connectionStatusCallback %d %d", friendnumber, status);
}

