//
//  KEMDistanceRangeCell.h
//  RunningMate
//
//  Created by Karim Mourra on 1/30/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NMRangeSlider/NMRangeSlider.h>

@interface KEMDistanceRangeCell : UITableViewCell<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet NMRangeSlider *distanceRange;
@property (strong, nonatomic) IBOutlet UILabel *lowerLabel;
@property (strong, nonatomic) IBOutlet UILabel *upperLabel;
@property(strong, nonatomic) UILabel* measurementLabel;

@property (strong, nonatomic) UILabel* distanceLabel;

@property (strong, nonatomic) UITextField* fromDistance;
@property (strong, nonatomic) UITextField* toDistance;

@property (strong, nonatomic) UILabel* fromLabel;
@property (strong, nonatomic) UILabel* toLabel;

@end