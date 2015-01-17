//
//  CellWithColorscheme.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 13.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CellWithColorscheme.h"
#import "UIView+Utilities.h"
#import "UIColor+Utilities.h"

static const CGFloat kButtonSide = 40.0;
static const CGFloat kButtonIndentation = 15.0;

@interface CellWithColorscheme()

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) NSArray *buttonsArray;

@end

@implementation CellWithColorscheme

#pragma mark - Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.label = [self.contentView addLabelWithTextColor:[UIColor blackColor] bgColor:[UIColor clearColor]];
        self.label.text = NSLocalizedString(@"Colorscheme", @"CellWithColorscheme");

        [self createButtons];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self adjustSubviews];
}

#pragma mark -  Actions

- (void)buttonPressed:(UIButton *)button
{
    NSUInteger index = [self.buttonsArray indexOfObject:button];

    [self.delegate cellWithColorscheme:self didSelectScheme:index];
}

#pragma mark -  Public

- (void)redraw
{
    [self adjustSubviews];
}

+ (CGFloat)height
{
    return 75.0;
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
            button.layer.borderColor = [UIColor uColorOpaqueWithWhite:182].CGColor;
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

- (void)adjustSubviews
{
    [self.label sizeToFit];

    CGRect frame = self.label.frame;
    frame.origin.x = (self.bounds.size.width - frame.size.width) / 2;
    frame.origin.y = 4.0f;
    self.label.frame = frame;

    const CGFloat buttonsWidth = self.buttonsArray.count * kButtonSide +
        (self.buttonsArray.count - 1) * kButtonIndentation;
    CGFloat originX = (self.bounds.size.width - buttonsWidth) / 2;

    for (NSUInteger index = 0; index < self.buttonsArray.count; index++) {
        UIButton *button = self.buttonsArray[index];

        frame = button.frame;
        frame.origin.x = originX;
        frame.origin.y = CGRectGetMaxY(self.label.frame) + 5.0;
        button.frame = frame;

        originX += kButtonSide + kButtonIndentation;
    }
}

@end
