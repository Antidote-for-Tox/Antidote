//
//  CallControlsView.h
//  Antidote
//
//  Created by Chuong Vu on 7/27/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallControlsViewProtocol.h"

@interface ExpandedControlsView : UIView <CallControlsViewProtocol>

@property (weak, nonatomic) id<CallControlsViewDelegate> delegate;

@end
