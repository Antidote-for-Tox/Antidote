//
//  AbstractCallViewController.m
//  Antidote
//
//  Created by Chuong Vu on 7/2/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "AbstractCallViewController.h"

#import "Masonry.h"
#import "Helper.h"
#import "AppearanceManager.h"

static const CGFloat kIndent = 20.0;
static const CGFloat kNameLabelHeightPortrait = 30.0;
static const CGFloat kNameLabelHeightLandscape = 20.0;
static const CGFloat kTopContainerHeightPortrait = 100.0;
static const CGFloat kTopContainerHeightLandscape = 75.0;
static const CGFloat kSublabelFontSize = 13.0;
static const CGFloat kNameLabelFontSize = 30.0;
static const CGFloat kNameLabelXIndent = 30.0;

@interface AbstractCallViewController ()

@property (strong, nonatomic, readwrite) UIView *topViewContainer;
@property (strong, nonatomic, readwrite) UILabel *nameLabel;
@property (strong, nonatomic, readwrite) UILabel *subLabel;

@end

@implementation AbstractCallViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupBlurredBackground];

    [self createTopViewContainer];
    [self createNameLabel];
    [self createSublabel];

    [self installConstraints];
}

- (void)setupBlurredBackground
{
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;

    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.view.bounds;

    [self.view insertSubview:visualEffectView atIndex:0];
    [visualEffectView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setNickname:(NSString *)nickname
{
    _nickname = nickname;
    self.nameLabel.text = nickname;
    [self.nameLabel setNeedsDisplay];
}

- (void)createTopViewContainer
{
    self.topViewContainer = [UIView new];
    self.topViewContainer.backgroundColor = [UIColor clearColor];
    self.topViewContainer.alpha = 0.95;
    [self.view addSubview:self.topViewContainer];
}

- (void)createNameLabel
{
    self.nameLabel = [UILabel new];
    self.nameLabel.text = self.nickname;
    self.nameLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:kNameLabelFontSize];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    self.nameLabel.textAlignment = NSTextAlignmentCenter;

    [self.topViewContainer addSubview:self.nameLabel];
}

- (void)createSublabel
{
    self.subLabel = [UILabel new];
    self.subLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:kSublabelFontSize];
    self.subLabel.textColor = [UIColor whiteColor];
    self.subLabel.textAlignment = NSTextAlignmentCenter;

    [self.topViewContainer addSubview:self.subLabel];
}

#pragma mark - Autolayout

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self remakeConstraintsForOrientation:toInterfaceOrientation];

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)installConstraints
{
    [self remakeConstraintsForOrientation:self.interfaceOrientation];
}

- (void)remakeConstraintsForOrientation:(UIInterfaceOrientation)orientation
{
    const BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);

    const CGFloat topViewContainerXOffset = isPortrait ? 0.0 : kIndent;
    const CGFloat topViewContainerYHeight = isPortrait ? kTopContainerHeightPortrait : kTopContainerHeightLandscape;

    [self.topViewContainer remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view).with.offset(topViewContainerXOffset);
        make.right.equalTo(self.view).with.offset(-topViewContainerXOffset);
        make.height.equalTo(topViewContainerYHeight);
    }];

    const CGFloat nameLabelHeight = isPortrait ? kNameLabelHeightPortrait : kNameLabelHeightLandscape;

    [self.nameLabel remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topViewContainer).with.offset(kIndent);
        make.height.equalTo(nameLabelHeight);
        make.left.equalTo(self.topViewContainer).with.offset(kNameLabelXIndent);
        make.right.equalTo(self.topViewContainer).with.offset(-kNameLabelXIndent);
    }];

    [self.subLabel remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.bottom).with.offset(kIndent);
        make.centerX.equalTo(self.topViewContainer);
    }];
}


@end
