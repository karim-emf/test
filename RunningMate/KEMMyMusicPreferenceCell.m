//
//  KEMMyMusicPreferenceCell.m
//  RunningMate
//
//  Created by Karim Mourra on 1/31/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "KEMMyMusicPreferenceCell.h"
#import "KEMDataStore.h"

@interface KEMMyMusicPreferenceCell ()

@property (strong, nonatomic) KEMDataStore* dataStore;

@end

@implementation KEMMyMusicPreferenceCell

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
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.frame.size.width - 5, 20)];
        titleLabel.numberOfLines = 0;
        titleLabel.text = @"Is wearing headphones a necessity?";
        [titleLabel sizeToFit];
        
        [self.contentView addSubview:titleLabel];
        [self setUpPreferencePick];
        [self.contentView addSubview:self.preferencePick];
        [self positionPreferencePick];
        self.dataStore =[KEMDataStore sharedDataManager];
    }
    return self;
}

-(CGFloat) obtainFrameOf:(UILabel*)label ThatFits:(NSString*)text
{
    CGSize maximumLabelSize = CGSizeMake(self.frame.size.width, FLT_MAX);
    
    CGSize expectedLabelSize = [text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
//    CGRect expectedLabelRect = [text boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil];
    
    return expectedLabelSize.height;
}

-(void)setUpPreferencePick
{
    NSArray* preferences = @[@"Yes", @"No"];
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
        [self.dataStore addPersonalMusicResponse:@1 ToPreferenceFor:date];
    }
    else if ([preference isEqual:@"No"])
    {
        [self.dataStore addPersonalMusicResponse:@0 ToPreferenceFor:date];
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
