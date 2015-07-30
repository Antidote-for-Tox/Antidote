//
//  ActiveCallViewController.m
//  Antidote
//
//  Created by Chuong Vu on 7/2/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ActiveCallViewController.h"
#import "Masonry.h"
#import "NSString+Utilities.h"
#import "AppearanceManager.h"
#import "PauseCallTableViewCell.h"
#import "UITableViewCell+Utilities.h"
#import "IncomingCallNotificationView.h"
#import "AvatarsManager.h"
#import "CallControlsView.h"

static const CGFloat kIndent = 50.0;
static const CGFloat kButtonSide = 75.0;
static const CGFloat kEndCallButtonHeight = 45.0;
static const CGFloat kButtonBorderWidth = 1.5f;
static const CGFloat kTableViewBottomOffSet = 200.0;

static const CGFloat kBadgeContainerHorizontalOffset = 10.0;
static const CGFloat kBadgeHeightWidth = 30.0;
static const CGFloat kBadgeFontSize = 14.0;

static const CGFloat kAvatarDiameter = 180.0;

@interface ActiveCallViewController () <UITableViewDelegate,
                                        UITableViewDataSource,
                                        PauseCallTableViewCellDelegate,
                                        IncomingCallNotificationViewDelegate,
                                        CallControlsViewDelegate>

@property (strong, nonatomic) UIButton *endCallButton;
@property (strong, nonatomic) CallControlsView *callControlsView;

@property (strong, nonatomic) IncomingCallNotificationView *incomingCallNotification;
@property (strong, nonatomic) UIView *bottomIncomingCallSpacer;
@property (strong, nonatomic) UIView *topIncomingCallSpacer;

@property (strong, nonatomic) UIButton *callMenuButton;
@property (strong, nonatomic) UIView *badgeContainer;
@property (strong, nonatomic) UILabel *badgeLabel;

@property (strong, nonatomic) UIView *pauseCallsContainer;
@property (strong, nonatomic) UITableView *tableViewOfPausedCalls;
@property (strong, nonatomic) UIButton *tapOutsideTableViewButton;

@property (strong, nonatomic) NSTimer *tableViewRefreshTimer;

@property (strong, nonatomic) UIImageView *friendAvatar;
@end

@implementation ActiveCallViewController

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createEndCallButton];
    [self createCallControlsView];

    [self createCallMenuButton];
    [self createPauseCallContainer];
    [self createCallPauseTableView];
    [self createBadgeViews];

    [self installConstraints];

    self.resumeButtonHidden = YES;

    [self reloadPausedCalls];
}

#pragma mark - View setup

