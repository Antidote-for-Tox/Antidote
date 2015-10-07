//
//  WizardViewController.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 22/09/15.
//  Copyright © 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizardViewController : UIViewController

@property (strong, nonatomic, readonly) UITextField *textField;

@property (copy, nonatomic) void (^returnKeyPressedBlock)(WizardViewController *controller);

@end
