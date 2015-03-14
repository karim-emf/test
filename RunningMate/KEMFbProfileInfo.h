//
//  KEMFbProfileInfo.h
//  RunningMate
//
//  Created by Karim Mourra on 3/11/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KEMFbProfileInfo : NSManagedObject

@property (nonatomic, retain) NSString * fbRelationshipStatus;
@property (nonatomic, retain) NSString * fbProfilePic;
@property (nonatomic, retain) NSString * fbName;
@property (nonatomic, retain) NSString * fbLocation;
@property (nonatomic, retain) NSString * fbGender;
@property (nonatomic, retain) NSString * fbBirthDate;

@end
