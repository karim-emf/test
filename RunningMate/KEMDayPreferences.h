//
//  KEMDayPreferences.h
//  RunningMate
//
//  Created by Karim Mourra on 2/20/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>

@interface KEMDayPreferences : NSObject

@property (strong, nonatomic) NSDate* date;

@property (nonatomic) CGFloat startTime;
@property (nonatomic) CGFloat endTime;

@property (nonatomic) CGFloat durationMin;
@property (nonatomic) CGFloat durationMax;

@property (strong,nonatomic) NSString* distanceMin;
@property (strong,nonatomic) NSString* distanceMax;

@property (nonatomic) CLLocationCoordinate2D chosenCoords;
@property (nonatomic) NSInteger radiusTolerance;

@property (nonatomic) NSInteger conversationPreference;

@property (nonatomic) NSInteger personalMusicPreference;

@property (nonatomic) NSInteger partnerMusicPreference;

@property (nonatomic) NSInteger speedKmH;
@property (nonatomic) NSInteger speedToleranceKmH;

@end
