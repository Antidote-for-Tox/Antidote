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
#import "ExpandedControlsView.h"
#import "CompactControlsView.h"
#import "VideoAndPreviewView.h"

static const CGFloat kIndent = 50.0;
static const CGFloat kCompactLandScapeHorizontalIndent = 100.0;
static const CGFloat kButtonSide = 75.0;
static const CGFloat kTableViewBottomOffSet = 200.0;

static const CGFloat kBadgeContainerHorizontalOffset = 10.0;
static const CGFloat kBadgeHeightWidth = 30.0;
static const CGFloat kBadgeFontSize = 14.0;

static const CGFloat kAvatarDiameter = 180.0;

@interface ActiveCallViewController () <UITableViewDelegate,
                                        UITableViewDataSource,
                                        PauseCallTableViewCellDelegate,
                                        IncomingCallNotificationViewDelegate,
                                        CallControlsViewDelegate,
                                        VideoAndPreviewViewDelegate>

@property (strong, nonatomic) ExpandedControlsView *expandedControlsView;
@property (strong, nonatomic) CompactControlsView *compactControlsView;

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
@property (strong, nonatomic) VideoAndPreviewView *videoContainerView;

@end

@implementation ActiveCallViewController

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createVideoContainerView];
    [self createExpandedCallControlsView];
    [self createCompactCallControlsView];

    [self createCallMenuButton];
    [self createPauseCallContainer];
    [self createCallPauseTableView];
    [self createBadgeViews];

    [self installConstraints];

    self.resumeButtonHidden = YES;

    [self reloadPausedCalls];
}

#pragma mark - View setup

- (void)createExpandedCallControlsView
{
    self.expandedControlsView = [ExpandedControlsView new];
    self.expandedControlsView.delegate = self;

    [self.view addSubview:self.expandedControlsView];
}

- (void)createCompactCallControlsView
{
    self.compactControlsView = [CompactControlsView new];
    self.compactControlsView.delegate = self;
    self.compactControlsView.hidden = YES;

    [self.view addSubview:self.compactControlsView];
}

- (void)createVideoContainerView
{
    self.videoContainerView = [VideoAndPreviewView new];
    self.videoContainerView.hidden = YES;
    self.videoContainerView.delegate = self;

    [self.view insertSubview:self.videoContainerView belowSubview:self.topViewContainer];
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

    [self.expandedControlsView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topViewContainer.bottom).with.offset(kIndent);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];

    [self.compactControlsView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];

    [self.videoContainerView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateUIForInterfaceOrientation:toInterfaceOrientation];

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)updateUIForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {

        [self.compactControlsView updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
        }];

        self.compactControlsView.hidden = YES;
        self.expandedControlsView.hidden = [self videoViewIsShown];
    }
    else {
        [self.compactControlsView updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).with.offset(-kCompactLandScapeHorizontalIndent);
            make.left.equalTo(self.view).with.offset(kCompactLandScapeHorizontalIndent);
        }];

        self.compactControlsView.hidden = NO;
        self.expandedControlsView.hidden = YES;
    }
}
#pragma mark - Public

- (void)setCallDuration:(NSTimeInterval)callDuration
{
    _callDuration = callDuration;
    [self updateTimerLabel];
}

- (void)setMicSelected:(BOOL)micSelected
{
    self.expandedControlsView.micSelected = micSelected;
    self.compactControlsView.micSelected = micSelected;
}

- (BOOL)micSelected
{
    return self.expandedControlsView.micSelected;
}

- (void)setSpeakerSelected:(BOOL)speakerSelected
{
    self.expandedControlsView.speakerSelected = speakerSelected;
    self.compactControlsView.speakerSelected = speakerSelected;
}

- (BOOL)speakerSelected
{
    return self.expandedControlsView.speakerSelected;
}

- (void)setVideoButtonSelected:(BOOL)videoButtonSelected
{
    self.compactControlsView.videoButtonSelected = videoButtonSelected;
}

- (BOOL)videoButtonSelected
{
    return self.compactControlsView.videoButtonSelected;
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
    if (self.expandedControlsView.resumeButtonHidden == resumeButtonHidden) {
        return;
    }

    self.expandedControlsView.resumeButtonHidden = resumeButtonHidden;
}

- (BOOL)videoViewIsShown
{
    return (self.videoContainerView.videoView != nil);
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
    self.expandedControlsView.hidden = YES;
    [self createFriendAvatar];
}

- (void)provideVideoView:(UIView *)view
{
    self.videoContainerView.videoView = view;

    [self switchToVideoViewIfNeeded];
}

- (void)providePreviewLayer:(CALayer *)layer
{
    self.videoContainerView.previewLayer = layer;

    [self switchToVideoViewIfNeeded];
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
        make.top.equalTo(self.view.centerY);
    }];

    [self.bottomIncomingCallSpacer makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.bottomIncomingCallSpacer);
        make.bottom.equalTo(self.compactControlsView.top);
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

    self.expandedControlsView.hidden = NO;
}

- (void)switchToVideoViewIfNeeded
{
    BOOL videoVisible = (self.videoContainerView.videoView || self.previewViewIsShown);

    self.videoContainerView.hidden = ! videoVisible;
    self.expandedControlsView.hidden = videoVisible;
    self.compactControlsView.hidden = ! videoVisible;
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

- (void)callControlsMicButtonPressed:(ExpandedControlsView *)callsControlView
{
    [self.delegate activeCallMicButtonPressed:self];
}

- (void)callControlsSpeakerButtonPressed:(ExpandedControlsView *)callsControlView
{
    [self.delegate activeCallSpeakerButtonPressed:self];
}

- (void)callControlsResumeButtonPressed:(ExpandedControlsView *)callsControlView
{
    [self.delegate activeCallResumeButtonPressed:self];
}

- (void)callControlsVideoButtonPressed:(ExpandedControlsView *)callsControlView
{
    [self.delegate activeCallVideoButtonPressed:self];
}

- (void)callControlsEndCallButtonPressed:(ExpandedControlsView *)callsControlView
{
    [self.delegate activeCallDeclineButtonPressed:self];
}

#pragma mark - VideoAndPreviewViewDelegate

- (void)videoAndPreviewViewTapped:(VideoAndPreviewView *)videoView
{
    BOOL hidden = (self.topViewContainer.alpha == 1.0);

    CGFloat newAlpha = (self.topViewContainer.alpha == 0.0) ? 1.0 : 0.0;

    if (newAlpha == 1.0) {
        self.topViewContainer.hidden = NO;
        self.compactControlsView.hidden = NO;
    }

    [UIView animateWithDuration:1.0
                     animations:^{
        self.topViewContainer.alpha = newAlpha;
        self.compactControlsView.alpha = newAlpha;
    } completion:^(BOOL finished) {
        self.topViewContainer.hidden = hidden;
        self.compactControlsView.hidden = hidden;
    }];
}
@end
