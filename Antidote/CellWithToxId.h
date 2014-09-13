//
//  CellWithToxId.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 13.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellWithToxIdDelegate;

@interface CellWithToxId : UITableViewCell

@property (weak, nonatomic) id <CellWithToxIdDelegate> delegate;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *toxId;

- (void)redraw;
+ (CGFloat)height;

@end

@protocol CellWithToxIdDelegate <NSObject>
- (void)cellWithToxIdQrButtonPressed:(CellWithToxId *)cell;
@end
