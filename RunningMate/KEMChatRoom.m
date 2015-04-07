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
    }
    return self;
}

-(void)fetchMessagesFromCloud:(FDataSnapshot *)snapshot withBlock:(void (^)(NSMutableArray *messages))completionBlock
{
    NSMutableArray *messagesArray=[[NSMutableArray alloc]init];
    
    if ([snapshot.value isKindOfClass:[NSDictionary class]])
    {
        [messagesArray addObject:snapshot.value];
    }
    completionBlock(messagesArray);
}

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

@end