- (void)createEndCallButton
{
    self.endCallButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.endCallButton.backgroundColor = [[AppContext sharedContext].appearance callRedColor];
    [self.endCallButton addTarget:self action:@selector(endCallButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.endCallButton.layer.cornerRadius = kEndCallButtonHeight / 2.0f;

    UIImage *image = [UIImage imageNamed:@"call-decline"];
    [self.endCallButton setImage:image forState:UIControlStateNormal];
    self.endCallButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.endCallButton.layer.borderWidth = kButtonBorderWidth;
    self.endCallButton.tintColor = [UIColor whiteColor];

    [self.view addSubview:self.endCallButton];
}

- (void)createCallControlsView
{
    self.callControlsView = [CallControlsView new];
    self.callControlsView.delegate = self;
    [self.view addSubview:self.callControlsView];
}

- (void)createCallMenuButton
{
    UIImage *image = [UIImage imageNamed:@"call-menu"];
    self.callMenuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.callMenuButton setImage:image forState:UIControlStateNormal];
    self.callMenuButton.tintColor = [UIColor whiteColor];
    [self.callMenuButton addTarget:self action:@selector(callMenuButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    [self.topViewContainer addSubview:self.callMenuButton];
}

- (void)createPauseCallContainer
{
    self.pauseCallsContainer = [UIView new];
    self.pauseCallsContainer.backgroundColor = [UIColor clearColor];
    self.pauseCallsContainer.hidden = YES;

    [self.view addSubview:self.pauseCallsContainer];

    self.tapOutsideTableViewButton = [UIButton new];
    [self.tapOutsideTableViewButton addTarget:self
                                       action:@selector(hideTableViewOfPausedCalls)
                             forControlEvents:UIControlEventTouchUpInside];

    [self.pauseCallsContainer addSubview:self.tapOutsideTableViewButton];
}

- (void)createCallPauseTableView
{
    self.tableViewOfPausedCalls = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableViewOfPausedCalls.backgroundColor = [UIColor blackColor];
    self.tableViewOfPausedCalls.delegate = self;
    self.tableViewOfPausedCalls.dataSource = self;
    self.tableViewOfPausedCalls.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableViewOfPausedCalls registerClass:[PauseCallTableViewCell class] forCellReuseIdentifier:[PauseCallTableViewCell reuseIdentifier]];

    [self.pauseCallsContainer addSubview:self.tableViewOfPausedCalls];
}

- (void)createBadgeViews
{
    self.badgeContainer = [UIView new];
    self.badgeContainer.backgroundColor = [[AppContext sharedContext].appearance callRedColor];
    self.badgeContainer.layer.masksToBounds = YES;
    self.badgeContainer.layer.cornerRadius = kBadgeHeightWidth / 2.0;
    [self.callMenuButton addSubview:self.badgeContainer];

    self.badgeLabel = [UILabel new];
    self.badgeLabel.textColor = [UIColor whiteColor];
    self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    self.badgeLabel.backgroundColor = [UIColor clearColor];
    self.badgeLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:kBadgeFontSize];
    [self.topViewContainer addSubview:self.badgeLabel];

    NSInteger numberOfPausedCalls = [self.dataSource activeCallControllerNumberOfPausedCalls:self];
    self.badgeLabel.text = [NSString stringWithFormat:@"%lu", numberOfPausedCalls];
}

- (void)createFriendAvatar
{
    AvatarsManager *avatars = [AppContext sharedContext].avatars;

    UIImage *image = [avatars avatarFromString:self.nickname
                                      diameter:kAvatarDiameter
                                     textColor:[UIColor whiteColor]
                               backgroundColor:[UIColor clearColor]];

    self.friendAvatar = [[UIImageView alloc] initWithImage:image];

    [self.view addSubview:self.friendAvatar];

    [self.friendAvatar makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}


- (void)installConstraints
{
    [super installConstraints];

    [self.endCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(-kIndent);
        make.left.equalTo(self.view).with.offset(kIndent);
        make.right.equalTo(self.view).with.offset(-kIndent);
        make.height.equalTo(kEndCallButtonHeight);
    }];

    [self.callControlsView makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];

    [self.callMenuButton makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(kButtonSide);
        make.right.equalTo(self.topViewContainer);
        make.top.equalTo(self.topViewContainer);
    }];

    [self.pauseCallsContainer makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topViewContainer.bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];

    [self.tableViewOfPausedCalls makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pauseCallsContainer);
        make.left.equalTo(self.pauseCallsContainer);
        make.right.equalTo(self.pauseCallsContainer);
        make.bottom.equalTo(self.pauseCallsContainer).with.offset(-kTableViewBottomOffSet);
    }];

    [self.tapOutsideTableViewButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableViewOfPausedCalls);
        make.left.equalTo(self.pauseCallsContainer);
        make.right.equalTo(self.pauseCallsContainer);
        make.bottom.equalTo(self.pauseCallsContainer);
    }];


    [self.badgeContainer makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.callMenuButton.centerY);
        make.centerX.equalTo(self.callMenuButton.right).with.offset(-kBadgeContainerHorizontalOffset);
        make.size.equalTo(kBadgeHeightWidth);
    }];

    [self.badgeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.badgeContainer);
        make.centerY.equalTo(self.badgeContainer);
    }];
}

#pragma mark - Public

- (void)setCallDuration:(NSTimeInterval)callDuration
{
    _callDuration = callDuration;
    [self updateTimerLabel];
}

- (void)setMicSelected:(BOOL)micSelected
{
    self.callControlsView.micSelected = micSelected;
}

- (BOOL)micSelected
{
    return self.callControlsView.micSelected;
}

- (void)setSpeakerSelected:(BOOL)speakerSelected
{
    self.callControlsView.speakerSelected = speakerSelected;
}

- (BOOL)speakerSelected
{
    return self.callControlsView.speakerSelected;
}

- (void)createIncomingCallViewForFriend:(NSString *)nickname
{
    if (self.incomingCallNotification) {
        return;
    }

    [self setupIncomingCallViewForFriend:nickname];
}

- (void)setResumeButtonHidden:(BOOL)resumeButtonHidden
{
    if (self.callControlsView.resumeButtonHidden == resumeButtonHidden) {
        return;
    }

    self.callControlsView.resumeButtonHidden = resumeButtonHidden;
}

- (void)hideIncomingCallView
{
    [self.incomingCallNotification removeFromSuperview];
    self.incomingCallNotification = nil;

    [self.topIncomingCallSpacer removeFromSuperview];
    self.topIncomingCallSpacer = nil;
    [self.bottomIncomingCallSpacer removeFromSuperview];
    self.bottomIncomingCallSpacer = nil;
}

- (void)reloadPausedCalls
{
    NSInteger numberOfPausedCalls = [self.dataSource activeCallControllerNumberOfPausedCalls:self];

    self.badgeLabel.text = [NSString stringWithFormat:@"%lu", [self.dataSource activeCallControllerNumberOfPausedCalls:self]];


    self.badgeLabel.hidden = (numberOfPausedCalls == 0);
    self.callMenuButton.hidden = (numberOfPausedCalls == 0);

    if (numberOfPausedCalls == 0) {
        [self hideTableViewOfPausedCalls];
    }

    [self.tableViewOfPausedCalls reloadData];
}

