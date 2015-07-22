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

static const CGFloat kIndent = 50.0;
static const CGFloat kButtonSide = 75.0;
static const CGFloat kEndCallButtonHeight = 45.0;
static const CGFloat kButtonBorderWidth = 1.5f;
static const CGFloat k3ButtonGap = 15.0;
static const CGFloat kOtherCallButtonSize = 4.0 / 5.0 * kButtonSide;
static const CGFloat kIncomingNameFontSize = 12.0;
static const CGFloat kIncomingIsCallingFontSize = 10.0;
static const CGFloat kTableViewBottomOffSet = 200.0;

static const CGFloat kBadgeContainerHorizontalOffset = 10.0;
static const CGFloat kBadgeHeightWidth = 30.0;
static const CGFloat kBadgeFontSize = 14.0;

@interface ActiveCallViewController () <UITableViewDelegate, UITableViewDataSource, PauseCallTableViewCellDelegate>

@property (strong, nonatomic) UIButton *endCallButton;
@property (strong, nonatomic) UIButton *videoButton;
@property (strong, nonatomic) UIView *controlsContainerView;
@property (strong, nonatomic) UIButton *microphoneButton;
@property (strong, nonatomic) UIButton *speakerButton;
@property (strong, nonatomic) UIButton *pauseButton;

@property (strong, nonatomic) UIView *incomingCallContainer;
@property (strong, nonatomic) UIView *bottomIncomingCallSpacer;
@property (strong, nonatomic) UIView *topIncomingCallSpacer;

@property (strong, nonatomic) UIButton *callMenuButton;
@property (strong, nonatomic) UIView *badgeContainer;
@property (strong, nonatomic) UILabel *badgeLabel;
@property (strong, nonatomic) UITableView *tableViewOfPausedCalls;

@property (strong, nonatomic) NSTimer *tableViewRefreshTimer;

@end

@implementation ActiveCallViewController

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createEndCallButton];
    [self createContainerView];
    [self createVideoButton];
    [self createMicrophoneButton];
    [self createMuteButton];
    [self createPauseButton];
    [self createCallMenuButton];
    [self createCallPauseTableView];
    [self createBadgeViews];

    [self installConstraints];

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

- (void)createContainerView
{
    self.controlsContainerView = [UIView new];
    [self.view addSubview:self.controlsContainerView];
}

- (void)createVideoButton
{
    self.videoButton = [self createButtonWithImageName:@"call-video" action:nil];
    [self.controlsContainerView addSubview:self.videoButton];
}

- (void)createMicrophoneButton
{
    self.microphoneButton = [self createButtonWithImageName:@"call-microphone-enable" action:@selector(micButtonPressed)];

    UIImage *selectedImage = [UIImage imageNamed:@"call-microphone-disable"];
    [self.microphoneButton setImage:selectedImage forState:UIControlStateSelected];

    [self.controlsContainerView addSubview:self.microphoneButton];
}

- (void)createMuteButton
{
    self.speakerButton = [self createButtonWithImageName:@"call-audio-enable" action:@selector(speakerButtonPressed)];

    UIImage *selectedImage = [UIImage imageNamed:@"call-audio-disable"];
    [self.speakerButton setImage:selectedImage forState:UIControlStateSelected];

    [self.controlsContainerView addSubview:self.speakerButton];
}

