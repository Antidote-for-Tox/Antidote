//
//  CellWithSwitch.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 05.01.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "CellWithSwitch.h"
#import "AppearanceManager.h"

@interface CellWithSwitch ()

@property (strong, nonatomic) UISwitch *theSwitch;

@end

@implementation CellWithSwitch

#pragma mark -  Lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        self.theSwitch = [UISwitch new];
        [self.theSwitch addTarget:self
                           action:@selector(valueChanged)
                 forControlEvents:UIControlEventValueChanged];


        self.accessoryView = self.theSwitch;
    }
    return self;
}

#pragma mark -  Properties

- (void)setTitle:(NSString *)title
{
    self.textLabel.text = title;
}

- (NSString *)title
{
    return self.textLabel.text;
}

- (void)setOn:(BOOL)on
{
    self.theSwitch.on = on;
}

- (BOOL)on
{
    return self.theSwitch.on;
}

#pragma mark -  Actions

- (void)valueChanged
{
    [self.delegate cellWithSwitchStateChanged:self];
}

@end
