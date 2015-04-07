//
//  KEMChatRoom.h
//  RunningMate
//
//  Created by Karim Mourra on 3/10/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import "KEMMatch.h"
#import <UIKit/UIKit.h>

@interface KEMChatRoom : NSObject

@property(strong,nonatomic) KEMMatch* user;
@property(strong,nonatomic)NSMutableArray *messages;
@property(strong,nonatomic)NSString *firebaseRoomName;
@property(strong,nonatomic)NSString *firebaseURL;
@property(strong,nonatomic)Firebase *firebase;

@property(strong,nonatomic)Firebase *userCountFireBase;
@property(strong,nonatomic)Firebase *contentFireBase;
@property(strong,nonatomic)Firebase *nameSwitchFireBase;
@property(strong,nonatomic)NSNumber* userCount;
@property(nonatomic) BOOL firstTimeInRoom;

@property(strong,nonatomic)NSString *matchName;

-(instancetype)init;

-(void)setupFirebaseWithCompletionBlock:(void (^)(BOOL completed))completionBlock;
-(void)fetchMessagesFromCloud:(FDataSnapshot *)snapshot withBlock:(void (^)(NSMutableArray *messages))completionBlock;
- (void)setUpContentFirebaseWithCompletionBlock:(void (^)(BOOL completed))completionBlock;

@end
