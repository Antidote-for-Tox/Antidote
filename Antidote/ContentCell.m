//
//  ContentCell.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 18/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "ContentCell.h"

static const CGFloat kContentLeftOffset = 20.0;
static const CGFloat kContentRightOffset = -20.0;
static const CGFloat kContentYOffset = 5.0;

@interface ContentCell ()

@property (strong, nonatomic) UIView *customContentView;

@property (strong, nonatomic) MASConstraint *rightConstraintWithOffset;
@property (strong, nonatomic) MASConstraint *rightConstraintNoOffset;

@end

@implementation ContentCell

#pragma mark -  Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];

    if (! self) {
        return nil;
    }

    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.customContentView = [UIView new];
    self.customContentView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.customContentView];

    [self.customContentView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kContentLeftOffset);
        make.top.equalTo(self).offset(kContentYOffset);
        make.bottom.equalTo(self).offset(-kContentYOffset);

        self.rightConstraintWithOffset = make.right.equalTo(self).offset(kContentRightOffset);
        self.rightConstraintNoOffset = make.right.equalTo(self);
    }];

    self.enableRightOffset = YES;

    return self;
}

#pragma mark -  Properties

- (void)setEnableRightOffset:(BOOL)enable
{
    _enableRightOffset = enable;

    if (enable) {
        [self.rightConstraintWithOffset activate];
        [self.rightConstraintNoOffset deactivate];
    }
    else {
        [self.rightConstraintWithOffset deactivate];
        [self.rightConstraintNoOffset activate];
    }
}

@end
