//
//  ContentSeparatorCell.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 25/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "ContentSeparatorCell.h"

static const CGFloat kSeparatorHeight = 0.5;
static const CGFloat kDefaultHeight = 20.0;

@interface ContentSeparatorCell ()

@property (strong, nonatomic) UIView *separatorView;
@property (strong, nonatomic) MASConstraint *heightConstraint;

@end

@implementation ContentSeparatorCell

#pragma mark -  Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (! self) {
        return nil;
    }

    self.separatorView = [UIView new];
    self.separatorView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    [self.customContentView addSubview:self.separatorView];

    [self.separatorView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.customContentView);
        make.centerY.equalTo(self);
        make.height.equalTo(kSeparatorHeight);
    }];

    [self.customContentView makeConstraints:^(MASConstraintMaker *make) {
        self.heightConstraint = make.height.equalTo(kDefaultHeight);
    }];

    self.enableRightOffset = NO;

    [self resetCell];

    return self;
}

#pragma mark -  Override

- (void)resetCell
{
    self.showGraySeparator = YES;
}

#pragma mark -  Properties

- (void)setShowGraySeparator:(BOOL)show
{
    self.separatorView.hidden = ! show;
}

- (BOOL)showGraySeparator
{
    return ! self.separatorView.hidden;
}

- (void)setHeight:(CGFloat)height
{
    self.heightConstraint.offset(height);
}

@end
