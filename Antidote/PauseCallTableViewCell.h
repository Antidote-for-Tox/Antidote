//
//  PauseCallTableViewCell.h
//  Antidote
//
//  Created by Chuong Vu on 7/16/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PauseCallTableViewCell;

@protocol PauseCallTableViewCellDelegate <NSObject>

- (void)pauseCallCellEndPausedCallButtonTapped:(PauseCallTableViewCell *)cell;

@end

@interface PauseCallTableViewCell : UITableViewCell

@property (weak, nonatomic) id <PauseCallTableViewCellDelegate> delegate;

/**
 * Set the friend's nickname and current call time
 * @param nickName Name of the caller.
 * @param callDuration The time it was paused at.
 */
- (void)setCallerNickname:(NSString *)nickName andCallDuration:(NSTimeInterval)callDuration;

@end