- (void)showCallPausedByFriend
{
    if (self.friendAvatar) {
        return;
    }

    self.subLabel.text = NSLocalizedString(@"is holding the call", @"Calls");
    self.callControlsView.hidden = YES;
    [self createFriendAvatar];
}

#pragma mark - Private

- (void)updateTimerLabel
{
    self.subLabel.text = [NSString stringFromTimeInterval:self.callDuration];

    [self.subLabel setNeedsDisplay];

    [self hideCallPausedByFriendIfNeeded];
}

- (void)setupIncomingCallViewForFriend:(NSString *)nickname
{
    self.incomingCallNotification = [[IncomingCallNotificationView alloc] initWithNickname:nickname];
    self.incomingCallNotification.delegate = self;
    [self.view addSubview:self.incomingCallNotification];

    self.topIncomingCallSpacer = [UIView new];
    self.topIncomingCallSpacer.backgroundColor = [UIColor clearColor];
    self.bottomIncomingCallSpacer = [UIView new];
    self.bottomIncomingCallSpacer.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.topIncomingCallSpacer];
    [self.view addSubview:self.bottomIncomingCallSpacer];

    [self.incomingCallNotification makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(kButtonSide);
        make.bottom.equalTo(self.bottomIncomingCallSpacer.top);
        make.top.equalTo(self.topIncomingCallSpacer.bottom);
    }];

    [self.topIncomingCallSpacer makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.bottomIncomingCallSpacer);
        make.top.equalTo(self.callControlsView.bottom);
    }];

    [self.bottomIncomingCallSpacer makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.bottomIncomingCallSpacer);
        make.bottom.equalTo(self.endCallButton.top);
    }];
}

- (void)showTableViewOfPausedCalls
{
    if (! self.pauseCallsContainer.hidden) {
        return;
    }

    self.pauseCallsContainer.hidden = NO;
    self.tableViewRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                  target:self
                                                                selector:@selector(reloadPausedCalls)
                                                                userInfo:nil
                                                                 repeats:YES];
}

- (void)hideTableViewOfPausedCalls
{
    self.pauseCallsContainer.hidden = YES;

    [self.tableViewRefreshTimer invalidate];
    self.tableViewRefreshTimer = nil;
}

- (void)hideCallPausedByFriendIfNeeded
{
    if (! self.friendAvatar) {
        return;
    }

    [self.friendAvatar removeFromSuperview];
    self.friendAvatar = nil;

    self.callControlsView.hidden = NO;
}

#pragma mark - Call Menu

- (void)callMenuButtonPressed
{
    BOOL wasHidden = self.pauseCallsContainer.hidden;

    wasHidden ? [self showTableViewOfPausedCalls] : [self hideTableViewOfPausedCalls];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.dataSource activeCallController:self resumePausedCallSelectedAtIndex:indexPath];
    [self hideTableViewOfPausedCalls];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PauseCallTableViewCell *cell = [self.tableViewOfPausedCalls dequeueReusableCellWithIdentifier:[PauseCallTableViewCell reuseIdentifier]];

    NSString *nickName = [self.dataSource activeCallController:self
                            pausedCallerNicknameForCallAtIndex             :indexPath];

    NSDate *callPauseDate = [self.dataSource activeCallController:self
                                          pauseDateForCallAtIndex  :indexPath];

    NSTimeInterval holdDuration = [[NSDate date] timeIntervalSinceDate:callPauseDate];

    [cell setCallerNickname:nickName andOnHoldDuration:holdDuration];
    cell.delegate = self;

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfPausedCalls = [self.dataSource activeCallControllerNumberOfPausedCalls:self];

    return numberOfPausedCalls;
}

#pragma mark - PauseCallTableViewCellDelegate

- (void)pauseCallCellEndPausedCallButtonTapped:(PauseCallTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableViewOfPausedCalls indexPathForCell:cell];

    [self.dataSource activeCallController:self endPausedCallSelectedAtIndex:indexPath];
}

#pragma mark - IncomingCallNotificationViewDelegate

- (void)incomingCallNotificationViewTappedAcceptButton
{
    [self.delegate activeCallAnswerIncomingCallButtonPressed:self];
}

- (void)incomingCallNotificationViewTappedDeclineButton
{
    [self.delegate activeCallDeclineIncomingCallButtonPressed:self];
}

#pragma mark - Call controls pressed

- (void)endCallButtonPressed
{
    [self.delegate activeCallDeclineButtonPressed:self];
}

#pragma mark - CallControlsViewDelegate

- (void)callControlsMicButtonPressed:(CallControlsView *)callsControlView
{
    [self.delegate activeCallMicButtonPressed:self];
}

- (void)callControlsSpeakerButtonPressed:(CallControlsView *)callsControlView
{
    [self.delegate activeCallSpeakerButtonPressed:self];
}

- (void)callControlsResumeButtonPressed:(CallControlsView *)callsControlView
{
    [self.delegate activeCallResumeButtonPressed:self];
}

@end
