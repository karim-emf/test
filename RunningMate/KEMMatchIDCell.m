//
//  KEMMatchIDCell.m
//  RunningMate
//
//  Created by Karim Mourra on 3/15/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "KEMMatchIDCell.h"

@implementation KEMMatchIDCell

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
        [self createNameLabel];
        [self createProfilePicView];
        [self positionProfilePicView];
        [self positionFirstLabel:self.nameLabel];
    }
    return self;
}

-(void) createProfilePicView
{
    self.profilePicView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 50, 20)];
    [self.contentView addSubview:self.profilePicView];
}

-(void) createNameLabel
{
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 50, 20)];
    self.nameLabel.backgroundColor = [UIColor clearColor];
//    [self.nameLabel setTextAlignment:NSTextAlignmentCenter];
    self.nameLabel.textColor = [UIColor blackColor];
    [self.nameLabel sizeToFit];
    [self.contentView addSubview:self.nameLabel];
}

-(void) positionProfilePicView
{
    self.profilePicView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *labelTop = [NSLayoutConstraint constraintWithItem:self.profilePicView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.contentView
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:5.0];
    
    NSLayoutConstraint *labeltBottom = [NSLayoutConstraint constraintWithItem:self.profilePicView
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.contentView
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0
                                                                     constant:-5.0];
    
    NSLayoutConstraint *labelWidth = [NSLayoutConstraint constraintWithItem:self.profilePicView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.profilePicView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1.0
                                                                   constant:0.0];
    
    NSLayoutConstraint *labelLeft = [NSLayoutConstraint constraintWithItem:self.profilePicView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:5.0];
    
    [self.contentView addConstraints:@[labelLeft,labeltBottom, labelTop, labelWidth]];
    
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
    
//    NSLayoutConstraint *labelWidth = [NSLayoutConstraint constraintWithItem:label
//                                                                  attribute:NSLayoutAttributeWidth
//                                                                  relatedBy:NSLayoutRelationEqual
//                                                                     toItem:self.contentView
//                                                                  attribute:NSLayoutAttributeWidth
//                                                                 multiplier:1.0
//                                                                   constant:-10.0];
    
    NSLayoutConstraint *labelLeft = [NSLayoutConstraint constraintWithItem:label
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.profilePicView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:5.0];
    
    [self.contentView addConstraints:@[labelLeft,labeltBottom, labelTop]];
}
@end
