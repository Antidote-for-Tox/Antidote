//
//  RingTonePlayer.m
//  Antidote
//
//  Created by Chuong Vu on 7/22/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "RingTonePlayer.h"

#import <AVFoundation/AVFoundation.h>

#define LOG_IDENTIFIER self

static NSString *const kRingToneFilePath = @"ringtone.wav";
static NSString *const kRingBackFilePath = @"ringback.wav";

@interface RingTonePlayer ()

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation RingTonePlayer

- (void)createAudioPlayerWithFile:(NSString *)filePath
{
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filePath];
    NSURL *soundURL = [NSURL fileURLWithPath:path];

    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];

    if (! self.audioPlayer) {
        AALogWarn(@"error:%@", error);
    }
    self.audioPlayer.numberOfLoops = -1;
}

#pragma mark - Public

- (void)playRingTone
{
    if (self.audioPlayer) {
        return;
    }

    [self createAudioPlayerWithFile:kRingToneFilePath];

    [self.audioPlayer play];
}

- (void)playRingBackTone
{
    if (self.audioPlayer) {
        return;
    }

    [self createAudioPlayerWithFile:kRingBackFilePath];

    [self.audioPlayer play];
}

- (void)stopPlayingSound
{
    if (! self.audioPlayer) {
        return;
    }

    [self.audioPlayer stop];
    self.audioPlayer = nil;
}

@end
