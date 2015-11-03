//
//  CompactControlsView.h
//  Antidote
//
//  Created by Chuong Vu on 8/10/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CallControlsViewProtocol.h"

@interface CompactControlsView : UIView <CallControlsViewProtocol>

@property (nonatomic, weak) id<CallControlsViewDelegate> delegate;

@end
