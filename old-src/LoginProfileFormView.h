//
//  LoginProfileFormView.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 09/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginProfileFormView;
@protocol LoginProfileFormViewDelegate <NSObject>

- (void)loginProfileFormViewProfileButtonPressed:(LoginProfileFormView *)view;
- (void)loginProfileFormViewLoginButtonPressed:(LoginProfileFormView *)view;
- (void)loginProfileFormViewCreateAccountButtonPressed:(LoginProfileFormView *)view;
- (void)loginProfileFormViewImportProfileButtonPressed:(LoginProfileFormView *)view;

@end

/**
 * View with profile form, "Log In" button, "Create account" and "Import profile" buttons at the bottom.
 */
@interface LoginProfileFormView : UIView

@property (weak, nonatomic) id<LoginProfileFormViewDelegate> delegate;

@property (strong, nonatomic) NSString *profileString;
@property (strong, nonatomic) NSString *passwordString;

- (void)showPasswordField:(BOOL)show animated:(BOOL)animated;

- (CGFloat)loginButtonBottomY;

@end
