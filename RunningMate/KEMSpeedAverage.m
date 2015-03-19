//
//  KEMSpeedTolerance.m
//  RunningMate
//
//  Created by Karim Mourra on 1/31/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "KEMSpeedAverage.h"
#import "KEMDataStore.h"

@interface KEMSpeedAverage ()

@property (strong, nonatomic) KEMDataStore* dataStore;

@end

@implementation KEMSpeedAverage

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, self.frame.size.width - 5, 20)];
        self.titleLabel.text = @"Enter the average speed at which you prefer to run:";
        self.titleLabel.numberOfLines = 0;
        [self.titleLabel sizeToFit];
        [self.contentView addSubview:self.titleLabel];
        
        [self setUpSpeedPicker];
        [self.contentView addSubview:self.speedPicker];
        [self positionSpeedPicker];
        self.dataStore =[KEMDataStore sharedDataManager];
    }
    return self;
}

-(void)setUpSpeedPicker
{
    float screenWidth = self.frame.size.width;
    self.speedPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(60, 35, screenWidth-80, 30)];
    self.speedPicker.delegate = self;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 4;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
    {
        return 46;
    }
    else if (component == 1)
    {
        return 1;
    }
    else if (component == 2)
    {
        return 10;
    }
    else
    {
        return 1;
    }
}

-(NSString*) pickerView:(UIPickerView*)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
    {
        return [NSString stringWithFormat:@"%ld", (long)row];
    }
    else if (component == 1)
    {
        return @":";
    }
    else if (component == 2)
    {
        return [NSString stringWithFormat:@"%ld", (long)row * 10];
    }
    else
    {
                        return @"Km/h";
//        switch(row)
//        {
//            case 0:
//                return @"Km/h";
//            case 1:
//                return @"mph";
//        }
//        return @"";
    }
}

-(void) positionSpeedPicker
{
    self.speedPicker.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *speedPickerTop =[NSLayoutConstraint constraintWithItem:self.speedPicker
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.titleLabel
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0
                                                                       constant:0.0];
    
    NSLayoutConstraint *speedPickerBottom =[NSLayoutConstraint constraintWithItem:self.speedPicker
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.contentView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0
                                                                       constant:0.0];
    
    [self.contentView addConstraints:@[speedPickerTop, speedPickerBottom]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //core data!
    
    //convert all to km/h !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *year = [formatter stringFromDate:now];
    [formatter setDateFormat:@"MM"];
    NSString *month = [formatter stringFromDate:now];
    [formatter setDateFormat:@"dd"];
    NSString *day = [formatter stringFromDate:now];
    NSString *date = [day stringByAppendingFormat:@"-%@-%@", month, year];
    
    if (component == 0)
    {
        self.speedUnit = [NSString stringWithFormat:@"%d", (int)row];
    }
    else if (component == 2)
    {
        self.speedDecimal =  [NSString stringWithFormat:@"%d", (int)row * 10];
    }
    
    [self.dataStore addAverageSpeedUnit:self.speedUnit AndSpeedDecimal:self.speedDecimal ToPreferenceFor:date];
    
    KEMDailyPreference* dailyPreference = [self.dataStore.dailyPreferences objectForKey:date];
    
    if ([dailyPreference.fastestSpeedKmH floatValue] == 0 && [dailyPreference.slowestSpeedKmH floatValue] == 0)
    {
        [self.dataStore addFastestSpeedUnit:self.speedUnit AndSpeedDecimal:self.speedDecimal ToPreferenceFor:date];
        [self.dataStore addSlowestSpeedUnit:self.speedUnit AndSpeedDecimal:self.speedDecimal ToPreferenceFor:date];
        
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:@"averageSpeedSet" object:nil];
    }
    
}


@end
