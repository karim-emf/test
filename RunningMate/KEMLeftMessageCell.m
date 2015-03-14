//
//  KJDLeftMessageCell.m
//  Vegas
//
//  Created by Karim Mourra on 12/30/14.
//  Copyright (c) 2014 Jan Roures Mintenig. All rights reserved.
//

#import "KEMLeftMessageCell.h"

@implementation KEMLeftMessageCell

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
        
        self.senderName = [[UILabel alloc] init];
        self.senderName.textColor = [UIColor blackColor];
        self.senderName.backgroundColor = [UIColor clearColor];
        self.senderName.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.senderName];
        
        self.message = [[UILabel alloc] init];
        self.message.textColor = [UIColor blackColor];
        self.message.numberOfLines = 0;
        [self.message sizeToFit];
        self.message.backgroundColor = [UIColor clearColor];
        self.message.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.message];
    }
    return self;
}

-(void) setUpSenderNameLabel
{
    
    self.senderName.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *labelTop = [NSLayoutConstraint constraintWithItem:self.senderName
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:4.0];
    
    NSLayoutConstraint *labelHeight = [NSLayoutConstraint constraintWithItem:self.senderName
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0.0
                                                                    constant:17];
    
    NSLayoutConstraint *labelWidth = [NSLayoutConstraint constraintWithItem:self.senderName
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:5/8.0f
                                                                   constant:4.0];
    
    NSLayoutConstraint *labelRight = [NSLayoutConstraint constraintWithItem:self.senderName
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0
                                                                   constant:4.0];
    
    [self addConstraints:@[labelTop, labelHeight, labelWidth, labelRight]];
    
    
}

-(void) setUpMessageLabel
{
    
    self.message.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *messageTop = [NSLayoutConstraint constraintWithItem:self.message
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.senderName
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:4.0];
    
    NSLayoutConstraint *messageBottom = [NSLayoutConstraint constraintWithItem:self.message
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:-12.0];
    
    NSLayoutConstraint *messageWidth = [NSLayoutConstraint constraintWithItem:self.message
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.senderName
                                                                    attribute:NSLayoutAttributeWidth
                                                                   multiplier:1.0
                                                                     constant:0.0];
    
    NSLayoutConstraint *messageRight = [NSLayoutConstraint constraintWithItem:self.message
                                                                    attribute:NSLayoutAttributeRight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.senderName
                                                                    attribute:NSLayoutAttributeRight
                                                                   multiplier:1.0
                                                                     constant:0.0];
    
    [self addConstraints:@[messageTop, messageBottom, messageWidth, messageRight]];
    
}


@end
