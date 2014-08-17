//
//  ToxManagerFileProgressDelegate.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 17.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ToxManagerFileProgressDelegate <NSObject>

// progress from 0.0 to 1.0
- (void)toxManagerProgressChanged:(CGFloat)progress
     forPendingFileWithFileNumber:(uint16_t)fileNumber
                     friendNumber:(int32_t)friendNumber;

@end
