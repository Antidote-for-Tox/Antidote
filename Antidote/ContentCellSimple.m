//
//  ContentCellSimple.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 18/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "ContentCellSimple.h"
#import "AppearanceManager.h"

static const CGFloat kHorizontalOffset = 10.0;

static const CGFloat kLabelFontSize = 17.0;
static const CGFloat kLabelMinimumHeight = 20.0;

static const CGFloat kDetailLabelRightOffset = -20.0;

@interface ContentCellSimple ()

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UILabel *detailLabel;

@end

@implementation ContentCellSimple

#pragma mark -  Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (! self) {
        return nil;
    }

    [self createViews];
    [self remakeConstraints];

    return self;
}

#pragma mark -  Properties

- (void)setTitle:(NSString *)title
{
    self.label.text = title;
}

- (NSString *)title
{
    return self.label.text;
}

- (void)setDetailTitle:(NSString *)detail
{
    self.detailLabel.text = detail;
}

- (NSString *)detailTitle
{
    return self.detailLabel.text;
}

- (void)setTitleColor:(UIColor *)color
{
    self.label.textColor = color;
}

- (UIColor *)titleColor
{
    return self.label.textColor;
}

- (void)setBoldTitle:(BOOL)boldTitle
{
    _boldTitle = boldTitle;

    if (boldTitle) {
        self.label.font = [[AppContext sharedContext].appearance fontHelveticaNeueBoldWithSize:kLabelFontSize];
    }
    else {
        self.label.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:kLabelFontSize];
    }
}

- (void)setLeftAccessoryView:(UIView *)view
{
    if (_leftAccessoryView) {
        [_leftAccessoryView removeFromSuperview];
    }

    _leftAccessoryView = view;

    if (view) {
        [self.customContentView addSubview:view];
    }

    [self remakeConstraints];
}

- (void)setLeftAccessoryViewSize:(CGSize)size
{
    _leftAccessoryViewSize = size;
    [self remakeConstraints];
}

#pragma mark -  Override

- (void)resetCell
{
    self.title = nil;
    self.boldTitle = NO;
    self.titleColor = [UIColor blackColor];
    self.detailTitle = nil;
    self.leftAccessoryView = nil;
    self.leftAccessoryViewSize = CGSizeZero;
    self.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark -  Private

- (void)createViews
{
    self.label = [UILabel new];
    [self.customContentView addSubview:self.label];

    self.detailLabel = [UILabel new];
    [self.customContentView addSubview:self.detailLabel];
}

- (void)remakeConstraints
{
    [self.leftAccessoryView remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.customContentView);
        make.centerY.equalTo(self.customContentView);
        make.top.greaterThanOrEqualTo(self.customContentView);
        make.bottom.lessThanOrEqualTo(self.customContentView);
        make.width.equalTo(self.leftAccessoryViewSize.width);
        make.height.equalTo(self.leftAccessoryViewSize.height);
    }];

    [self.label remakeConstraints:^(MASConstraintMaker *make) {
        if (self.leftAccessoryView) {
            make.left.equalTo(self.leftAccessoryView.right).offset(kHorizontalOffset);
        }
        else {
            make.left.equalTo(self.customContentView);
        }
        make.centerY.equalTo(self.customContentView);
        make.top.greaterThanOrEqualTo(self.customContentView);
        make.bottom.lessThanOrEqualTo(self.customContentView);
        make.height.greaterThanOrEqualTo(kLabelMinimumHeight);
    }];

    [self.detailLabel remakeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.label.right).offset(kHorizontalOffset);
        make.right.equalTo(self.customContentView).offset(kDetailLabelRightOffset);
        make.centerY.equalTo(self.customContentView);
        make.top.greaterThanOrEqualTo(self.customContentView);
        make.bottom.lessThanOrEqualTo(self.customContentView);
        make.height.greaterThanOrEqualTo(kLabelMinimumHeight);
    }];
}

@end
