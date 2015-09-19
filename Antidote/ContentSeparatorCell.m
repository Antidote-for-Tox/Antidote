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
static const CGFloat kYOffset = 10.0;

@interface ContentSeparatorCell ()

@property (strong, nonatomic) UIView *separatorView;

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
        make.top.equalTo(self.customContentView).offset(kYOffset);
        make.bottom.equalTo(self.customContentView).offset(-kYOffset);
        make.height.equalTo(kSeparatorHeight);
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

@end
