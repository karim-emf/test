//
//  KEMDataStore.m
//  RunningMate
//
//  Created by Karim Mourra on 2/20/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "KEMDataStore.h"



@implementation KEMDataStore
@synthesize managedObjectContext = _managedObjectContext;

+ (instancetype)sharedDataManager {
    static KEMDataStore *_sharedDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataManager = [[KEMDataStore alloc] init];
    });
    
    return _sharedDataManager;
}

-(KEMDailyPreference*)createDailyPreference
{
    KEMDailyPreference* daysPreference = [NSEntityDescription insertNewObjectForEntityForName:@"KEMDailyPreference" inManagedObjectContext:self.managedObjectContext];
    

    //note! may have to change this to string Date seen below
    NSString* date = [self obtainDateStringDDMMYYYY];
    
    
    if (! self.dailyPreferences)
    {
        self.dailyPreferences = [NSMutableDictionary new];
    }
    else
    {
        KEMFbProfileInfo* fbProfileInfo = [self fetchFbProfileInfo];
        
        daysPreference.runDate =  date;
        
        daysPreference.fbName = fbProfileInfo.fbName;
        daysPreference.fbLocation = fbProfileInfo.fbLocation;
        daysPreference.fbGender = fbProfileInfo.fbGender;
        daysPreference.fbBirthDate = fbProfileInfo.fbBirthDate;
        daysPreference.fbRelationshipStatus = fbProfileInfo.fbRelationshipStatus;
        daysPreference.fbProfilePic = fbProfileInfo.fbProfilePic;
    }
    
    [self.dailyPreferences setObject:daysPreference forKey:date];

    return daysPreference;
}

-(KEMChatMessage*)createChatMessage:(NSString*)content From:(NSString*)sender For:(NSString*)chatRoomCode Dated:(NSDate*)dateSent
{
    KEMChatMessage* chatMessage = [NSEntityDescription insertNewObjectForEntityForName:@"KEMChatMessage" inManagedObjectContext:self.managedObjectContext];
    chatMessage.content = content;
    chatMessage.sender = sender;
    chatMessage.chatRoomCode = chatRoomCode;
    chatMessage.dateSent = dateSent;
    
    [self saveContextWithoutPushingToParse];
    return chatMessage;
}

-(NSArray*)fetchChatMessages
{
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"KEMChatMessage"];
    NSArray* chatMessages = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return chatMessages;
}

