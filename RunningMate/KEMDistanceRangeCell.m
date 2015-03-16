//
//  KEMDistanceRangeCell.m
//  RunningMate
//
//  Created by Karim Mourra on 1/30/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "KEMDistanceRangeCell.h"
#import "KEMDataStore.h"

@interface KEMDistanceRangeCell ()

@property (strong, nonatomic) KEMDataStore* dataStore;

@end

@implementation KEMDistanceRangeCell

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
        [self setUpLabelsAndTextFields];
        self.dataStore =[KEMDataStore sharedDataManager];
    }
    return self;
}

-(void)setUpLabelsAndTextFields
{
    self.distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 50, 20)];
    self.distanceLabel.text = @"Distance:";
    [self.distanceLabel sizeToFit];
    [self.contentView addSubview:self.distanceLabel];
    
    self.toLabel = [[UILabel alloc]initWithFrame:CGRectMake(175, 30, 50, 50)];
    self.toLabel.text = @"To:";
    [self.toLabel sizeToFit];
    [self.contentView addSubview:self.toLabel];
    
    self.toDistance = [[UITextField alloc]initWithFrame:CGRectMake(200, 30, 50, 25)];
    self.toDistance.delegate = self;
    self.toDistance.translatesAutoresizingMaskIntoConstraints = NO;
    self.toDistance.layer.masksToBounds = YES;
    self.toDistance.layer.cornerRadius = 10.0f;
    
    self.toDistance.backgroundColor = [UIColor lightTextColor];
    UIColor *borderColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    self.toDistance.layer.borderColor =[borderColor CGColor];
    self.toDistance.layer.borderWidth = 1.0f;
    
    self.toDistance.textAlignment=NSTextAlignmentCenter;
    self.toDistance.autocapitalizationType=UITextAutocapitalizationTypeNone;
    
    self.toDistance.keyboardType = UIKeyboardTypeDecimalPad;
    [self.toDistance addTarget:self action:@selector(toDistanceFieldEdited) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:self.toDistance];
    [self.contentView bringSubviewToFront:self.toDistance];
    
    self.fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 30, 50, 50)];
    self.fromLabel.text = @"From:";
    [self.fromLabel sizeToFit];
    [self.contentView addSubview:self.fromLabel];
    
    self.fromDistance = [[UITextField alloc]initWithFrame:CGRectMake(75, 30, 50, 25)];
    self.fromDistance.delegate = self;
    self.fromDistance.translatesAutoresizingMaskIntoConstraints = NO;
    self.fromDistance.layer.masksToBounds = YES;
    self.fromDistance.layer.cornerRadius = 10.0f;
    self.fromDistance.backgroundColor = [UIColor lightTextColor];
    self.fromDistance.layer.borderColor =[borderColor CGColor];
    self.fromDistance.layer.borderWidth = 1.0f;
    self.fromDistance.textAlignment=NSTextAlignmentCenter;
    self.fromDistance.autocapitalizationType=UITextAutocapitalizationTypeNone;
    self.fromDistance.keyboardType = UIKeyboardTypeDecimalPad;
    [self.fromDistance addTarget:self action:@selector(fromDistanceFieldEdited) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:self.fromDistance];
    [self.contentView bringSubviewToFront:self.fromDistance];
    
    [self positionFirstLabel:self.distanceLabel];
    [self positionFromField];
    [self positionFromLabel];
    [self positionToLabel];
    [self positionToField];
    [self setUpMeasurementLabel];
}

-(void)fromDistanceFieldEdited
{
    //core data!
    //self.fromDistance.text
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
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterNoStyle;
    NSNumber *fromDist = [numberFormatter numberFromString:self.fromDistance.text];
    NSNumber *toDist = [numberFormatter numberFromString:self.toDistance.text];
    
    [self.dataStore addDistanceFrom:fromDist To:toDist ToPreferenceFor:date];
    
}

-(void)toDistanceFieldEdited
{
    //core data!
    //self.toDistance.text
    [self fromDistanceFieldEdited];
}

