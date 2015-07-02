//
//  DialingCallViewController.m
//  Antidote
//
//  Created by Chuong Vu on 7/1/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "DialingCallViewController.h"
#import "Masonry.h"
#import "Helper.h"
#import "OCTCall.h"
#import "OCTChat.h"
#import "OCTSubmanagerCalls.h"

static const CGFloat kIndent = 50.0;

@interface DialingCallViewController () <RBQFetchedResultsControllerDelegate>

@property (strong, nonatomic) OCTSubmanagerCalls *manager;
@property (strong, nonatomic) OCTCall *call;
@property (strong, nonatomic) RBQFetchedResultsController *callController;

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *cancelCallButton;
@property (strong, nonatomic) UILabel *timerLabel;

@end

@implementation DialingCallViewController

#pragma mark - Life cycle

- (instancetype)initWithChat:(OCTChat *)chat submanagerCalls:(OCTSubmanagerCalls *)manager
{
    self = [super init];
    if (! self) {
        return nil;
    }

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chat == %@", chat];
    _callController = [Helper createFetchedResultsControllerForType:OCTFetchRequestTypeCall predicate:predicate delegate:self];
    _callController.delegate = self;

    _call = [[_callController fetchedObjects] firstObject];

    if (! _call) {
        return nil;
    }

    _manager = manager;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.opaque = YES;

    self.view.backgroundColor = [UIColor clearColor];

    [self setupBlurredView];
    [self createNameLabel];

    [self createEndCallButton];
    [self createCallTimer];

    [self installConstraints];
}

#pragma mark -  RBQFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(RBQFetchedResultsController *)controller
{
    self.call = [[self.callController fetchedObjects] firstObject];

    [self updateTimerLabel];
}
#pragma mark - Private

- (void)setupBlurredView
{
    UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
    darkView.backgroundColor = [UIColor blackColor];
    darkView.alpha = 0.5;

    [self.view addSubview:darkView];

    [darkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];

    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.view.bounds;

    [self.view addSubview:visualEffectView];
    [visualEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)createNameLabel
{
    if (self.call.chat.friends.count == 1) {
        OCTFriend *friend = self.call.chat.friends.firstObject;

        self.nameLabel = [UILabel new];
        self.nameLabel.text = friend.nickname;
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.nameLabel sizeToFit];

        [self.view addSubview:self.nameLabel];
    }
}
- (void)createEndCallButton
{
    self.cancelCallButton = [UIButton new];
    self.cancelCallButton.backgroundColor = [UIColor redColor];
    [self.cancelCallButton setImage:[UIImage imageWithContentsOfFile:@"phone"] forState:UIControlStateNormal];
    [self.cancelCallButton addTarget:self action:@selector(endCall) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.cancelCallButton];
}

- (void)createCallTimer
{
    self.timerLabel = [UILabel new];
    self.timerLabel.textColor = [UIColor whiteColor];
    self.timerLabel.textAlignment = NSTextAlignmentCenter;

    [self.view addSubview:self.timerLabel];
}

- (void)installConstraints
{
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(kIndent);
        make.left.equalTo(self.view.mas_left).with.offset(kIndent);
        make.right.equalTo(self.view.mas_right).with.offset(-kIndent);
        make.height.equalTo(30);
    }];

    [self.cancelCallButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-kIndent);
        make.centerX.equalTo(self.view.mas_centerX);
        make.left.equalTo(self.view.mas_left).with.offset(kIndent);
        make.right.equalTo(self.view.mas_right).with.offset(-kIndent);
    }];

    [self.timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(kIndent);
        make.left.equalTo(self.nameLabel.mas_left);
        make.right.equalTo(self.nameLabel.mas_right);
        make.centerX.equalTo(self.nameLabel.centerX);
    }];
}

- (void)updateTimerLabel
{
    self.timerLabel.text = [self stringFromTimeInterval:self.call.callDuration];
    [self.timerLabel setNeedsDisplay];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval
{
    int minutes = (int)interval / 60;
    int seconds = interval - (minutes * 60);

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;



    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (void)endCall
{
    // do animation stuff
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
