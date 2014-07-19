//
//  FriendRequestsCell.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendRequestsCell : UITableViewCell

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *subtitle;

- (void)redraw;

+ (CGFloat)height;
+ (NSString *)reuseIdentifier;

@end
