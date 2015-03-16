//
//  KEMConversationPreferenceCell.m
//  RunningMate
//
//  Created by Karim Mourra on 1/31/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "KEMConversationPreferenceCell.h"
#import "KEMDataStore.h"

@interface KEMConversationPreferenceCell ()

@property (strong, nonatomic) KEMDataStore* dataStore;

@end

@implementation KEMConversationPreferenceCell

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

        UILabel* titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 50, 20)];
        titleLabel.text = @"Conversation while running?";
        [titleLabel sizeToFit];
        [self.contentView addSubview:titleLabel];
        
        [self setUpPreferencePick];
        [self.contentView addSubview:self.preferencePick];
        [self positionPreferencePick];
        self.dataStore =[KEMDataStore sharedDataManager];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setUpPreferencePick
{
    NSArray* preferences = @[@"Yes", @"No", @"I don't care"];
    self.preferencePick =[[UISegmentedControl alloc]initWithItems:preferences];
    [self.preferencePick addTarget:self action:@selector(preferencePicked) forControlEvents:UIControlEventValueChanged];
}

-(void)preferencePicked
{
    NSString *preference =[self.preferencePick titleForSegmentAtIndex: [self.preferencePick selectedSegmentIndex]];
    
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
    if ([preference isEqual:@"Yes"])
    {
        [self.dataStore addConversationResponse:@1 ToPreferenceFor:date];
    }
    else if ([preference isEqual:@"No"])
    {
        [self.dataStore addConversationResponse:@-1 ToPreferenceFor:date];
    }
    else if ([preference isEqual:@"I don't care"])
    {
        [self.dataStore addConversationResponse:@0 ToPreferenceFor:date];
    }
}

-(void) positionPreferencePick
{
    self.preferencePick.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *preferencePickX =[NSLayoutConstraint constraintWithItem:self.preferencePick
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.contentView
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1.0
                                                                       constant:0.0];
    
    NSLayoutConstraint *preferencePickY =[NSLayoutConstraint constraintWithItem:self.preferencePick
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.contentView
                                                                      attribute:NSLayoutAttributeCenterY
                                                                     multiplier:1.0
                                                                       constant:0.0];
    [self.contentView addConstraints:@[preferencePickX,preferencePickY]];
}
@end