-(NSArray*)fetchChatMessagesForChatRoom:(NSString*)chatRoomCode
{
    NSArray* messages = [self fetchChatMessages];
    
    NSPredicate *chatRoomCodePredicate = [NSPredicate predicateWithFormat:@"chatRoomCode == %@", chatRoomCode];
    NSArray *filteredArrayByChatCode = [messages filteredArrayUsingPredicate:chatRoomCodePredicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateSent" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];

    NSArray *sortedArray = [filteredArrayByChatCode sortedArrayUsingDescriptors:sortDescriptors];
    
    NSMutableArray* arrayOfMessageDictionnaries = [NSMutableArray new];
    
    for (KEMChatMessage* chatMessage in sortedArray)
    {
        NSDictionary* message = @{@"message":chatMessage.content,
                                  @"user":chatMessage.sender};
        [arrayOfMessageDictionnaries addObject:message];
    }
    
    return arrayOfMessageDictionnaries;
}

-(NSString*)obtainDateStringDDMMYYYY
{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *year = [formatter stringFromDate:now];
    [formatter setDateFormat:@"MM"];
    NSString *month = [formatter stringFromDate:now];
    [formatter setDateFormat:@"dd"];
    NSString *day = [formatter stringFromDate:now];
    NSString *date = [day stringByAppendingFormat:@"-%@-%@", month, year];
    return date;
}

-(void)addTimeRange:(NSNumber*)lowerValue And: (NSNumber*)upperValue ToPreferenceFor:(NSString*)day
{
    KEMDailyPreference* dailyPreference = [self.dailyPreferences objectForKey:day];
    dailyPreference.startTime = lowerValue;
    dailyPreference.endTime = upperValue;
    [self saveContext];
}

-(void)addDurationMinTime:(NSNumber*)lowerValue AndMaxTime: (NSNumber*)upperValue ToPreferenceFor:(NSString*)day
{
    KEMDailyPreference* dailyPreference = [self.dailyPreferences objectForKey:day];
    dailyPreference.durationMin = lowerValue;
    dailyPreference.durationMax = upperValue;
    [self saveContext];
}

-(void)addDistanceFrom:(NSNumber*)distanceMin To: (NSNumber*)distanceMax ToPreferenceFor:(NSString*)day
{
    KEMDailyPreference* dailyPreference = [self.dailyPreferences objectForKey:day];
    dailyPreference.distanceMin = distanceMin;
    dailyPreference.distanceMax = distanceMax;
    [self saveContext];
}

-(void)addLocationLatitude:(NSNumber*)latitude Longitude:(NSNumber*)longitude AndRadius:(NSNumber*)radius ToPreferenceFor:(NSString*)day
{
    KEMDailyPreference* dailyPreference = [self.dailyPreferences objectForKey:day];
    
    //decimals (about 10) are lost when saved to daily preference !!!!!
    
    dailyPreference.chosenLatitude = latitude;
    dailyPreference.chosenLongitude = longitude;
    dailyPreference.radiusTolerance = radius;
    [self saveContext];
}

-(void)addConversationResponse:(NSNumber*)response ToPreferenceFor:(NSString*)day
{
    KEMDailyPreference* dailyPreference = [self.dailyPreferences objectForKey:day];
    dailyPreference.conversationPreference = response;
    [self saveContext];
}

-(void)addPersonalMusicResponse:(NSNumber*)response ToPreferenceFor:(NSString*)day
{
    KEMDailyPreference* dailyPreference = [self.dailyPreferences objectForKey:day];
    dailyPreference.personalMusicPreference = response;
    [self saveContext];
}

-(void)addPartnerMusicResponse:(NSNumber*)response ToPreferenceFor:(NSString*)day
{
    KEMDailyPreference* dailyPreference = [self.dailyPreferences objectForKey:day];
    dailyPreference.partnerMusicPreference = response;
    [self saveContext];
}

-(void)addAverageSpeedUnit:(NSString*)speedUnit AndSpeedDecimal:(NSString*)speedDecimal ToPreferenceFor:(NSString*)day
{
    NSString* combinedSpeed = [speedUnit stringByAppendingFormat:@".%@",speedDecimal];
    KEMDailyPreference* dailyPreference = [self.dailyPreferences objectForKey:day];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    dailyPreference.averageSpeedKmH = [formatter numberFromString:combinedSpeed];
    
    [self saveContext];
}

-(void)addFastestSpeedUnit:(NSString*)speedUnit AndSpeedDecimal:(NSString*)speedDecimal ToPreferenceFor:(NSString*)day
{
    NSString* combinedSpeed = [speedUnit stringByAppendingFormat:@".%@",speedDecimal];
    KEMDailyPreference* dailyPreference = [self.dailyPreferences objectForKey:day];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    dailyPreference.fastestSpeedKmH = [formatter numberFromString:combinedSpeed];
    
    [self saveContext];
}

-(void)addSlowestSpeedUnit:(NSString*)speedUnit AndSpeedDecimal:(NSString*)speedDecimal ToPreferenceFor:(NSString*)day
{
    NSString* combinedSpeed = [speedUnit stringByAppendingFormat:@".%@",speedDecimal];
    KEMDailyPreference* dailyPreference = [self.dailyPreferences objectForKey:day];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    dailyPreference.slowestSpeedKmH = [formatter numberFromString:combinedSpeed];
    
    [self saveContext];
}

-(void)addUserName:(NSString*)fbName UserCity:(NSString*)fbCity UserGender:(NSString*)fbGender UserDOB:(NSString*)fbDOB UserRelationship:(NSString*)fbRelationship AndProfilePicture:(NSString*)fbProfilePic ForDate:(NSString*)date
{
    KEMFbProfileInfo* fbProfileInfo = [NSEntityDescription insertNewObjectForEntityForName:@"KEMFbProfileInfo" inManagedObjectContext:self.managedObjectContext];
    fbProfileInfo.fbName = fbName;
    fbProfileInfo.fbLocation = fbCity;
    fbProfileInfo.fbGender = fbGender;
    fbProfileInfo.fbBirthDate = fbDOB;
    fbProfileInfo.fbRelationshipStatus = fbRelationship;
    fbProfileInfo.fbProfilePic = fbProfilePic;
    
    KEMDailyPreference* dailyPreference;
    
    if (! [self.dailyPreferences objectForKey:date])
    {
        dailyPreference = [self createDailyPreference];
    }
    else
    {
        dailyPreference = [self.dailyPreferences objectForKey:date];
    }
    
    if (! dailyPreference.fbName)
    {
        dailyPreference.fbName = fbName;
        dailyPreference.fbLocation = fbCity;
        dailyPreference.fbGender = fbGender;
        dailyPreference.fbBirthDate = fbDOB;
        dailyPreference.fbRelationshipStatus = fbRelationship;
        dailyPreference.fbProfilePic = fbProfilePic;
    }
    [self saveContext];
//    [self saveContextWithoutPushingToParse];
}

-(void)fetchPreferencesOf:(NSString*)day
// will we be returning preferences of the specified day ?
{
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"KEMDailyPreference"];
    
    NSArray* dailyPreferences = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    self.fetchedDailyPreferences = [[NSMutableArray alloc]initWithArray:dailyPreferences];
    
    
    self.dailyPreferences = [[NSMutableDictionary alloc]init];
    for (KEMDailyPreference* dayPreference in self.fetchedDailyPreferences)
    {
        [self.dailyPreferences setObject:dayPreference forKey:dayPreference.runDate];
    }
}

