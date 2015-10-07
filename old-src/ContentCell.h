//
//  ContentCell.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 18/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentCell : UITableViewCell

/**
 * View to add all content to.
 */
@property (strong, nonatomic, readonly) UIView *customContentView;

/**
 * By default is enabled.
 */
@property (assign, nonatomic) BOOL enableRightOffset;

/**
 * Override this method in subclass.
 */
- (void)resetCell;

@end
