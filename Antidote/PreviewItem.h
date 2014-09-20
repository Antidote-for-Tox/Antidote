//
//  PreviewItem.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 20.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@interface PreviewItem : NSObject <QLPreviewItem>

@property (strong, readwrite) NSURL *previewItemURL;
@property (strong, readwrite) NSString *previewItemTitle;

@end
