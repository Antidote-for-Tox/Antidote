//
//  LoginChoiceView.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 20/09/15.
//  Copyright © 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginChoiceView;
@protocol LoginChoiceViewDelegate <NSObject>

- (void)loginChoiceViewCreateAccountButtonPressed:(LoginChoiceView *)view;
- (void)loginChoiceViewImportProfileButtonPressed:(LoginChoiceView *)view;

@end

@interface LoginChoiceView : UIView

@property (weak, nonatomic) id<LoginChoiceViewDelegate> delegate;

@end
