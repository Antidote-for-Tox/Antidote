//
//  ToxIdView.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 02.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ToxIdView;
@protocol ToxIdViewDelegate <NSObject>
- (void)toxIdView:(ToxIdView *)view wantsToShowQRWithText:(NSString *)text;
@end

@interface ToxIdView : UIView

@property (weak, nonatomic) id<ToxIdViewDelegate> delegate;

// This method will set frame.size
- (instancetype)initWithId:(NSString *)toxId;

@end
