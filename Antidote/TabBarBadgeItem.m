//
//  TabBarBadgeItem.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 09.07.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <BlocksKit/UIControl+BlocksKit.h>
#import <Masonry/Masonry.h>

#import "TabBarBadgeItem.h"
#import "AppearanceManager.h"

static const CGFloat kImageAndTextContainerYOffset = 2.0;
static const CGFloat kImageAndTextOffset = 3.0;
static const CGFloat kBadgeVerticalOffset = 1.0;
static const CGFloat kBadgeHorizontalOffset = 3.0;

@interface TabBarBadgeItem ()

@property (strong, nonatomic) UIView *imageAndTextContainer;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *textLabel;

@property (strong, nonatomic) UIView *badgeContainer;
@property (strong, nonatomic) UILabel *badgeLabel;

@property (strong, nonatomic) UIButton *button;

@end

@implementation TabBarBadgeItem
@synthesize selected = _selected;
@synthesize didTapOnItem = _didTapOnItem;

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];

    if (! self) {
        return nil;
    }

    self.backgroundColor = [UIColor clearColor];

    [self createImageAndTextViews];
    [self createBadgeViews];
    [self createButton];

    [self installConstraints];

    return self;
}

#pragma mark -  Properties

- (void)setImage:(UIImage *)image
{
    self.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setText:(NSString *)text
{
    self.textLabel.text = text;
}

- (NSString *)text
{
    return self.textLabel.text;
}

- (void)setBadgeText:(NSString *)badgeText
{
    self.badgeLabel.text = badgeText;
}

- (NSString *)badgeText
{
    return self.badgeLabel.text;
}

#pragma mark -  TabBarItemProtocol

- (void)setSelected:(BOOL)selected
{
    _selected = selected;

    UIColor *color = selected ? [[AppContext sharedContext].appearance textMainColor] : [UIColor colorWithWhite:0.5 alpha:1.0];

    self.textLabel.textColor = color;
    self.imageView.tintColor = color;
}

#pragma mark -  Private

- (void)createImageAndTextViews
{
    self.imageAndTextContainer = [UIView new];
    self.imageAndTextContainer.backgroundColor = [UIColor clearColor];
    [self addSubview:self.imageAndTextContainer];

    self.imageView = [UIImageView new];
    self.imageView.backgroundColor = [UIColor clearColor];
    [self.imageAndTextContainer addSubview:self.imageView];

    self.textLabel = [UILabel new];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:10.0];
    [self.imageAndTextContainer addSubview:self.textLabel];
}

- (void)createBadgeViews
{
    self.badgeContainer = [UIView new];
    self.badgeContainer.backgroundColor = [[AppContext sharedContext].appearance statusBusyColor];
    [self addSubview:self.badgeContainer];

    self.badgeLabel = [UILabel new];
    self.badgeLabel.textColor = [UIColor whiteColor];
    self.badgeLabel.backgroundColor = [UIColor clearColor];
    self.badgeLabel.font = [[AppContext sharedContext].appearance fontHelveticaNeueWithSize:14.0];
    [self.badgeContainer addSubview:self.badgeLabel];
}

- (void)createButton
{
    self.button = [UIButton new];
    self.button.backgroundColor = [UIColor clearColor];
    [self addSubview:self.button];

    __weak TabBarBadgeItem *weakSelf = self;
    [self.button bk_addEventHandler:^(UIButton *b) {
        if (weakSelf.didTapOnItem) {
            weakSelf.didTapOnItem(weakSelf);
        }
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)installConstraints
{
    [self.imageAndTextContainer makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(kImageAndTextContainerYOffset);
    }];

    [self.imageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageAndTextContainer);
        make.centerX.equalTo(self.imageAndTextContainer);
    }];

    [self.textLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.bottom).offset(kImageAndTextOffset);
        make.centerX.equalTo(self.imageAndTextContainer);
        make.bottom.equalTo(self.imageAndTextContainer);
    }];

    [self.badgeContainer makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageAndTextContainer.right);
        make.bottom.equalTo(self.imageAndTextContainer.top);
    }];

    [self.badgeContainer makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.badgeContainer).offset(kBadgeVerticalOffset);
        make.left.equalTo(self.badgeContainer).offset(kBadgeHorizontalOffset);
        make.right.equalTo(self.badgeContainer).offset(-kBadgeHorizontalOffset);
        make.bottom.equalTo(self.badgeContainer).offset(-kBadgeVerticalOffset);
    }];

    [self.button makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

@end
