//
//  ContentCellWithTitleBasic.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 25/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "ContentCellWithTitleBasic.h"
#import "AppearanceManager.h"

static const CGFloat kTitleHeight = 20.0;

@interface ContentCellWithTitleBasic ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *button;

@end

@implementation ContentCellWithTitleBasic

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (! self) {
        return nil;
    }

    [self basic_createViews];
    [self basic_installConstraints];

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

#pragma mark -  Actions

- (void)buttonPressed
{
    if ([self.delegate respondsToSelector:@selector(contentCellWithTitleBasicDidPressButton:)]) {
        [self.delegate contentCellWithTitleBasicDidPressButton:self];
    }
}

#pragma mark -  Override

- (void)resetCell
{
    self.title = nil;
    self.buttonTitle = nil;
    self.mainText = nil;
}

#pragma mark -  Private

- (void)basic_createViews
{
    UIColor *textMainColor = [[AppContext sharedContext].appearance textMainColor];

    self.titleLabel = [UILabel new];
    self.titleLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueLightWithSize:17.0];
    self.titleLabel.textColor = textMainColor;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self.customContentView addSubview:self.titleLabel];

    self.button = [UIButton new];
    [self.button setTitleColor:textMainColor forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.customContentView addSubview:self.button];
}

- (void)basic_installConstraints
{
    [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.customContentView);
        make.height.equalTo(kTitleHeight);
    }];

    [self.button makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.titleLabel.right);
        make.right.equalTo(self.customContentView);
        make.centerY.equalTo(self.titleLabel);
        make.bottom.lessThanOrEqualTo(self.customContentView);
    }];
}

@end
