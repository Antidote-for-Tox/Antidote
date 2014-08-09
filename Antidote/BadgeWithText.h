//
//  BadgeWithText.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 09.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BadgeWithText : UIView

@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIColor *bubbleColor;

// BadgeWithText will resize itself after setting value
@property (strong, nonatomic) NSString *value;

@end
