//
//  FriendsFilterView.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 13.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FriendsFilterView;
@protocol FriendsFilterViewDelegate <NSObject>
- (void)friendsFilterView:(FriendsFilterView *)view didSelectStringAtIndex:(NSUInteger)index;
- (void)friendsFilterViewEmptySpacePressed:(FriendsFilterView *)view;
@end

@interface FriendsFilterView : UIView

@property (weak, nonatomic) id <FriendsFilterViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame stringsArray:(NSArray *)stringsArray;

- (CGFloat)heightOfVisiblePart;

@end
