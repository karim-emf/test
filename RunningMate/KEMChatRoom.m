//
//  KEMChatRoom.m
//  RunningMate
//
//  Created by Karim Mourra on 3/10/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "KEMChatRoom.h"

@implementation KEMChatRoom

-(instancetype)init
{
    self=[super init];
    if (self)
    {
        _messages=[[NSMutableArray alloc]init];
        [self setUpChatNotification];
    }
    return self;
}

-(void) setUpChatNotification
{
    self.chatNotification = [[UILocalNotification alloc]init];
    self.chatNotification.alertBody = [NSString stringWithFormat:@"You received a new message!"];
    self.chatNotification.soundName = UILocalNotificationDefaultSoundName;
//    self.chatNotification.alertLaunchImage = @"appicon-60@3x";
}

-(void)fetchMessagesFromCloud:(FDataSnapshot *)snapshot withBlock:(void (^)(NSMutableArray *messages))completionBlock
{
    NSMutableArray *messagesArray=[[NSMutableArray alloc]init];
    
    if ([snapshot.value isKindOfClass:[NSDictionary class]])
    {
        [messagesArray addObject:snapshot.value];
        
        
//        UIApplicationState appState = [[UIApplication sharedApplication] applicationState];
//        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        
//        if (! appDelegate.chatRoomVCDelegate.currentlyInRoom)
//        {
//            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//            [[UIApplication sharedApplication] cancelLocalNotification:self.chatNotification];
//        }
//        if ( appState == UIApplicationStateBackground || appState == UIApplicationStateInactive)
//        {
//            [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
//            [[UIApplication sharedApplication] presentLocalNotificationNow:self.chatNotification];
//        }
    }
    completionBlock(messagesArray);
}

//-(void)fetchUserCountFromCloud:(FDataSnapshot *)snapshot withBlock:(void (^)(NSNumber *count))completionBlock
//{
//    if (self.firstTimeInRoom)
//    {
//        if (snapshot.value == [NSNull null])
//        {
//            self.userCount = @1;
//        }
//        else
//        {
//            NSNumber* previousCount = snapshot.value[@"userCount"];
//            self.userCount = [NSNumber numberWithInteger:([previousCount integerValue] +1)];
//        }
//        [self.userCountFireBase setValue:@{@"userCount":self.userCount}];
//        self.firstTimeInRoom = false;
//    }
//    else
//    {
//        if (snapshot.value != [NSNull null])
//        {
//            self.userCount = snapshot.value[@"userCount"];
//        }
//    }
//    completionBlock(self.userCount);
//}

//-(void)setUpUserCountFireBaseWithCompletionBlock:(void (^)(BOOL completedCount))completionBlock
//{
//    self.userCountFireBase= [self.firebase childByAppendingPath:@"userCount"];
//    
//    [self.userCountFireBase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
//     {
//         [self fetchUserCountFromCloud:snapshot withBlock:^(NSNumber *count)
//          {
//              self.userCount = count;
//              completionBlock(YES);
//          }];
//     }];
//}

- (void)setupFirebaseWithCompletionBlock:(void (^)(BOOL completed))completionBlock
{
    self.firebaseURL = [NSString stringWithFormat:@"https://runwithmeapp.firebaseio.com/%@", self.firebaseRoomName];
    
    self.firebase = [[Firebase alloc] initWithUrl:self.firebaseURL];
    
    completionBlock(YES);
}

- (void)setUpContentFirebaseWithCompletionBlock:(void (^)(BOOL completed))completionBlock
{
    self.contentFireBase = [self.firebase childByAppendingPath:@"content"];
    
    [self.contentFireBase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [self fetchMessagesFromCloud:snapshot withBlock:^(NSMutableArray *messages)
         {
             //chat is received here
             [self.messages addObjectsFromArray:messages];
             
             completionBlock(YES);
         }];
    }];
}

//-(void)fetchNameSwitchFromCloud:(FDataSnapshot *)snapshot withBlock:(void (^)(NSDictionary* nameChange))isCompleted
//{
//    if (! (snapshot.value == [NSNull null]))
//    {
//        if ([snapshot.value[@"oldName"] isEqual:self.user.name])
//        {
//            self.user.name = snapshot.value[@"newName"];
//        }
//        isCompleted(snapshot.value);
//    }
//}

//-(void)setUpNameSwitchFireBaseWithCompletionBlock:(void (^)(NSDictionary* nameChange))completionBlock
//{
//    self.nameSwitchFireBase= [self.firebase childByAppendingPath:@"nameSwitch"];
//    
//    [self.nameSwitchFireBase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
//     {
//         [self fetchNameSwitchFromCloud:snapshot withBlock:^(NSDictionary *nameChange)
//          {
//              completionBlock(nameChange);
//          }];
//     }];
//}

@end
