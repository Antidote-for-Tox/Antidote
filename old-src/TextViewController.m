//
//  TextViewController.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 09/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "TextViewController.h"
#import "UIViewController+Utilities.h"

static const CGFloat kOffset = 10.0;

@interface TextViewController ()

@property (strong, nonatomic) UITextView *textView;

@end

@implementation TextViewController

#pragma mark -  Lifecycle

- (void)loadView
{
    [self loadWhiteView];

    self.textView = [UITextView new];
    self.textView.userInteractionEnabled = NO;
    self.textView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.textView];

    [self.textView makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view).offset(kOffset);
        make.right.bottom.equalTo(self.view).offset(-kOffset);
    }];
};

#pragma mark -  Properties

- (void)setHtml:(NSString *)html
{
    _html = html;

    NSData *data = [html dataUsingEncoding:NSUnicodeStringEncoding];
    NSDictionary *options = @{
        NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,
    };

    self.textView.attributedText = [[NSAttributedString alloc] initWithData:data
                                                                    options:options
                                                         documentAttributes:nil
                                                                      error:nil];
}

- (void)setBackgroundColor:(UIColor *)color
{
    _backgroundColor = color;
    self.view.backgroundColor = color;
}

@end
