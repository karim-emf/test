//
//  KJDMessageCell.h
//  Vegas
//
//  Created by Karim Mourra on 12/29/14.
//  Copyright (c) 2014 Jan Roures Mintenig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KEMRightMessageCell : UITableViewCell

@property (nonatomic, strong) UILabel* senderName;
@property (nonatomic, strong) UILabel* message;

-(void) setUpSenderNameLabel;
-(void) setUpMessageLabel;

@end
