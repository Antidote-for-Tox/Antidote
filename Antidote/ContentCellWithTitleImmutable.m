//
//  ContentCellWithTitleImmutable.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 25/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "ContentCellWithTitleImmutable.h"
#import "AppearanceManager.h"
#import "CopyLabel.h"

static const CGFloat kLabelTopOffset = 2.0;

static const CGFloat kEditButtonTopOffset = -4.0;
static const CGFloat kEditButtonRightOffset = 10.0;
static const CGFloat kEditButtonSize = 30.0;

static const CGFloat kMinumumMainLabelHeight = 20.0;

@interface ContentCellWithTitleImmutable ()

@property (strong, nonatomic) CopyLabel *mainLabel;
@property (strong, nonatomic) UIButton *editButton;

@property (strong, nonatomic) MASConstraint *editButtonSizeConstraint;

@end

@implementation ContentCellWithTitleImmutable
@dynamic delegate;

#pragma mark -  Lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (! self) {
        return nil;
    }

    [self createViews];
    [self installConstraints];

    self.showEditButton = NO;

    return self;
}

#pragma mark -  Properties

- (void)setMainText:(NSString *)text
{
    self.mainLabel.text = text;
}

- (NSString *)mainText
{
    return self.mainLabel.text;
}

- (void)setShowEditButton:(BOOL)show
{
    _showEditButton = show;

    self.editButton.hidden = ! show;

    if (show) {
        [self.editButtonSizeConstraint activate];
    }
    else {
        [self.editButtonSizeConstraint deactivate];
    }
}

- (void)setCopyable:(BOOL)copyable
{
    self.mainLabel.copyable = copyable;
}

- (BOOL)copyable
{
    return self.mainLabel.copyable;
}

#pragma mark -  Actions

- (void)editButtonPressed
{
    if ([self.delegate respondsToSelector:@selector(contentCellWithTitleImmutableEditButtonPressed:)]) {
        [self.delegate contentCellWithTitleImmutableEditButtonPressed:self];
    }
}

#pragma mark -  Private

- (void)createViews
{
    self.mainLabel = [CopyLabel new];
    self.mainLabel.numberOfLines = 0;
    self.mainLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:17.0];
    self.mainLabel.textColor = [UIColor blackColor];
    self.mainLabel.backgroundColor = [UIColor clearColor];
    [self.customContentView addSubview:self.mainLabel];

    UIImage *image = [UIImage imageNamed:@"edit-icon"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    self.editButton = [UIButton new];
    [self.editButton setImage:image forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(editButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.customContentView addSubview:self.editButton];
}

- (void)installConstraints
{
    [self.mainLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.bottom).offset(kLabelTopOffset);
        make.left.bottom.equalTo(self.customContentView);
        make.height.greaterThanOrEqualTo(kMinumumMainLabelHeight);
    }];

    [self.editButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainLabel).offset(kEditButtonTopOffset);
        make.left.equalTo(self.mainLabel.right);
        make.right.equalTo(self.customContentView).offset(kEditButtonRightOffset);
        self.editButtonSizeConstraint = make.size.equalTo(kEditButtonSize);
    }];
}

@end
