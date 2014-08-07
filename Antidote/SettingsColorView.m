//
//  SettingsColorView.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 07.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "SettingsColorView.h"
#import "UIView+Utilities.h"

static const CGFloat kButtonSide = 40.0;
static const CGFloat kButtonIndentation = 15.0;

@interface SettingsColorView()

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) NSArray *buttonsArray;

@end

@implementation SettingsColorView

#pragma mark -  Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        self.backgroundColor = [UIColor clearColor];

        self.label = [self addLabelWithTextColor:[UIColor blackColor] bgColor:[UIColor clearColor]];
        self.label.text = NSLocalizedString(@"Colorscheme", @"Settings");

        [self createButtons];
    }
    return self;
}

#pragma mark -  Actions

- (void)buttonPressed:(UIButton *)button
{
    NSUInteger index = [self.buttonsArray indexOfObject:button];

    [self.delegate settingsColorView:self didSelectScheme:index];
}

#pragma mark -  Public

- (CGSize)sizeThatFits:(CGSize)size
{
    [self.label sizeToFit];

    const CGFloat buttonsWidth = self.buttonsArray.count * kButtonSide +
        (self.buttonsArray.count - 1) * kButtonIndentation;

    const CGFloat maxWidth = MAX(self.label.frame.size.width, buttonsWidth);
    const CGFloat buttonsXDelta = (maxWidth - buttonsWidth) / 2;

    CGRect frame = self.label.frame;
    frame.origin.x = (maxWidth - frame.size.width) / 2;
    self.label.frame = frame;

    for (NSUInteger index = 0; index < self.buttonsArray.count; index++) {
        UIButton *button = self.buttonsArray[index];

        frame = button.frame;
        frame.origin.x = buttonsXDelta + index * (kButtonSide + kButtonIndentation);
        frame.origin.y = CGRectGetMaxY(self.label.frame);
        button.frame = frame;

        size.height = CGRectGetMaxY(button.frame);
    }

    size.width = maxWidth;

    return size;
}

#pragma mark -  Private

- (void)createButtons
{
    NSMutableArray *array = [NSMutableArray new];
    AppearanceManagerColorscheme currentScheme = [AppearanceManager colorscheme];

    for (NSUInteger index = 0; index < __AppearanceManagerColorschemeCount; index++) {
        CGRect frame = CGRectZero;
        frame.size.width = frame.size.height = kButtonSide;

        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        button.layer.cornerRadius = kButtonSide / 2;
        button.layer.masksToBounds = YES;

        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:button];
        [array addObject:button];

        if (index == currentScheme) {
            button.layer.borderWidth = 2.0;
            button.layer.borderColor = [UIColor blackColor].CGColor;
        }

        frame.size.width /= 2;

        UIView *left = [[UIView alloc] initWithFrame:frame];
        left.backgroundColor = [AppearanceManager textMainColorForScheme:index];
        left.userInteractionEnabled = NO;

        frame.origin.x = frame.size.width;

        UIView *right = [[UIView alloc] initWithFrame:frame];
        right.backgroundColor = [AppearanceManager bubbleIncomingColorForScheme:index];
        right.userInteractionEnabled = NO;

        [button addSubview:left];
        [button addSubview:right];
    }

    self.buttonsArray = [array copy];
}

@end
