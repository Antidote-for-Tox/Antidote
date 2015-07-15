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

static const CGFloat kIndent = 50.0;

@interface AbstractCallViewController ()

@property (strong, nonatomic, readwrite) UILabel *nameLabel;

@end

@implementation AbstractCallViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupBlurredBackground];

    [self createNameLabel];

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

- (void)createNameLabel
{
    self.nameLabel = [UILabel new];
    self.nameLabel.text = self.nickname;
    self.nameLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:30.0];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.nameLabel sizeToFit];

    [self.view addSubview:self.nameLabel];
}

- (void)installConstraints
{
    [self.nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.top).with.offset(kIndent);
        make.centerX.equalTo(self.view.centerX);
        make.height.equalTo(30);
    }];
}

@end
