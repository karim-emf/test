//
//  KEMFirebaseLiaison.h
//  RunningMate
//
//  Created by Karim Mourra on 4/4/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KEMFirebaseLiaison : NSObject


+ (instancetype)firebaseLiaisonSingleton;

-(void)registerForChatNotificationsOfActiveChats;

@end
