//
//  ContentCellWithTitle.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 19/07/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "ContentCell.h"

@class ContentCellWithTitle;
@protocol ContentCellWithTitleDelegate <NSObject>
- (void)contentCellWithTitleDidPressButton:(ContentCellWithTitle *)cell;
@end

@interface ContentCellWithTitle : ContentCell

@property (weak, nonatomic) id<ContentCellWithTitleDelegate> delegate;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *buttonTitle;
@property (strong, nonatomic) NSString *mainText;

@end