-(KEMFbProfileInfo*)fetchFbProfileInfo
{
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"KEMFbProfileInfo"];
    NSArray* fbProfiles = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return [fbProfiles lastObject];
}


-(void)fetchMatches
{
    self.matchesByDate = [NSMutableDictionary new];
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"KEMMatch"];
    NSArray* fetchedMatches = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    self.matches = [NSMutableArray arrayWithArray:fetchedMatches];
    
    for (KEMMatch* match in fetchedMatches)
    {
        if (self.matchesByDate[match.runDate])
        {
            [ ((NSMutableArray*) self.matchesByDate[match.runDate]) addObject:match];
        }
        else
        {
            [self.matchesByDate setObject:[NSMutableArray arrayWithObject:match] forKey:match.runDate];
        }
    }
}


-(id)returnNSNullIfNil:(id)object
{
    if (object)
    {
        return object;
    }
    else
    {
        return [NSNull null];
    }
}

-(void)pushPreferencesToParse
{
    NSString* date = [self obtainDateStringDDMMYYYY];
    
    KEMDailyPreference* dailyPreference = [self.dailyPreferences objectForKey:date];
    PFGeoPoint* geoPoint = [self createGeoPointWithLatitude:dailyPreference.chosenLatitude AndLongitude:dailyPreference.chosenLongitude];
    
    if (dailyPreference.objID)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"Preferences"];
        
        // Retrieve the object by id
        [query getObjectInBackgroundWithId:dailyPreference.objID block:^(PFObject *preference, NSError *error)
        {
            [self setDailyPreferences:dailyPreference AndGeoPoint:geoPoint ForPreference:preference];
            [preference saveEventually:^(BOOL succeeded, NSError *error)
             {
                    [self checkForMatchesComparingDate:date GeoPoint:geoPoint AndDailyPreference:dailyPreference];
            }];
        }];
    }
    else
    {
        PFObject *preference = [PFObject objectWithClassName:@"Preferences"];
        PFUser* currentUser = [PFUser currentUser];

        if (currentUser)
        {
            preference[@"user"] = currentUser;
            [self setDailyPreferences:dailyPreference AndGeoPoint:geoPoint ForPreference:preference];
            
            [preference saveEventually:^(BOOL succeeded, NSError *error)
             {
                 if (succeeded)
                 {
                     [self obtainObjectIdForDailyPreference:dailyPreference];
                 }
             }];
        }
    }


}

-(void)obtainObjectIdForDailyPreference:(KEMDailyPreference*)dailyPreference
{
    NSString* date = [self obtainDateStringDDMMYYYY];
    [PFCloud callFunctionInBackground:@"obtainObjectIDForUserAtDate"
                       withParameters:@{@"date": date}
                                block:^(PFObject *result, NSError *error)
     {
         if (!error)
         {
             if (result.objectId)
             {
                 dailyPreference.objID = result.objectId;
                 [self saveContextWithoutPushingToParse];
             }
             
             
             //when it comes to adding dates, make a dictionnary pairing dates to objectId
         }
         else
         {
             NSLog(@"no funciona!");
         }
     }];

}

-(PFGeoPoint*)createGeoPointWithLatitude:(NSNumber*)latitutde AndLongitude:(NSNumber*)longitude
{
    PFGeoPoint* geoPoint = [PFGeoPoint geoPointWithLatitude:[latitutde doubleValue] longitude:[longitude doubleValue]];
    return geoPoint;
}

