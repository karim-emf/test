//
//  KEMTimeRangeCell.m
//  RunningMate
//
//  Created by Karim Mourra on 1/30/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "KEMTimeRangeCell.h"
#import "KEMDataStore.h"

@interface KEMTimeRangeCell ()

@property (strong, nonatomic) KEMDataStore* dataStore;

@end

@implementation KEMTimeRangeCell


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
        UILabel* timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 50, 20)];
        timeLabel.text = @"Time:";
        [timeLabel sizeToFit];
        [self.contentView addSubview:timeLabel];
        
        self.deleteCell = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 20, 35, 20, 20)];
        self.deleteCell.backgroundColor = [UIColor redColor];
        [self setUpTimeRange];
        [self.contentView addSubview:self.timeRange];
        [self.contentView addSubview:self.deleteCell];
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

-(void)setUpTimeRange
{
    float screenWidth = self.frame.size.width;
    self.timeRange = [[NMRangeSlider alloc]initWithFrame:CGRectMake(60, 35, screenWidth-80, 30)];
    [self.timeRange addTarget:self action:@selector(timeRangeChanged:) forControlEvents:UIControlEventValueChanged];
    self.timeRange.stepValue = 1;
    self.timeRange.stepValueContinuously = NO;
    self.timeRange.continuous = NO;
    
    NSNumber* currentHour = [self obtainCurrentHourAndMins][0];
    NSNumber* currentMins = [self obtainCurrentHourAndMins][1];
    
    NSArray* nextQuarter = [self convertToNextQuarter:@[currentHour, currentMins]];
    
    NSNumber* minHour = nextQuarter[0];
    NSNumber* minNextPoint = nextQuarter[2];
    
    self.timeRange.minimumValue = [minHour floatValue]*4 + [minNextPoint floatValue];

    self.timeRange.maximumValue = 24.0 * 4;
    [self.timeRange setLowerValue:self.timeRange.minimumValue upperValue:self.timeRange.maximumValue animated:NO];
    
    self.timeRange.minimumRange = 1;
    
    self.lowerLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.timeRange.lowerCenter.x + self.timeRange.frame.origin.x, self.timeRange.lowerCenter.y - 30, 60, 20)];
    self.upperLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.timeRange.upperCenter.x + self.timeRange.frame.origin.x, self.timeRange.upperCenter.y - 60, 60, 20)];
    
    
    //-----
    CGPoint lowerCenter;
    lowerCenter.x = (self.timeRange.frame.origin.x);

    lowerCenter.y = (self.timeRange.center.y + 30.0f);
    self.lowerLabel.center = lowerCenter;
    self.lowerLabel.text = [NSString stringWithFormat:@"%@", [self convertToHourMinuteFormat:(int)self.timeRange.lowerValue]];
    
    CGPoint upperCenter;
    upperCenter.x = (self.timeRange.frame.size.width);

    upperCenter.y = (self.timeRange.center.y - 30.0f);
    self.upperLabel.center = upperCenter;
    self.upperLabel.text = [NSString stringWithFormat:@"%@", [self convertToHourMinuteFormat:(int)self.timeRange.upperValue]];
    //-----
    
    //this may be unnecessary- verify and delete !
    if (self.recordedUpperValue)
    {
        self.timeRange.upperValue = [self.recordedUpperValue floatValue];
    }
    if (self.recordedLowerValue)
    {
        self.timeRange.lowerValue = [self.recordedLowerValue floatValue];
    }
    
    [self.timeRange layoutSubviews];
    [self.timeRange setNeedsLayout];
}

-(NSString*) convertToHourMinuteFormat:(int)amount
{
    NSString* time = @"";
    if (amount%4 == 0)
    {
        return[time stringByAppendingString:[[NSString stringWithFormat:@"%d:", amount/4] stringByAppendingString:@"00"]];
    }
    else
    {
        return[time stringByAppendingString:[[NSString stringWithFormat:@"%d:", (amount - (amount%4)) /4] stringByAppendingString:[NSString stringWithFormat:@"%d", (amount%4 * 15)]]];
    }
}

- (void) updateSliderLabels
{
    
    CGPoint lowerCenter;
    lowerCenter.x = (self.timeRange.lowerCenter.x + self.timeRange.frame.origin.x);
    lowerCenter.y = (self.timeRange.center.y + 30.0f);
    self.lowerLabel.center = lowerCenter;
    self.lowerLabel.text = [NSString stringWithFormat:@"%@", [self convertToHourMinuteFormat:(int)self.timeRange.lowerValue]];
    
    CGPoint upperCenter;
    upperCenter.x = (self.timeRange.upperCenter.x + self.timeRange.frame.origin.x);
    upperCenter.y = (self.timeRange.center.y - 30.0f);
    self.upperLabel.center = upperCenter;
    self.upperLabel.text = [NSString stringWithFormat:@"%@", [self convertToHourMinuteFormat:(int)self.timeRange.upperValue]];
}

- (IBAction)timeRangeChanged:(NMRangeSlider*)sender
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
    NSNumber* startTime = [NSNumber numberWithFloat:self.timeRange.lowerValue];
    NSNumber* endTime = [NSNumber numberWithFloat:self.timeRange.upperValue];

    [self.dataStore addTimeRange:startTime And:endTime ToPreferenceFor:date];
}


@end
