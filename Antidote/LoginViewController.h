//
//  LoginViewController.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "KeyboardNotificationController.h"

@interface LoginViewController : KeyboardNotificationController

- (instancetype)initWithActiveProfile:(NSString *)activeProfile;

@end
