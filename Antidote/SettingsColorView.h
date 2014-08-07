//
//  SettingsColorView.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 07.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsColorView;
@protocol SettingsColorViewDelegate <NSObject>
- (void)settingsColorView:(SettingsColorView *)view didSelectScheme:(AppearanceManagerColorscheme)scheme;
@end

@interface SettingsColorView : UIView

@property (weak, nonatomic) id <SettingsColorViewDelegate> delegate;

- (CGSize)sizeThatFits:(CGSize)size;

@end
