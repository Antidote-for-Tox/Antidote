//
//  CellWithColorscheme.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 13.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppearanceManager.h"

@protocol CellWithColorschemeDelegate;

@interface CellWithColorscheme : UITableViewCell

@property (weak, nonatomic) id <CellWithColorschemeDelegate> delegate;

- (void)redraw;
+ (CGFloat)height;

@end

@protocol CellWithColorschemeDelegate <NSObject>
- (void)cellWithColorscheme:(CellWithColorscheme *)cell didSelectScheme:(AppearanceManagerColorscheme)scheme;
@end
