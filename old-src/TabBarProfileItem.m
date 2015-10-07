//
//  TabBarProfileItem.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 09.07.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <BlocksKit/UIControl+BlocksKit.h>
#import <Masonry/Masonry.h>

#import "TabBarProfileItem.h"
#import "AppearanceManager.h"

static const CGFloat kStatusViewOffset = -3.0;
static const CGFloat kStatusViewSize = 6.0;

@interface TabBarProfileItem ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) StatusCircleView *statusView;

@property (strong, nonatomic) UIButton *button;

@end

@implementation TabBarProfileItem
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

    [self createImageView];
    [self createStatusView];
    [self createButton];

    [self installConstraints];

    return self;
}

#pragma mark -  Properties

- (void)setStatus:(StatusCircleStatus)status
{
    self.statusView.status = status;
    [self.statusView redraw];
}

- (StatusCircleStatus)status
{
    return self.statusView.status;
}

#pragma mark -  TabBarItemProtocol

- (void)setSelected:(BOOL)selected
{
    _selected = selected;

    self.imageView.tintColor = selected ?
                               [[AppContext sharedContext].appearance bubbleOutgoingColor] :
                               [UIColor colorWithWhite:0.75 alpha:1.0];
}

#pragma mark -  Private

- (void)createImageView
{
    UIImage *image = [UIImage imageNamed:@"tab-bar-profile"];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.imageView];
}

- (void)createStatusView
{
    self.statusView = [StatusCircleView new];
    [self.statusView redraw];
    [self addSubview:self.statusView];
}

- (void)createButton
{
    self.button = [UIButton new];
    self.button.backgroundColor = [UIColor clearColor];
    [self addSubview:self.button];

    weakself;
    [self.button bk_addEventHandler:^(UIButton *b) {
        strongself;

        if (self.didTapOnItem) {
            self.didTapOnItem(self);
        }
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)installConstraints
{
    [self.imageView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
    }];

    [self.statusView makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.imageView).offset(kStatusViewOffset);
        make.bottom.equalTo(self.imageView).offset(kStatusViewOffset);
        make.width.height.equalTo(kStatusViewSize);
    }];

    [self.button makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

@end
