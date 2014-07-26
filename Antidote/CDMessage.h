//
//  CDMessage.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 26.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CDMessage : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * isIncoming;
@property (nonatomic, retain) NSString * friendClientId;

@end
