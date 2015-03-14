//
//  KEMSpeedFastest.h
//  RunningMate
//
//  Created by Karim Mourra on 3/5/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KEMSpeedFastest : UITableViewCell<UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) UILabel* titleLabel;
@property (strong,nonatomic) UIPickerView* speedPicker;

@property (strong,nonatomic) NSString* speedUnit;
@property (strong,nonatomic) NSString* speedDecimal;

@end