//
//  BadgeWithText.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 09.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "BadgeWithText.h"
#import "UIView+Utilities.h"

@interface BadgeWithText()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UILabel *label;

@end

@implementation BadgeWithText

#pragma mark -  Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;

        self.backgroundView = [UIView new];
        self.backgroundView.backgroundColor = [UIColor redColor];

        self.label = [self addLabelWithTextColor:nil bgColor:[UIColor clearColor]];
        self.label.font = [AppearanceManager fontHelveticaNeueWithSize:14];

        self.textColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark -  Properties

- (void)setTextColor:(UIColor *)color
{
    self.label.textColor = color;
}

- (UIColor *)textColor
{
    return self.label.textColor;
}

- (void)setBubbleColor:(UIColor *)color
{
    self.backgroundView.backgroundColor = color;
}

- (UIColor *)bubbleColor
{
    return self.backgroundView.backgroundColor;
}

- (void)setValue:(NSString *)value
{
    self.label.text = value;

    [self adjustSubviews];
}

- (NSString *)value
{
    return self.label.text;
}

#pragma mark -  Private

- (void)adjustSubviews
{
    [self.label sizeToFit];

    CGFloat width = MAX(20, 8 + self.label.frame.size.width);

    CGRect frame = self.frame;
    frame.size.width = width;
    frame.size.height = self.label.frame.size.height;
    self.frame = frame;
    self.layer.cornerRadius = self.frame.size.height / 2;

    self.backgroundView.frame = self.bounds;

    frame = self.label.frame;
    frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
    self.label.frame = frame;
}

@end
