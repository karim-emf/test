//
//  KEMDurationRangeCell.m
//  RunningMate
//
//  Created by Karim Mourra on 1/31/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "KEMDurationRangeCell.h"
#import "KEMDataStore.h"

@interface KEMDurationRangeCell ()

@property (strong, nonatomic) KEMDataStore* dataStore;

@end

@implementation KEMDurationRangeCell

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
        UILabel* durationLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 50, 20)];
        durationLabel.text = @"Duration:";
        [durationLabel sizeToFit];
        [self.contentView addSubview:durationLabel];
        
        [self setUpDurationRange];
        [self.contentView addSubview:self.durationRange];
        [self.contentView addSubview:self.lowerLabel];
        [self.contentView addSubview:self.upperLabel];
        
        self.dataStore =[KEMDataStore sharedDataManager];
    }
    return self;
}

-(NSArray*) obtainCurrentHourAndMins
{
    NSDate *now = [NSDate date];
    NSDateFormatter *outputFormat = [[NSDateFormatter alloc]init];
    [outputFormat setDateFormat:@"HH:mm"];
    NSString *nowInHourAndMins = [outputFormat stringFromDate:now];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *currentHour = [f numberFromString:[nowInHourAndMins componentsSeparatedByString:@":"][0]];
    NSNumber *currentMins = [f numberFromString:[nowInHourAndMins componentsSeparatedByString:@":"][1]];
    return @[currentHour, currentMins];
}

-(NSArray*) convertToNextQuarter:(NSArray*)currentHourAndMins
{
    CGFloat currentHour = [currentHourAndMins[0] floatValue];
    CGFloat currentMins = [currentHourAndMins[1] floatValue];
    
    CGFloat nextQuarter;
    CGFloat nextPoint;
    
    
    if (currentMins <15)
    {
        nextQuarter = 15;
        nextPoint = 1;
    }
    else if (currentMins <30)
    {
        nextQuarter = 30;
        nextPoint = 2;
    }
    else if (currentMins <45)
    {
        nextQuarter = 45;
        nextPoint = 3;
    }
    else
    {
        currentHour += 1;
        nextQuarter = 0;
        nextPoint = 0;
    }
    return @[[NSNumber numberWithFloat:currentHour], [NSNumber numberWithFloat:nextQuarter], [NSNumber numberWithFloat:nextPoint]];
}

-(void)setUpDurationRange
{
    float screenWidth = self.frame.size.width;
    self.durationRange = [[NMRangeSlider alloc]initWithFrame:CGRectMake(60, 35, screenWidth-80, 30)];
    [self.durationRange addTarget:self action:@selector(durationRangeChanged:) forControlEvents:UIControlEventValueChanged];
    self.durationRange.stepValue = 1;
    self.durationRange.stepValueContinuously = NO;
    self.durationRange.continuous = NO;

    
    self.durationRange.minimumValue = 0; //[minHour floatValue]*4 + [minNextPoint floatValue];
    self.durationRange.maximumValue = 5 * 4;
    [self.durationRange setLowerValue:self.durationRange.minimumValue upperValue:self.durationRange.maximumValue animated:NO];
    
    
    //    self.durationRange.lowerValue = self.durationRange.minimumValue;
    //    self.durationRange.upperValue = self.durationRange.maximumValue;
    
    self.durationRange.minimumRange = 0;
    
    self.lowerLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.durationRange.lowerCenter.x + self.durationRange.frame.origin.x, self.durationRange.lowerCenter.y - 30, 60, 20)];
    self.upperLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.durationRange.upperCenter.x + self.durationRange.frame.origin.x, self.durationRange.upperCenter.y - 60, 60, 20)];
    
    
    //-----
    CGPoint lowerCenter;
    lowerCenter.x = (self.durationRange.frame.origin.x);//(self.durationRange.lowerCenter.x + self.durationRange.frame.origin.x);
    lowerCenter.y = (self.durationRange.center.y + 30.0f);
    self.lowerLabel.center = lowerCenter;
    self.lowerLabel.text = [NSString stringWithFormat:@"%@", [self convertToHourMinuteFormat:(int)self.durationRange.lowerValue]];
    
    CGPoint upperCenter;
    upperCenter.x = (self.durationRange.frame.size.width);
    upperCenter.y = (self.durationRange.center.y - 30.0f);
    self.upperLabel.center = upperCenter;
    self.upperLabel.text = [NSString stringWithFormat:@"%@", [self convertToHourMinuteFormat:(int)self.durationRange.upperValue]];
    //-----
    
    if (self.recordedUpperValue)
    {
        self.durationRange.upperValue = [self.recordedUpperValue floatValue];
    }
    if (self.recordedLowerValue)
    {
        self.durationRange.lowerValue = [self.recordedLowerValue floatValue];
    }
    
    [self.durationRange layoutSubviews];
    [self.durationRange setNeedsLayout];
}

-(NSString*) convertToHourMinuteFormat:(int)amount
{
    NSString* duration = @"";
    if (amount%4 == 0)
    {
        return[duration stringByAppendingString:[[NSString stringWithFormat:@"%d:", amount/4] stringByAppendingString:@"00"]];
    }
    else
    {
        return[duration stringByAppendingString:[[NSString stringWithFormat:@"%d:", (amount - (amount%4)) /4] stringByAppendingString:[NSString stringWithFormat:@"%d", (amount%4 * 15)]]];
    }
}

- (void) updateSliderLabels
{
    
    CGPoint lowerCenter;
    lowerCenter.x = (self.durationRange.lowerCenter.x + self.durationRange.frame.origin.x);
    lowerCenter.y = (self.durationRange.center.y + 30.0f);
    self.lowerLabel.center = lowerCenter;
    self.lowerLabel.text = [NSString stringWithFormat:@"%@", [self convertToHourMinuteFormat:(int)self.durationRange.lowerValue]];
    
    CGPoint upperCenter;
    upperCenter.x = (self.durationRange.upperCenter.x + self.durationRange.frame.origin.x);
    upperCenter.y = (self.durationRange.center.y - 30.0f);
    self.upperLabel.center = upperCenter;
    self.upperLabel.text = [NSString stringWithFormat:@"%@", [self convertToHourMinuteFormat:(int)self.durationRange.upperValue]];
}

- (IBAction)durationRangeChanged:(NMRangeSlider*)sender
{
    [self updateSliderLabels];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *year = [formatter stringFromDate:now];
    [formatter setDateFormat:@"MM"];
    NSString *month = [formatter stringFromDate:now];
    [formatter setDateFormat:@"dd"];
    NSString *day = [formatter stringFromDate:now];
    NSString *date = [day stringByAppendingFormat:@"-%@-%@", month, year];
    
    //core data!
    NSNumber* minTime = [NSNumber numberWithFloat:self.durationRange.lowerValue];
    NSNumber* maxTime = [NSNumber numberWithFloat:self.durationRange.upperValue];
    
    [self.dataStore addDurationMinTime:minTime AndMaxTime:maxTime ToPreferenceFor:date];
    ///core data!
//    self.durationRange.lowerValue;
//    self.durationRange.upperValue;
}

@end
