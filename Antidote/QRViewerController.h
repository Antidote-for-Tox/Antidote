//
//  QRViewerController.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRViewerController : UIViewController

- (instancetype)initWithToxId:(NSString *)toxId;

- (instancetype)initWithText:(NSString *)text;

@end
