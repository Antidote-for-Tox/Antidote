//
//  CellWithSwitch.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 05.01.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellWithSwitchDelegate;

@interface CellWithSwitch : UITableViewCell

@property (weak, nonatomic) id <CellWithSwitchDelegate> delegate;

@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL on;

@end

@protocol CellWithSwitchDelegate <NSObject>
- (void)cellWithSwitchStateChanged:(CellWithSwitch *)cell;
@end