-(void)setUpDistanceRange
{
    float screenWidth = self.frame.size.width;
    self.distanceRange = [[NMRangeSlider alloc]initWithFrame:CGRectMake(60, 35, screenWidth-80, 30)];
    [self.distanceRange addTarget:self action:@selector(distanceRangeChanged:) forControlEvents:UIControlEventValueChanged];
    self.distanceRange.stepValue = 100;
    self.distanceRange.stepValueContinuously = NO;
    
    self.distanceRange.minimumValue = 0;
    self.distanceRange.maximumValue = 42195;
    [self.distanceRange setLowerValue:self.distanceRange.minimumValue upperValue:self.distanceRange.maximumValue animated:NO];
    
        self.distanceRange.lowerValue = self.distanceRange.minimumValue;
        self.distanceRange.upperValue = self.distanceRange.maximumValue;
    
    self.distanceRange.minimumRange = 1;
    
    self.lowerLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.distanceRange.lowerCenter.x + self.distanceRange.frame.origin.x, self.distanceRange.lowerCenter.y - 30, 60, 20)];
    self.upperLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.distanceRange.upperCenter.x + self.distanceRange.frame.origin.x, self.distanceRange.upperCenter.y - 60, 60, 20)];
    
    //-----
    CGPoint lowerCenter;
    lowerCenter.x = (self.distanceRange.frame.origin.x);//(self.distanceRange.lowerCenter.x + self.distanceRange.frame.origin.x);
    NSLog(@"low center x : %f", lowerCenter.x);
    lowerCenter.y = (self.distanceRange.center.y + 30.0f);
    self.lowerLabel.center = lowerCenter;
    self.lowerLabel.text = [NSString stringWithFormat:@"%f", self.distanceRange.lowerValue];
    
    CGPoint upperCenter;
    upperCenter.x = (self.distanceRange.frame.size.width);
    NSLog(@"Up center x : %f", upperCenter.x);
    
    upperCenter.y = (self.distanceRange.center.y - 30.0f);
    self.upperLabel.center = upperCenter;
    self.upperLabel.text = [NSString stringWithFormat:@"%f", self.distanceRange.upperValue];
    //-----
    
    
    [self.distanceRange layoutSubviews];
    [self.distanceRange setNeedsLayout];
}

- (void) updateSliderLabels
{
    
    CGPoint lowerCenter;
    lowerCenter.x = (self.distanceRange.lowerCenter.x + self.distanceRange.frame.origin.x);
    lowerCenter.y = (self.distanceRange.center.y + 30.0f);
    self.lowerLabel.center = lowerCenter;
    self.lowerLabel.text = [NSString stringWithFormat:@"%f", self.distanceRange.lowerValue];
    
    CGPoint upperCenter;
    upperCenter.x = (self.distanceRange.upperCenter.x + self.distanceRange.frame.origin.x);
    upperCenter.y = (self.distanceRange.center.y - 30.0f);
    self.upperLabel.center = upperCenter;
    self.upperLabel.text = [NSString stringWithFormat:@"%f", self.distanceRange.upperValue];
}

- (IBAction)distanceRangeChanged:(NMRangeSlider*)sender
{
    [self updateSliderLabels];
}

-(void) positionFirstLabel:(UILabel*)label
{
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *labelTop = [NSLayoutConstraint constraintWithItem:label
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:5.0];
    
    NSLayoutConstraint *labeltHeight = [NSLayoutConstraint constraintWithItem:label
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.contentView
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:0
                                                                     constant:20.0];
    
    NSLayoutConstraint *labelWidth = [NSLayoutConstraint constraintWithItem:label
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0
                                                                    constant:-10.0];
    
    NSLayoutConstraint *labelLeft = [NSLayoutConstraint constraintWithItem:label
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0
                                                                   constant:5.0];
    
    [self.contentView addConstraints:@[labelLeft,labeltHeight, labelTop, labelWidth]];
}

-(void) positionFromField
{
    self.fromDistance.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *labelY = [NSLayoutConstraint constraintWithItem:self.fromDistance
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.fromLabel
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:0.0];
    
    NSLayoutConstraint *labeltHeight = [NSLayoutConstraint constraintWithItem:self.fromDistance
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.contentView
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:0
                                                                     constant:25.0];
    
    NSLayoutConstraint *labelWidth = [NSLayoutConstraint constraintWithItem:self.fromDistance
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:0
                                                                   constant:50.0];
    
    NSLayoutConstraint *labelRight = [NSLayoutConstraint constraintWithItem:self.fromDistance
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:-5.0];
    
    [self.contentView addConstraints:@[labelRight,labeltHeight, labelY, labelWidth]];
}

