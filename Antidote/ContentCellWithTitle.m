//
//  ContentCellWithTitle.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 19/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "ContentCellWithTitle.h"
#import "AppearanceManager.h"

static const CGFloat kTitleHeight = 20.0;

@interface ContentCellWithTitle ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UILabel *mainTextLabel;

@end

@implementation ContentCellWithTitle

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

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setButtonTitle:(NSString *)title
{
    [self.button setTitle:title forState:UIControlStateNormal];
}

- (NSString *)buttonTitle
{
    return [self.button titleForState:UIControlStateNormal];
}

- (void)setMainText:(NSString *)text
{
    self.mainTextLabel.text = text;
}

- (NSString *)mainText
{
    return self.mainTextLabel.text;
}

#pragma mark -  Actions

- (void)buttonPressed
{
    [self.delegate contentCellWithTitleDidPressButton:self];
}

#pragma mark -  Private

- (void)createViews
{
    UIColor *textMainColor = [[AppContext sharedContext].appearance textMainColor];

    self.titleLabel = [UILabel new];
    self.titleLabel.textColor = textMainColor;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self.customContentView addSubview:self.titleLabel];

    self.button = [UIButton new];
    [self.button setTitleColor:textMainColor forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.customContentView addSubview:self.button];

    self.mainTextLabel = [UILabel new];
    self.mainTextLabel.textColor = [UIColor blackColor];
    self.mainTextLabel.backgroundColor = [UIColor clearColor];
    [self.customContentView addSubview:self.mainTextLabel];
}

- (void)installConstraints
{
    [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.customContentView);
        make.height.equalTo(kTitleHeight);
    }];

    [self.button makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.titleLabel.right);
        make.right.equalTo(self.customContentView);
        make.centerY.equalTo(self.titleLabel);
    }];

    [self.mainTextLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.bottom);
        make.left.right.bottom.equalTo(self.customContentView);
    }];
}

@end
