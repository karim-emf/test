//
//  KEMChatMessage.h
//  RunningMate
//
//  Created by Karim Mourra on 3/18/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KEMChatMessage : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * chatRoomCode;
@property (nonatomic, retain) NSDate * dateSent;
@property (nonatomic, retain) NSString * sender;

@end
