//
//  FriendRequestsCell.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FriendRequestsCell;

@protocol FriendRequestsCellDelegate <NSObject>
- (void)friendRequestCellAddButtonPressed:(FriendRequestsCell *)cell;
@end

@interface FriendRequestsCell : UITableViewCell

@property (weak, nonatomic) id <FriendRequestsCellDelegate> delegate;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;

- (void)redraw;

+ (CGFloat)height;

@end
