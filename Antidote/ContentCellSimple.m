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

static const CGFloat kLeftAccessoryViewRightOffset = 10.0;

static const CGFloat kLabelFontSize = 17.0;
static const CGFloat kLabelMinimumHeight = 20.0;

@interface ContentCellSimple ()

@property (strong, nonatomic) UILabel *label;

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

#pragma mark -  Private

- (void)createViews
{
    self.label = [UILabel new];
    [self.customContentView addSubview:self.label];
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
            make.left.equalTo(self.leftAccessoryView.right).offset(kLeftAccessoryViewRightOffset);
        }
        else {
            make.left.equalTo(self.customContentView);
        }
        make.centerY.equalTo(self.customContentView);
        make.top.greaterThanOrEqualTo(self.customContentView);
        make.bottom.lessThanOrEqualTo(self.customContentView);
        make.height.greaterThanOrEqualTo(kLabelMinimumHeight);
    }];
}

@end
