//
//  ValueViewWithTitle.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 13.07.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "ValueViewWithTitle.h"

static const CGFloat kSpacing = 4.0;
static const CGFloat kContainerIndentation = 8.0;

@interface ValueViewWithTitle ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView *valueContainer;
@property (strong, nonatomic) UILabel *valueLabel;

@end

@implementation ValueViewWithTitle

#pragma mark -  Lyfecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (! self) {
        return nil;
    }

    self.backgroundColor = [UIColor clearColor];

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

- (void)setValue:(NSString *)value
{
    self.valueLabel.text = value;
}

- (NSString *)value
{
    return self.valueLabel.text;
}

#pragma mark -  Private

- (void)createViews
{
    self.titleLabel = [UILabel new];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.titleLabel];

    self.valueContainer = [UIView new];
    self.valueContainer.backgroundColor = [UIColor whiteColor];
    self.valueContainer.layer.cornerRadius = 5.0;
    self.valueContainer.layer.borderWidth = 0.5;
    self.valueContainer.layer.borderColor = [[UIColor colorWithWhite:0.8f alpha:1.0f] CGColor];
    self.valueContainer.layer.masksToBounds = YES;
    [self addSubview:self.valueContainer];

    self.valueLabel = [UILabel new];
    self.valueLabel.numberOfLines = 0;
    self.valueLabel.textColor = [UIColor blackColor];
    [self.valueContainer addSubview:self.valueLabel];
}

- (void)installConstraints
{
    [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
    }];

    [self.valueContainer makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.bottom).offset(kSpacing);
        make.left.right.bottom.equalTo(self);
    }];

    [self.valueLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.valueContainer).offset(kContainerIndentation);
        make.bottom.right.equalTo(self.valueContainer).offset(-kContainerIndentation);
    }];
}

@end
