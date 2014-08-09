//
//  StatusCircleView.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, StatusCircleStatus) {
    StatusCircleStatusOffline,
    StatusCircleStatusOnline,
    StatusCircleStatusAway,
    StatusCircleStatusBusy,
};

@interface StatusCircleView : UIView

@property (assign, nonatomic) StatusCircleStatus status;
@property (assign, nonatomic) BOOL showWhiteBorder;

// default value is 10
@property (assign, nonatomic) CGFloat side;

// this method will adjust StatusCircleView frame.size
- (void)redraw;

@end