-(void)setDailyPreferences:(KEMDailyPreference*)dailyPreference AndGeoPoint:(PFGeoPoint*)geoPoint ForPreference:(PFObject*)preference
{
    preference[@"location"] = [self returnNSNullIfNil:geoPoint];
    
    preference[@"startTime"] = [self returnNSNullIfNil:dailyPreference.startTime];
    preference[@"endTime"] = [self returnNSNullIfNil:dailyPreference.endTime];
    preference[@"durationMin"] = [self returnNSNullIfNil:dailyPreference.durationMin];
    preference[@"durationMax"] = [self returnNSNullIfNil:dailyPreference.durationMax];
    preference[@"distanceMin"] = [self returnNSNullIfNil:dailyPreference.distanceMin];
    preference[@"distanceMax"] = [self returnNSNullIfNil:dailyPreference.distanceMax];
    preference[@"latitude"] = [self returnNSNullIfNil:dailyPreference.chosenLatitude];
    preference[@"longitude"] = [self returnNSNullIfNil:dailyPreference.chosenLongitude];
    preference[@"radius"] = [self returnNSNullIfNil:dailyPreference.radiusTolerance];
    preference[@"conversation"] = [self returnNSNullIfNil:dailyPreference.conversationPreference];
    preference[@"personalMusic"] = [self returnNSNullIfNil:dailyPreference.personalMusicPreference];
    preference[@"partnerMusic"] = [self returnNSNullIfNil:dailyPreference.partnerMusicPreference];
    preference[@"averageSpeed"] = [self returnNSNullIfNil:dailyPreference.averageSpeedKmH];
    preference[@"slowestSpeed"] = [self returnNSNullIfNil:dailyPreference.slowestSpeedKmH];
    preference[@"fastestSpeed"] = [self returnNSNullIfNil:dailyPreference.fastestSpeedKmH];
    preference[@"date"] = [self returnNSNullIfNil:dailyPreference.runDate];
    
    preference[@"fbName"] = [self returnNSNullIfNil:dailyPreference.fbName];
    preference[@"fbCity"] = [self returnNSNullIfNil:dailyPreference.fbLocation];
    preference[@"fbGender"] = [self returnNSNullIfNil:dailyPreference.fbGender];
    preference[@"fbBirthDate"] = [self returnNSNullIfNil:dailyPreference.fbBirthDate];
    preference[@"fbRelationship"] = [self returnNSNullIfNil:dailyPreference.fbRelationshipStatus];
    
    if (self.profilePicInString)
    {
        preference[@"fbProfilePic"] = self.profilePicInString;
    }
}

-(NSDictionary*)createParametersFrom:(KEMDailyPreference*)dailyPreference AndGeoPoint:(PFGeoPoint*)geoPoint ForDate:(NSString*)date
{
    return @{@"date": date,
             @"distanceMin":[self returnNSNullIfNil:dailyPreference.distanceMin],
             @"distanceMax":[self returnNSNullIfNil:dailyPreference.distanceMax],
             @"durationMin":[self returnNSNullIfNil:dailyPreference.durationMin],
             @"durationMax":[self returnNSNullIfNil:dailyPreference.durationMax],
             @"startTime":[self returnNSNullIfNil:dailyPreference.startTime],
             @"endTime":[self returnNSNullIfNil:dailyPreference.endTime],
             @"conversation":[self returnNSNullIfNil:dailyPreference.conversationPreference],
             @"personalMusic":[self returnNSNullIfNil:dailyPreference.personalMusicPreference],
             @"partnerMusic":[self returnNSNullIfNil:dailyPreference.partnerMusicPreference],
             @"averageSpeed":[self returnNSNullIfNil:dailyPreference.averageSpeedKmH],
             @"slowestSpeed":[self returnNSNullIfNil:dailyPreference.slowestSpeedKmH],
             @"fastestSpeed":[self returnNSNullIfNil:dailyPreference.fastestSpeedKmH],
             @"location":[self returnNSNullIfNil:geoPoint],
             @"radius":[self returnNSNullIfNil:dailyPreference.radiusTolerance]};
}

