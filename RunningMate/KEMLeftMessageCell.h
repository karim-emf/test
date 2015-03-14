//
//  KJDLeftMessageCell.h
//  Vegas
//
//  Created by Karim Mourra on 12/30/14.
//  Copyright (c) 2014 Jan Roures Mintenig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KEMLeftMessageCell : UITableViewCell

@property (nonatomic, strong) UILabel* senderName;
@property (nonatomic, strong) UILabel* message;

-(void) setUpSenderNameLabel;
-(void) setUpMessageLabel;

@end
