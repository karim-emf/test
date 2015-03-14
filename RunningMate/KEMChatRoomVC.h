//
//  KEMChatRoomVC.h
//  RunningMate
//
//  Created by Karim Mourra on 3/10/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KEMChatRoom.h"

@interface KEMChatRoomVC : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate>

//@property(strong,nonatomic)KJDUser *user;
@property (strong, nonatomic) NSString *firebaseRoomURL;
@property (strong, nonatomic) NSString *firebaseURL;
@property (weak, nonatomic) KEMChatRoom *chatRoom;
@property (strong, nonatomic) NSString* userName;
@property (strong, nonatomic) NSString* matchName;
@property (strong, nonatomic) NSString* matchDate;

@end