-(void)checkForMatchesComparingDate:(NSString*)date GeoPoint:(PFGeoPoint*)geoPoint AndDailyPreference:(KEMDailyPreference*)dailyPreference
{
    [PFCloud callFunctionInBackground:@"findMatches"
                       withParameters:[self createParametersFrom:dailyPreference AndGeoPoint:geoPoint ForDate:date]
                                block:^(NSArray *results, NSError *error)
     {
         if (!error)
         {
             //receiving an array containing PFObjects
             //result[0][@"location"] to access its geoPoint
             NSLog(@"----------- %@", results);
             
             for (PFObject* result in results)
             {
                 PFGeoPoint* geoPointOfMatch = result[@"location"];
                 CGFloat radiusOfMatch = [result[@"radius"] floatValue];
                 CGFloat matchDistance = [geoPoint distanceInKilometersTo:geoPointOfMatch];
                 CGFloat tolerableDistance = [dailyPreference.radiusTolerance floatValue] + radiusOfMatch;
                 
                 if (matchDistance <= tolerableDistance)
                 {
//                     KEMMatch* match = [self createKEMMatchFromResult:result];
                     [self checkForDuplicatesBeforeMakingMatchFromResult:result];
//                     [self checkForDuplicatedAndAddMatch:match];
                 }
             }
             //             return matches;
             //when it comes to adding dates, make a dictionnary pairing dates to objectId
         }
         else
         {
             NSLog(@"no funciona!");
         }
     }];
}

-(void)checkForDuplicatesBeforeMakingMatchFromResult:(PFObject*)result
{
    if ( ! self.matches)
    {
        [self fetchMatches];
    }

    
    PFUser* user = result[@"user"];
    
    NSPredicate *objIdPredicate = [NSPredicate predicateWithFormat:@"objID == %@", user.objectId];
    NSArray *filteredArrayByObjId = [self.matches filteredArrayUsingPredicate:objIdPredicate];
    
    NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"runDate == %@", result[@"date"]];
    NSArray *filteredArrayByDateAndObjId = [filteredArrayByObjId filteredArrayUsingPredicate:datePredicate];
    
    if ([filteredArrayByDateAndObjId count] > 0)
    {
        NSInteger matchIndex=[self.matches indexOfObject:filteredArrayByDateAndObjId[0]];
        
        [self updateExistingMatch:self.matches[matchIndex] WithResult:result];
        //instead of deleting how about updating?
        
//        [self.managedObjectContext deleteObject:self.matches[matchIndex]];
//        self.matches[matchIndex] = match;
        
        NSInteger matchIndexInMatchDate = [self.matchesByDate[result[@"date"]] indexOfObject:filteredArrayByDateAndObjId[0]];
        self.matchesByDate[result[@"date"]][matchIndexInMatchDate] = self.matches[matchIndex];
    }
    else
    {
        KEMMatch* match = [self createKEMMatchFromResult:result];
        [self saveContextWithoutPushingToParse];
        
        [self.matches addObject:match];
        
        if (self.matchesByDate[result[@"date"]])
        {
            [ ((NSMutableArray*) self.matchesByDate[result[@"date"]]) addObject:match];
        }
        else
        {
            [self.matchesByDate setObject:[NSMutableArray arrayWithObject:match] forKey:result[@"date"]];
        }
        
        if (self.notificationFromParse)
        {
            self.notificationFromParse = NO;
        }
        else
        {
            [self notifyThatMatchEventOccurredWithTitle:@"You have a new match!" AndMessage:@"Tap the Matches icon to find out who it is!"];
            [self notifyMatchThatHeMustCheckMatches:user];
            
            NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:@"newMatch" object:nil];
        }
    }
}

-(void)notifyMatchThatHeMustCheckMatches:(PFUser*)matchUser
{
    PFQuery* matchNotificationQuery = [PFInstallation query];
    [matchNotificationQuery whereKey:@"user" equalTo:matchUser];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:matchNotificationQuery];
    
    //if you change this, change the filter in appDelegate !!!!!
/*if you change this, change the filter in appDelegate !!!!!*/ [push setMessage:@"You have a new match!"]; //if you change this, change the filter in appDelegate !!!!!
    //if you change this, change the filter in appDelegate !!!!!
    
    [push sendPushInBackground];

}