- (void)createPauseButton
{
    self.pauseButton = [self createButtonWithImageName:@"call-play" action:@selector(pauseButtonPressed)];

    UIImage *selectedImage = [UIImage imageNamed:@"call-pause"];
    [self.pauseButton setImage:selectedImage forState:UIControlStateSelected];

    [self.controlsContainerView addSubview:self.pauseButton];
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

- (void)createCallPauseTableView
{
    self.tableViewOfPausedCalls = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableViewOfPausedCalls.backgroundColor = [UIColor blackColor];
    self.tableViewOfPausedCalls.delegate = self;
    self.tableViewOfPausedCalls.dataSource = self;
    self.tableViewOfPausedCalls.hidden = YES;
    self.tableViewOfPausedCalls.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableViewOfPausedCalls registerClass:[PauseCallTableViewCell class] forCellReuseIdentifier:[PauseCallTableViewCell reuseIdentifier]];

    [self.view addSubview:self.tableViewOfPausedCalls];
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
- (void)installConstraints
{
    [super installConstraints];

    [self.endCallButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.bottom).with.offset(-kIndent);
        make.left.equalTo(self.view.left).with.offset(kIndent);
        make.right.equalTo(self.view.right).with.offset(-kIndent);
        make.height.equalTo(kEndCallButtonHeight);
    }];

    [self.controlsContainerView makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.centerX.equalTo(self.view);
        make.height.equalTo(kButtonSide * 3 + 2 * k3ButtonGap);
    }];

    [self.videoButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.controlsContainerView);
        make.centerX.equalTo(self.controlsContainerView);
        make.width.equalTo(kButtonSide);
        make.height.equalTo(kButtonSide);
    }];

    [self.microphoneButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.controlsContainerView.left);
        make.right.equalTo(self.speakerButton.left).with.offset(-k3ButtonGap);
        make.width.equalTo(kButtonSide);
        make.height.equalTo(kButtonSide);
        make.centerY.equalTo(self.controlsContainerView);
    }];

    [self.speakerButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.controlsContainerView.right);
        make.width.equalTo(kButtonSide);
        make.height.equalTo(kButtonSide);
        make.centerY.equalTo(self.controlsContainerView);
    }];

    [self.pauseButton makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.controlsContainerView);
        make.width.equalTo(kButtonSide);
        make.height.equalTo(kButtonSide);
        make.centerX.equalTo(self.controlsContainerView);
    }];

    [self.callMenuButton makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(kButtonSide);
        make.height.equalTo(kButtonSide);
        make.right.equalTo(self.topViewContainer.rightMargin);
        make.top.equalTo(self.topViewContainer.topMargin);
    }];

    [self.tableViewOfPausedCalls makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topViewContainer.bottom);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view.bottom).with.offset(-kTableViewBottomOffSet);
    }];

    [self.badgeContainer makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.callMenuButton.centerY);
        make.centerX.equalTo(self.callMenuButton.right).with.offset(-kBadgeContainerHorizontalOffset);
        make.width.equalTo(kBadgeHeightWidth);
        make.height.equalTo(kBadgeHeightWidth);
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
    self.microphoneButton.selected = micSelected;
}

- (BOOL)micSelected
{
    return self.microphoneButton.selected;
}

- (void)setSpeakerSelected:(BOOL)speakerSelected
{
    self.speakerButton.selected = speakerSelected;
}

- (BOOL)speakerSelected
{
    return self.speakerButton.selected;
}

- (void)createIncomingCallViewForFriend:(NSString *)nickname
{
    if (self.incomingCallContainer) {
        return;
    }

    [self setupIncomingCallViewForFriend:nickname];
}

- (void)setPauseSelected:(BOOL)pauseSelected
{
    self.pauseButton.selected = pauseSelected;
}

- (BOOL)pauseSelected
{
    return self.pauseButton.selected;
}

