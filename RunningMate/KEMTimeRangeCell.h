//
//  KEMTimeRangeCell.h
//  RunningMate
//
//  Created by Karim Mourra on 1/30/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NMRangeSlider/NMRangeSlider.h>

@interface KEMTimeRangeCell : UITableViewCell

@property (strong, nonatomic) IBOutlet NMRangeSlider *timeRange;
@property (strong, nonatomic) IBOutlet UILabel *lowerLabel;
@property (strong, nonatomic) IBOutlet UILabel *upperLabel;
@property (strong, nonatomic) IBOutlet UIButton *deleteCell;

@property (strong, nonatomic) NSNumber* recordedLowerValue;
@property (strong, nonatomic) NSNumber* recordedUpperValue;

- (void) updateSliderLabels;

@end