-(void)updateExistingMatch:(KEMMatch*)match WithResult:(PFObject*)result
{
    PFUser* user = result[@"user"];
    
    match.objID = user.objectId;
    match.conversationPreference = result[@"conversation"];
    match.runDate = result[@"date"];
    match.durationMax = result[@"durationMax"];
    match.durationMin = result[@"durationMin"];
    match.endTime = result[@"endTime"];
    match.chosenLatitude = result[@"latitude"];
    match.chosenLongitude = result[@"longitude"];
    match.partnerMusicPreference = result[@"partnerMusic"];
    match.personalMusicPreference = result[@"personalMusic"];
    match.radiusTolerance = result[@"radius"];
    match.startTime = result[@"startTime"];
    match.averageSpeedKmH = result[@"averageSpeed"];
    match.distanceMax = result[@"distanceMax"];
    match.distanceMin = result[@"distanceMin"];
    match.fastestSpeedKmH = result[@"fastestSpeed"];
    match.slowestSpeedKmH = result[@"slowestSpeed"];
    
    match.fbName = result[@"fbName"];
    match.fbLocation = result[@"fbCity"];
    match.fbGender = result[@"fbGender"];
    match.fbBirthDate = result[@"fbBirthDate"];
    match.fbRelationshipStatus = result[@"fbRelationship"];
    match.fbProfilePic= result[@"fbProfilePic"];
    
    [self saveContextWithoutPushingToParse];
}

-(KEMMatch*)createKEMMatchFromResult:(PFObject*)result
{
    KEMMatch* match = [NSEntityDescription insertNewObjectForEntityForName:@"KEMMatch" inManagedObjectContext:self.managedObjectContext];
    
    PFUser* user = result[@"user"];
    
    match.objID = user.objectId;
    match.conversationPreference = result[@"conversation"];
    match.runDate = result[@"date"];
    match.durationMax = result[@"durationMax"];
    match.durationMin = result[@"durationMin"];
    match.endTime = result[@"endTime"];
    match.chosenLatitude = result[@"latitude"];
    match.chosenLongitude = result[@"longitude"];
    match.partnerMusicPreference = result[@"partnerMusic"];
    match.personalMusicPreference = result[@"personalMusic"];
    match.radiusTolerance = result[@"radius"];
    match.startTime = result[@"startTime"];
    match.averageSpeedKmH = result[@"averageSpeed"];
    match.distanceMax = result[@"distanceMax"];
    match.distanceMin = result[@"distanceMin"];
    match.fastestSpeedKmH = result[@"fastestSpeed"];
    match.slowestSpeedKmH = result[@"slowestSpeed"];
    
    match.fbName = result[@"fbName"];
    match.fbLocation = result[@"fbCity"];
    match.fbGender = result[@"fbGender"];
    match.fbBirthDate = result[@"fbBirthDate"];
    match.fbRelationshipStatus = result[@"fbRelationship"];
    match.fbProfilePic= result[@"fbProfilePic"];

    return match;
}
-(void)checkForDuplicatedAndAddMatch:(KEMMatch*)match
//no longer used because we want to check for duplicate before creating a match
{
    if ( ! self.matches)
    {
        [self fetchMatches];
    }

        NSPredicate *objIdPredicate = [NSPredicate predicateWithFormat:@"objID == %@", match.objID];
        NSArray *filteredArrayByObjId = [self.matches filteredArrayUsingPredicate:objIdPredicate];
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"runDate == %@", match.runDate];
        NSArray *filteredArrayByDate = [filteredArrayByObjId filteredArrayUsingPredicate:datePredicate];
        
        if ([filteredArrayByDate count] > 0)
        {
            NSInteger matchIndex=[self.matches indexOfObject:filteredArrayByDate[0]];
            [self.managedObjectContext deleteObject:self.matches[matchIndex]];
            self.matches[matchIndex] = match;
            
            NSInteger matchIndexInMatchDate = [self.matchesByDate[match.runDate] indexOfObject:filteredArrayByDate[0]];
            self.matchesByDate[match.runDate][matchIndexInMatchDate] = match;
        }
        else
        {
            [self.matches addObject:match];
            
            if (self.matchesByDate[match.runDate])
            {
                [ ((NSMutableArray*) self.matchesByDate[match.runDate]) addObject:match];
            }
            else
            {
                [self.matchesByDate setObject:[NSMutableArray arrayWithObject:match] forKey:match.runDate];
            }
            [self notifyThatMatchEventOccurredWithTitle:@"You have a new match!" AndMessage:@"Tap the Matches icon to find out who it is!"];
            
        }
//    }
}

-(void) notifyThatMatchEventOccurredWithTitle:(NSString*)title AndMessage:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Awesome!", nil];
    [alert show];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
//    if ([PFUser currentUser])
//    {
//        [self pushPreferencesToParse];
//    }
}

- (void)saveContextWithoutPushingToParse
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }

}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"runningMate.sqlite"];
    
    NSError *error = nil;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
