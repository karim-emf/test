//
//  KEMDataStore.h
//  RunningMate
//
//  Created by Karim Mourra on 2/20/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreGraphics/CoreGraphics.h>
#import "KEMDailyPreference.h"
#import "KEMMatch.h"
#import "KEMFbProfileInfo.h"
#import <Parse/Parse.h>
#import "KEMChatMessage.h"

@interface KEMDataStore : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSMutableDictionary* dailyPreferences;
@property (strong, nonatomic) NSMutableArray* fetchedDailyPreferences;

@property (strong, nonatomic) NSMutableArray* matches;
@property (strong, nonatomic) NSMutableDictionary* matchesByDate;

//@property (strong, nonatomic) PFObject *testObject;
@property (strong, nonatomic) NSString* objectID;
@property (strong, nonatomic) NSString* profilePicInString;

@property (nonatomic) BOOL notificationFromParse;

+ (instancetype)sharedDataManager;

-(KEMDailyPreference*)createDailyPreference;
-(void)addTimeRange:(NSNumber*)lowerValue And: (NSNumber*)upperValue ToPreferenceFor:(NSString*)day;
-(void)addDurationMinTime:(NSNumber*)lowerValue AndMaxTime: (NSNumber*)upperValue ToPreferenceFor:(NSString*)day;
-(void)addDistanceFrom:(NSNumber*)distanceMin To: (NSNumber*)distanceMax ToPreferenceFor:(NSString*)day;
-(void)addLocationLatitude:(NSNumber*)latitude Longitude:(NSNumber*)longitude AndRadius:(NSNumber*)radius ToPreferenceFor:(NSString*)day;
-(void)addConversationResponse:(NSNumber*)response ToPreferenceFor:(NSString*)day;
-(void)addPersonalMusicResponse:(NSNumber*)response ToPreferenceFor:(NSString*)day;
-(void)addPartnerMusicResponse:(NSNumber*)response ToPreferenceFor:(NSString*)day;
-(void)addAverageSpeedUnit:(NSString*)speedUnit AndSpeedDecimal:(NSString*)speedDecimal ToPreferenceFor:(NSString*)day;
-(void)addFastestSpeedUnit:(NSString*)speedUnit AndSpeedDecimal:(NSString*)speedDecimal ToPreferenceFor:(NSString*)day;
-(void)addSlowestSpeedUnit:(NSString*)speedUnit AndSpeedDecimal:(NSString*)speedDecimal ToPreferenceFor:(NSString*)day;
-(void)addUserName:(NSString*)fbName UserCity:(NSString*)fbCity UserGender:(NSString*)fbGender UserDOB:(NSString*)fbDOB UserRelationship:(NSString*)fbRelationship AndProfilePicture:(NSString*)fbProfilePic ForDate:(NSString*)date;

-(void)fetchPreferencesOf:(NSString*)day;
-(KEMFbProfileInfo*)fetchFbProfileInfo;
-(void)fetchMatches;

-(KEMChatMessage*)createChatMessage:(NSString*)content From:(NSString*)sender For:(NSString*)chatRoomCode Dated:(NSDate*)dateSent;
-(NSArray*)fetchChatMessagesForChatRoom:(NSString*)chatRoomCode;

-(void)pushPreferencesToParse;

@end
