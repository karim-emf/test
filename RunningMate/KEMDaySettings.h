//
//  KEMDaySettings.h
//  RunningMate
//
//  Created by Karim Mourra on 1/30/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KEMLocationPreferenceCell.h"

@interface KEMDaySettings : UITableViewController<UINavigationControllerDelegate>

@property (strong, nonatomic) UITextField* fromDistance;
@property (strong, nonatomic) UITextField* toDistance;
@property(strong, nonatomic) UITextField* searchBar;
@property(strong, nonatomic) UITextField* radiusToleranceField;
@property(strong,nonatomic) UIButton* editCurrentLocationButton;

//@property(strong, nonatomic) KEMLocationPreferenceCell* locationCell;
-(void)refreshLocationCell;
@end