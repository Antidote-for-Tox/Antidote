//
//  ChatInputView.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 28.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatInputView;
@protocol ChatInputViewDelegate <NSObject>

- (void)chatInputViewWantsToUpdateFrame:(ChatInputView *)view;
- (void)chatInputView:(ChatInputView *)view sendButtonPressedWithText:(NSString *)text;
- (void)chatInputView:(ChatInputView *)view typingChangedTo:(BOOL)isTyping;

@end

@interface ChatInputView : UIView

@property (weak, nonatomic) id <ChatInputViewDelegate> delegate;

@property (assign, nonatomic) BOOL sendButtonEnabled;

- (void)setText:(NSString *)text;

- (CGFloat)heightWithCurrentTextAndWidth:(CGFloat)width;

@end
