//
//  FullscreenPicker.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 09/09/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Masonry/Masonry.h>
#import "FullscreenPicker.h"
#import "AppearanceManager.h"

static const CGFloat kAnimationDuration = 0.3;
static const CGFloat kToolbarHeight = 44.0;

@interface FullscreenPicker () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) UIButton *blackoutButton;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UIPickerView *picker;

@property (strong, nonatomic) MASConstraint *pickerBottomConstraint;

@property (strong, nonatomic) NSArray *stringsArray;

@end

@implementation FullscreenPicker

#pragma mark -  Lifecycle

- (instancetype)initWithStrings:(NSArray *)stringsArray selectedIndex:(NSUInteger)index
{
    self = [super init];

    if (! self) {
        return nil;
    }

    self.stringsArray = stringsArray;
    self.backgroundColor = [UIColor clearColor];

    self.blackoutButton = [UIButton new];
    self.blackoutButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    [self.blackoutButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.blackoutButton];

    self.toolbar = [UIToolbar new];
    self.toolbar.tintColor = [UIColor whiteColor];
    self.toolbar.barTintColor = [[AppContext sharedContext].appearance loginNavigationBarColor];
    self.toolbar.items = @[
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil],
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(doneButtonPressed)],
    ];
    [self addSubview:self.toolbar];

    self.picker = [UIPickerView new];
    self.picker.backgroundColor = [UIColor whiteColor];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    [self addSubview:self.picker];

    [self.picker selectRow:index inComponent:0 animated:NO];

    [self installConstraints];

    return self;
}

#pragma mark -  Actions

- (void)doneButtonPressed
{
    [self.delegate fullscreenPicker:self willDismissWithSelectedIndex:[self selectedRow]];

    [self hide];
}

#pragma mark -  Public

- (void)showAnimatedInView:(UIView *)view
{
    [view addSubview:self];
    [self makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];

    [self show];
}

#pragma mark -  UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.stringsArray.count;
}

#pragma mark -  UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.stringsArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.picker reloadAllComponents];
}

#pragma mark -  Private

- (void)installConstraints
{
    [self.blackoutButton makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [self.toolbar makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.picker.top);
        make.height.equalTo(kToolbarHeight);
        make.width.equalTo(self);
    }];

    [self.picker makeConstraints:^(MASConstraintMaker *make) {
        self.pickerBottomConstraint = make.bottom.equalTo(self);
    }];
}

- (void)show
{
    self.blackoutButton.alpha = 0.0;
    self.pickerBottomConstraint.offset(self.picker.frame.size.height);

    [self layoutIfNeeded];

    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.blackoutButton.alpha = 1.0;
        self.pickerBottomConstraint.offset(0.0);

        [self layoutIfNeeded];
    }];
}

- (void)hide
{
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.blackoutButton.alpha = 0.0;
        self.pickerBottomConstraint.offset(self.picker.frame.size.height);

        [self layoutIfNeeded];

    } completion:^(BOOL f) {
        [self removeFromSuperview];
    }];
}

- (NSInteger)selectedRow
{
    return [self.picker selectedRowInComponent:0];
}

@end
