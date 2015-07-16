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
static const CGFloat kNameLabelHeight = 30.0;
static const CGFloat kTopContainerHeight = 100.0;
static const CGFloat kSublabelFontSize = 16.0;
static const CGFloat kNameLabelFontSize = 30.0;

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

    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
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
    self.topViewContainer.backgroundColor = [UIColor darkGrayColor];
    self.topViewContainer.alpha = 0.95;
    [self.view addSubview:self.topViewContainer];
}

- (void)createNameLabel
{
    self.nameLabel = [UILabel new];
    self.nameLabel.text = self.nickname;
    self.nameLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:kNameLabelFontSize];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.nameLabel sizeToFit];

    [self.topViewContainer addSubview:self.nameLabel];
}

- (void)createSublabel
{
    self.subLabel = [UILabel new];
    self.subLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:kSublabelFontSize];
    self.subLabel.textColor = [UIColor whiteColor];
    self.subLabel.textAlignment = NSTextAlignmentCenter;
    [self.subLabel sizeToFit];

    [self.topViewContainer addSubview:self.subLabel];
}

- (void)installConstraints
{
    [self.topViewContainer makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(kTopContainerHeight);
    }];

    [self.nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topViewContainer.topMargin).with.offset(kIndent);
        make.centerX.equalTo(self.topViewContainer);
        make.height.equalTo(kNameLabelHeight);
    }];

    [self.subLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.bottom).with.offset(kIndent);
        make.centerX.equalTo(self.topViewContainer);
    }];
}

@end
