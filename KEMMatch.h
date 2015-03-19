//
//  KEMMatch.h
//  RunningMate
//
//  Created by Karim Mourra on 3/17/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KEMMatch : NSManagedObject

@property (nonatomic, retain) NSNumber * averageSpeedKmH;
@property (nonatomic, retain) NSNumber * chosenLatitude;
@property (nonatomic, retain) NSNumber * chosenLongitude;
@property (nonatomic, retain) NSNumber * conversationPreference;
@property (nonatomic, retain) NSNumber * distanceMax;
@property (nonatomic, retain) NSNumber * distanceMin;
@property (nonatomic, retain) NSNumber * durationMax;
@property (nonatomic, retain) NSNumber * durationMin;
@property (nonatomic, retain) NSNumber * endTime;
@property (nonatomic, retain) NSNumber * fastestSpeedKmH;
@property (nonatomic, retain) NSString * fbBirthDate;
@property (nonatomic, retain) NSString * fbGender;
@property (nonatomic, retain) NSString * fbLocation;
@property (nonatomic, retain) NSString * fbName;
@property (nonatomic, retain) NSString * fbProfilePic;
@property (nonatomic, retain) NSString * fbRelationshipStatus;
@property (nonatomic, retain) NSString * objID;
@property (nonatomic, retain) NSNumber * partnerMusicPreference;
@property (nonatomic, retain) NSNumber * personalMusicPreference;
@property (nonatomic, retain) NSNumber * radiusTolerance;
@property (nonatomic, retain) NSString * runDate;
@property (nonatomic, retain) NSNumber * slowestSpeedKmH;
@property (nonatomic, retain) NSNumber * startTime;

@end
