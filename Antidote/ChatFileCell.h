//
//  ChatFileCell.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 14.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatFileCell;
@protocol ChatFileCellDelegate <NSObject>
- (void)chatFileCellButtonPressedYes:(ChatFileCell *)cell;
- (void)chatFileCellButtonPressedNo:(ChatFileCell *)cell;
@end

@interface ChatFileCell : UITableViewCell

@property (weak, nonatomic) id <ChatFileCellDelegate> delegate;

@property (assign, nonatomic) BOOL showYesNoButtons;

- (void)redraw;

+ (CGFloat)height;
+ (NSString *)reuseIdentifier;

@end
