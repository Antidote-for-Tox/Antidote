//
//  IncomingCallNotificationView.h
//  Antidote
//
//  Created by Chuong Vu on 7/21/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IncomingCallNotificationViewDelegate

- (void)incomingCallNotificationViewTappedAcceptButton;
- (void)incomingCallNotificationViewTappedDeclineButton;

@end

@interface IncomingCallNotificationView : UIView

@property (weak, nonatomic) id<IncomingCallNotificationViewDelegate> delegate;

- (instancetype)initWithNickname:(NSString *)nickname;

@end
