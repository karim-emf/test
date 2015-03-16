//
//  KEMMatchDateCell.m
//  RunningMate
//
//  Created by Karim Mourra on 3/15/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "KEMMatchDateCell.h"

@implementation KEMMatchDateCell

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
        self.backgroundColor = [UIColor colorWithRed:51/255.0f green:171/255.0f blue:249/255.0f alpha:0.7];//[UIColor clearColor];
//        self.contentView.backgroundColor= [UIColor colorWithRed:51/255.0f green:171/255.0f blue:249/255.0f alpha:0.7];
        
        self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 50, 20)];
        self.dateLabel.backgroundColor = [UIColor clearColor];
//        self.dateLabel.text = @"Location:";
        [self.dateLabel setTextAlignment:NSTextAlignmentCenter];
        self.dateLabel.textColor = [UIColor whiteColor];
        [self.dateLabel sizeToFit];
        [self.contentView addSubview:self.dateLabel];
        [self positionFirstLabel:self.dateLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
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
    
    NSLayoutConstraint *labeltBottom = [NSLayoutConstraint constraintWithItem:label
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.contentView
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0
                                                                     constant:-5.0];
    
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
    
    [self.contentView addConstraints:@[labelLeft,labeltBottom, labelTop, labelWidth]];
}

@end
