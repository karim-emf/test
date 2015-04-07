//
//  KEMFirebaseLiaison.m
//  RunningMate
//
//  Created by Karim Mourra on 4/4/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "KEMFirebaseLiaison.h"
#import "KEMDataStore.h"
#import <Firebase/Firebase.h>

@interface KEMFirebaseLiaison ()

@property (strong, nonatomic) KEMDataStore* dataStore;

@end

@implementation KEMFirebaseLiaison

+ (instancetype)firebaseLiaisonSingleton
{
    static KEMFirebaseLiaison *_firebaseLiaison = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _firebaseLiaison = [[KEMFirebaseLiaison alloc] init];
    });
    
    return _firebaseLiaison;
}

-(void)registerForChatNotificationsOfActiveChats
{
    self.dataStore = [KEMDataStore sharedDataManager];
    [self.dataStore fetchMatches];
    
//    NSArray* matches = self.dataStore.matches;
    NSDictionary* matchesByDate =self.dataStore.matchesByDate;
    
    NSArray* matchDates = [matchesByDate allKeys];
    NSArray* sortedMatchDates = [matchDates sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSMutableArray* matches = [[NSMutableArray alloc]initWithArray:@[]];
    for (NSString* date in sortedMatchDates)
    {
        [matches addObject:date];
        [matches addObjectsFromArray:matchesByDate[date]];
    }
    
    for (NSInteger i=0; i<[matches count]; i++)
//    for (KEMMatch* match in matches)
    {
        if ([[matches[i] class] isSubclassOfClass:[KEMMatch class]])
        {
            KEMMatch* match = matches[i];
            NSString* fireBaseRoomName = [self makeFirebaseRoomNameFromDate:match.runDate MatchObjID:match.objID AndUserObjID:[PFUser currentUser].objectId];
        
            NSString* firebaseURL = [NSString stringWithFormat:@"https://runwithmeapp.firebaseio.com/%@", fireBaseRoomName];
            Firebase* firebaseRoom = [[Firebase alloc]initWithUrl:firebaseURL];
            
            //        [firebaseRoom observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
            [firebaseRoom observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot)
             {
                 if ([snapshot.value isKindOfClass:[NSDictionary class]])
                 {
                     NSDictionary* content = snapshot.value;//[@"content"];

                     [self setUpChatNotificationFromUser:content[@"user"] Saying:content[@"message"]];
                     NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
                     [notificationCenter postNotificationName:@"chatReceived" object:nil userInfo:@{@"row":@(i)}];
                 }
             }];
        }
    }
}



-(NSString*)makeFirebaseRoomNameFromDate:(NSString*)Date MatchObjID:(NSString*)matchObjID AndUserObjID:(NSString*)userObjID
{
    NSString* firstObjID;
    NSString* secondObjID;
    NSComparisonResult result = [matchObjID compare:userObjID];
    if (result == NSOrderedAscending)
    {
        firstObjID = matchObjID;
        secondObjID = userObjID;
    }
    else if (result == NSOrderedDescending)
    {
        firstObjID = userObjID;
        secondObjID = matchObjID;
    }
    else
    {
        NSLog(@"AAAAAAHHHHHHHHRRRRRRRGGGGGGGG !!!!!");
    }
    return [NSString stringWithFormat:@"%@-%@-%@",Date, firstObjID, secondObjID];
}

-(void) setUpChatNotificationFromUser:(NSString*)userName Saying:(NSString*)message
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification* chatNotification = [[UILocalNotification alloc]init];
    chatNotification.alertBody = [NSString stringWithFormat:@"%@: %@", userName, message];
    chatNotification.soundName = UILocalNotificationDefaultSoundName;
    
    //    if (self.inChatRoom)
    //                {
    //                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //                    [[UIApplication sharedApplication] cancelLocalNotification:chatNotification];
    //                }
    //
    //                if ( appState == UIApplicationStateBackground || appState == UIApplicationStateInactive)
    //                {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] presentLocalNotificationNow:chatNotification];
    //                }
    //    self.chatNotification.alertLaunchImage = @"appicon-60@3x";
}

@end