- (void)hideIncomingCallView
{
    [self.incomingCallContainer removeFromSuperview];
    self.incomingCallContainer = nil;

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

#pragma mark - Private

- (void)updateTimerLabel
{
    self.subLabel.text = [NSString stringFromTimeInterval:self.callDuration];

    [self.subLabel setNeedsDisplay];
}

- (UIButton *)createButtonWithImageName:(NSString *)imageName action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:imageName];
    [button setImage:image forState:UIControlStateNormal];

    button.tintColor = [UIColor whiteColor];

    button.contentMode = UIViewContentModeScaleAspectFill;
    button.layer.cornerRadius = kButtonSide / 2.0f;
    button.layer.masksToBounds = YES;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = kButtonBorderWidth;

    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (void)setupIncomingCallViewForFriend:(NSString *)nickname
{
    self.incomingCallContainer = [UIView new];
    self.incomingCallContainer.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.incomingCallContainer];

    UILabel *nameLabel = [UILabel new];
    nameLabel.adjustsFontSizeToFitWidth = YES;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = nickname;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueBoldWithSize:kIncomingNameFontSize];
    [self.incomingCallContainer addSubview:nameLabel];

    UILabel *descriptionLabel = [UILabel new];
    descriptionLabel.text = NSLocalizedString(@"is calling", @"Calls");
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueBoldWithSize:kIncomingIsCallingFontSize];
    [self.incomingCallContainer addSubview:descriptionLabel];

    UIButton *declineCall = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *declineCallImage = [UIImage imageNamed:@"call-decline"];
    [declineCall setImage:declineCallImage forState:UIControlStateNormal];
    declineCall.tintColor = [UIColor whiteColor];
    declineCall.backgroundColor = [[AppContext sharedContext].appearance callRedColor];
    declineCall.layer.cornerRadius = kOtherCallButtonSize / 2.0;
    [declineCall addTarget:self action:@selector(declineIncomingCallButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.incomingCallContainer addSubview:declineCall];

    UIButton *acceptCall = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *acceptCallimage = [UIImage imageNamed:@"call-phone"];
    [acceptCall setImage:acceptCallimage forState:UIControlStateNormal];
    acceptCall.tintColor = [UIColor whiteColor];
    acceptCall.backgroundColor = [UIColor greenColor];
    acceptCall.layer.cornerRadius = kOtherCallButtonSize / 2.0;
    [acceptCall addTarget:self action:@selector(acceptIncomingCallButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.incomingCallContainer addSubview:acceptCall];

    self.topIncomingCallSpacer = [UIView new];
    self.topIncomingCallSpacer.backgroundColor = [UIColor clearColor];
    self.bottomIncomingCallSpacer = [UIView new];
    self.bottomIncomingCallSpacer.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.topIncomingCallSpacer];
    [self.view addSubview:self.bottomIncomingCallSpacer];

    [self.incomingCallContainer makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(kButtonSide);
        make.bottom.equalTo(self.bottomIncomingCallSpacer.top);
        make.top.equalTo(self.topIncomingCallSpacer.bottom);
    }];

    [self.topIncomingCallSpacer makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.bottomIncomingCallSpacer);
        make.top.equalTo(self.controlsContainerView.bottom);
    }];

    [self.bottomIncomingCallSpacer makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.bottomIncomingCallSpacer);
        make.bottom.equalTo(self.endCallButton.top);
    }];

    [acceptCall makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.incomingCallContainer);
        make.centerY.equalTo(self.incomingCallContainer);
        make.height.equalTo(kOtherCallButtonSize);
        make.width.equalTo(kOtherCallButtonSize);
    }];

    [declineCall makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(acceptCall);
        make.centerY.equalTo(acceptCall);
        make.right.equalTo(acceptCall.left).with.offset(-kIndent);
    }];

    [nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.incomingCallContainer.left);
        make.height.equalTo(20.0);
        make.bottom.equalTo(self.incomingCallContainer.centerY);
    }];

    [descriptionLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(nameLabel);
        make.bottom.equalTo(self.incomingCallContainer.bottom);
        make.top.equalTo(self.incomingCallContainer.centerY);
    }];
}

- (void)showTableViewOfPausedCalls
{
    if (! self.tableViewOfPausedCalls.hidden) {
        return;
    }

    self.tableViewOfPausedCalls.hidden = NO;
    self.tableViewRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                  target:self
                                                                selector:@selector(reloadPausedCalls)
                                                                userInfo:nil
                                                                 repeats:YES];
}

- (void)hideTableViewOfPausedCalls
{
    self.tableViewOfPausedCalls.hidden = YES;

    [self.tableViewRefreshTimer invalidate];
    self.tableViewRefreshTimer = nil;
}

#pragma mark - Call Menu

- (void)callMenuButtonPressed
{
    BOOL wasHidden = self.tableViewOfPausedCalls.hidden;

    wasHidden ? [self showTableViewOfPausedCalls] : [self hideTableViewOfPausedCalls];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.dataSource activeCallController:self resumePausedCallSelectedAtIndex:indexPath];
    self.tableViewOfPausedCalls.hidden = YES;
    [self.tableViewRefreshTimer invalidate];
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

#pragma mark PauseCallTableViewCellDelegate

- (void)pauseCallCellEndPausedCallButtonTapped:(PauseCallTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableViewOfPausedCalls indexPathForCell:cell];

    [self.dataSource activeCallController:self endPausedCallSelectedAtIndex:indexPath];
}

#pragma mark - Touch actions

- (void)acceptIncomingCallButtonPressed
{
    [self.delegate activeCallAnswerIncomingCallButtonPressed:self];
}

- (void)declineIncomingCallButtonPressed
{
    [self.delegate activeCallDeclineIncomingCallButtonPressed:self];
}

- (void)micButtonPressed
{
    [self.delegate activeCallMicButtonPressed:self];
}

- (void)speakerButtonPressed
{
    [self.delegate activeCallSpeakerButtonPressed:self];
}

- (void)endCallButtonPressed
{
    [self.delegate activeCallDeclineButtonPressed:self];
}

- (void)pauseButtonPressed
{
    [self.delegate activeCallPauseButtonPressed:self];
}

@end
