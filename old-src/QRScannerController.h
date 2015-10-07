//
//  QRScannerController.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 11.12.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QRScannerController;

typedef void (^QRScannerControllerSuccessBlock)(QRScannerController *controller, NSArray *stringValues);
typedef void (^QRScannerControllerCancelBlock)(QRScannerController *controller);

@interface QRScannerController : UIViewController

@property (assign, nonatomic) BOOL pauseScanning;

+ (UINavigationController *)navigationWithScannerControllerWithSuccess:(QRScannerControllerSuccessBlock)success
                                                           cancelBlock:(QRScannerControllerCancelBlock)cancel;

@end
