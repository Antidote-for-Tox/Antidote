//
//  ContentCellWithAvatar.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 24/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "ContentCellWithAvatar.h"

const CGFloat kContentCellWithAvatarImageSize = 120.0;

@interface ContentCellWithAvatar ()

@property (strong, nonatomic) UIButton *button;

@end

@implementation ContentCellWithAvatar

#pragma mark -  Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (! self) {
        return nil;
    }

    [self createViews];
    [self installConstraints];

    return self;
}

#pragma mark -  Properties

- (void)setAvatar:(UIImage *)avatar
{
    [self.button setImage:avatar forState:UIControlStateNormal];
}

- (UIImage *)avatar
{
    return [self.button imageForState:UIControlStateNormal];
}

#pragma mark -  Actions

- (void)buttonPressed
{
    [self.delegate contentCellWithAvatarImagePressed:self];
}

#pragma mark -  Override

- (void)resetCell
{
    self.avatar = nil;
}

#pragma mark -  Private

- (void)createViews
{
    self.button = [UIButton new];
    self.button.layer.cornerRadius = kContentCellWithAvatarImageSize / 2;
    self.button.layer.masksToBounds = YES;
    [self.button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.customContentView addSubview:self.button];
}

- (void)installConstraints
{
    [self.button makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.customContentView);
        make.top.bottom.equalTo(self.customContentView);
        make.size.equalTo(kContentCellWithAvatarImageSize);
    }];
}

@end
