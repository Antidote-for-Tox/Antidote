//
//  ContentSeparatorCell.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 25/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ContentCell.h"

@interface ContentSeparatorCell : ContentCell

@property (assign, nonatomic) BOOL showGraySeparator;

- (void)setHeight:(CGFloat)height;

@end
