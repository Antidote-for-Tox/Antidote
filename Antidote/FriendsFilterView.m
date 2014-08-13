//
//  FriendsFilterView.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 13.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "FriendsFilterView.h"

@interface FriendsFilterView()

@property (strong, nonatomic) UIButton *invisibleButton;
@property (strong, nonatomic) NSArray *buttonsArray;

@end

@implementation FriendsFilterView

#pragma mark -  Lifecycle

- (instancetype)initWithFrame:(CGRect)frame stringsArray:(NSArray *)stringsArray
{
    self = [super initWithFrame:frame];
    if (self) {
        self.invisibleButton = [[UIButton alloc] initWithFrame:self.bounds];
        self.invisibleButton.backgroundColor = [UIColor clearColor];
        [self.invisibleButton addTarget:self
                                 action:@selector(invisibleButtonPressed)
                       forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.invisibleButton];

        NSMutableArray *buttonsArray = [NSMutableArray arrayWithCapacity:stringsArray.count];

        CGFloat originY = 0.0;

        for (NSString *string in stringsArray) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.titleLabel.font = [AppearanceManager fontHelveticaNeueWithSize:16];
            button.backgroundColor = [AppearanceManager unreadChatCellBackgroundWithAlpha:0.95];
            [button setTitle:string forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];

            CGRect frame = CGRectZero;
            frame.size.width = self.bounds.size.width;
            frame.size.height = 30.0;
            frame.origin.x = (self.bounds.size.width - frame.size.width) / 2;
            frame.origin.y = originY;
            button.frame = frame;

            [buttonsArray addObject:button];

            originY += frame.size.height;
        }

        self.buttonsArray = [buttonsArray copy];
    }
    return self;
}

#pragma mark -  Properties

- (void)invisibleButtonPressed
{
    [self.delegate friendsFilterViewEmptySpacePressed:self];
}

- (void)buttonPressed:(UIButton *)button
{
    NSUInteger index = [self.buttonsArray indexOfObject:button];

    [self.delegate friendsFilterView:self didSelectStringAtIndex:index];
}

#pragma mark -  Public

- (CGFloat)heightOfVisiblePart
{
    UIButton *button = [self.buttonsArray lastObject];

    return CGRectGetMaxY(button.frame);
}

@end
