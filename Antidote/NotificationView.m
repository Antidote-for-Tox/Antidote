//
//  NotificationView.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 27.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "NotificationView.h"
#import "UIColor+Utilities.h"
#import "AppearanceManager.h"

const CGFloat kNotificationViewHeight = 50.0;

static const CGFloat kIndentation = 10.0;
static const CGFloat kLabelsIndentation = -5.0;

@interface NotificationView ()

@property (copy, nonatomic) NotificationObject *object;

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *topLabel;
@property (strong, nonatomic) UILabel *bottomLabel;

@end

@implementation NotificationView

#pragma mark -  Public

- (instancetype)initWithObject:(NotificationObject *)object
{
    self = [super init];

    if (! self) {
        return nil;
    }

    self.object = object;
    self.backgroundColor = [UIColor uColorWithRed:65 green:56 blue:57 alpha:0.9];

    [self createSubviews];
    [self installConstraints];

    return self;
}

#pragma mark -  Private

- (void)createSubviews
{
    AppearanceManager *appearance = [AppContext sharedContext].appearance;

    self.imageView = [UIImageView new];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.image = self.object.image;
    [self addSubview:self.imageView];

    self.topLabel = [UILabel new];
    self.topLabel.text = self.object.topText;
    self.topLabel.textColor = [UIColor whiteColor];
    self.topLabel.backgroundColor = [UIColor clearColor];
    self.topLabel.font = [appearance fontHelveticaNeueLightWithSize:16.0];
    [self addSubview:self.topLabel];

    self.bottomLabel = [UILabel new];
    self.bottomLabel.text = self.object.bottomText;
    self.bottomLabel.textColor = [UIColor whiteColor];
    self.bottomLabel.backgroundColor = [UIColor clearColor];
    self.bottomLabel.font = [appearance fontHelveticaNeueLightWithSize:16.0];
    [self addSubview:self.bottomLabel];
}

- (void)installConstraints
{
    [self.imageView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(kIndentation);
        make.centerY.equalTo(self);
        CGFloat size = self.object.image ? kNotificationObjectImageSize : 0.0;
        make.width.height.equalTo(size);
    }];

    [self.topLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.top);
        make.left.equalTo(self.imageView.right).offset(kIndentation);
        make.right.equalTo(self.right).offset(-kIndentation);
    }];

    [self.bottomLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topLabel.bottom).offset(kLabelsIndentation);
        make.left.equalTo(self.topLabel.left);
        make.right.equalTo(self.right).offset(-kIndentation);
        make.bottom.equalTo(self.bottom);
        make.height.equalTo(self.topLabel.height);
    }];
}

@end
