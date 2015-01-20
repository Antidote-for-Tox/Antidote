//
//  ChatBackgroundsCollectionvViewCell.h
//  Antidote
//
//  Created by Nikolay Palamar on 12/01/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatBackgroundsCollectionvViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic, getter=isCheked) BOOL cheked;

+ (NSString *)reusableIdentifier;

@end