//
//  ContentCellSimple.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 18/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ContentCell.h"

@interface ContentCellSimple : ContentCell

@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL boldTitle;
@property (strong, nonatomic) UIColor *titleColor;

@property (strong, nonatomic) NSString *detailTitle;

@property (strong, nonatomic) UIView *leftAccessoryView;
@property (assign, nonatomic) CGSize leftAccessoryViewSize;

@end
