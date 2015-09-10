//
//  CreateAccountSectionView.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 09/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CreateAccountSectionView;
@protocol CreateAccountSectionViewDelegate <NSObject>

- (BOOL)createAccountSectionViewShouldReturn:(CreateAccountSectionView *)view;

@end


@interface CreateAccountSectionView : UIView

@property (weak, nonatomic) id<CreateAccountSectionViewDelegate> delegate;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *placeholder;
@property (strong, nonatomic) NSString *text;
@property (assign, nonatomic) NSUInteger maxTextUTF8Length;
@property (strong, nonatomic) NSString *hint;

@property (assign, nonatomic) UIReturnKeyType returnKeyType;

- (BOOL)becomeFirstResponder;

@end
