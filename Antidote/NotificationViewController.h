//
//  NotificationViewController.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 28.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotificationViewControllerDelegate <NSObject>

- (void)viewWillLayoutSubviews;

@end

@interface NotificationViewController : UIViewController

@property (weak, nonatomic) id<NotificationViewControllerDelegate> delegate;

@end
