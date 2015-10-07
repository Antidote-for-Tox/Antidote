//
//  FullscreenPicker.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 09/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FullscreenPicker;
@protocol FullscreenPickerDelegate <NSObject>

- (void)fullscreenPicker:(FullscreenPicker *)picker willDismissWithSelectedIndex:(NSUInteger)index;

@end

@interface FullscreenPicker : UIView

@property (weak, nonatomic) id<FullscreenPickerDelegate> delegate;

- (instancetype)initWithStrings:(NSArray *)stringsArray selectedIndex:(NSUInteger)index;

/**
 * Shows picker in given view.
 */
- (void)showAnimatedInView:(UIView *)view;

@end