-(void) positionFromLabel
{
//        self.fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 30, 50, 50)];
    self.fromLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *labelTop = [NSLayoutConstraint constraintWithItem:self.fromLabel
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.distanceLabel
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:5.0];
    
    NSLayoutConstraint *labeltHeight = [NSLayoutConstraint constraintWithItem:self.fromLabel
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.contentView
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:0
                                                                     constant:20.0];
    
    NSLayoutConstraint *labelWidth = [NSLayoutConstraint constraintWithItem:self.fromLabel
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:0
                                                                   constant:50.0];
    
    NSLayoutConstraint *labelRight = [NSLayoutConstraint constraintWithItem:self.fromLabel
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.fromDistance
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0
                                                                   constant:-5.0];
    
    [self.contentView addConstraints:@[labelRight,labeltHeight, labelTop, labelWidth]];
}

-(void) positionToLabel
{
    //        self.fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 30, 50, 50)];
    self.toLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *labelTop = [NSLayoutConstraint constraintWithItem:self.toLabel
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.distanceLabel
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:5.0];
    
    NSLayoutConstraint *labeltHeight = [NSLayoutConstraint constraintWithItem:self.toLabel
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.contentView
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:0
                                                                     constant:20.0];
    
    NSLayoutConstraint *labelWidth = [NSLayoutConstraint constraintWithItem:self.toLabel
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:0
                                                                   constant:25.0];
    
    NSLayoutConstraint *labelLeft = [NSLayoutConstraint constraintWithItem:self.toLabel
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:5.0];
    
    [self.contentView addConstraints:@[labelLeft,labeltHeight, labelTop, labelWidth]];
}

-(void) positionToField
{
    self.toDistance.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *labelY = [NSLayoutConstraint constraintWithItem:self.toDistance
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.fromLabel
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:0.0];
    
    NSLayoutConstraint *labeltHeight = [NSLayoutConstraint constraintWithItem:self.toDistance
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.contentView
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:0
                                                                     constant:25.0];
    
    NSLayoutConstraint *labelWidth = [NSLayoutConstraint constraintWithItem:self.toDistance
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:0
                                                                   constant:50.0];
    
    NSLayoutConstraint *labelLeft = [NSLayoutConstraint constraintWithItem:self.toDistance
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.toLabel
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0
                                                                   constant:5.0];
    
    [self.contentView addConstraints:@[labelLeft,labeltHeight, labelY, labelWidth]];
}

-(void)setUpMeasurementLabel
{
    self.measurementLabel = [[UILabel alloc]init];
    self.measurementLabel.text = @"KMs";
    self.measurementLabel.backgroundColor = [UIColor clearColor];
    [self.measurementLabel sizeToFit];
    [self.contentView addSubview:self.measurementLabel];
    self.measurementLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    NSLayoutConstraint *radiusToleranceLabelHeight = [NSLayoutConstraint constraintWithItem:self.measurementLabel
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self.fromLabel
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                 multiplier:1.0
                                                                                   constant:0.0];
    
    NSLayoutConstraint *radiusToleranceLabelCenterY = [NSLayoutConstraint constraintWithItem:self.measurementLabel
                                                                                   attribute:NSLayoutAttributeCenterY
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.fromLabel
                                                                                   attribute:NSLayoutAttributeCenterY
                                                                                  multiplier:1.0
                                                                                    constant:0.0];
    
    NSLayoutConstraint *radiusToleranceLabelLeft = [NSLayoutConstraint constraintWithItem:self.measurementLabel
                                                                                 attribute:NSLayoutAttributeLeft
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self.toDistance
                                                                                 attribute:NSLayoutAttributeRight
                                                                                multiplier:1.0
                                                                                  constant:5.0];
    
    [self.contentView addConstraints:@[radiusToleranceLabelHeight, radiusToleranceLabelCenterY, radiusToleranceLabelLeft]];
}

@end
