//
//  KEMChatRoomVC.m
//  RunningMate
//
//  Created by Karim Mourra on 3/10/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "KEMChatRoomVC.h"
#import <Parse/Parse.h>
#import "KEMRightMessageCell.h"
#import "KEMLeftMessageCell.h"
#import "AppDelegate.h"
#import "KEMDataStore.h"

@interface KEMChatRoomVC ()

@property (strong, nonatomic) UITextField *inputTextField;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *mediaButton;
@property (strong, nonatomic) UILabel *subtitleView;
@property (strong, nonatomic) UIBarButtonItem *settingsButton;
@property (strong, nonatomic) UILabel *infoLabel;

//jan
@property (strong, nonatomic) UIView *usernameView;
@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) NSLayoutConstraint *usernameViewTop;
@property (strong, nonatomic) NSLayoutConstraint *usernameViewHeight;
@property (strong, nonatomic) NSLayoutConstraint *usernameViewWidth;
@property (strong, nonatomic) NSLayoutConstraint *usernameViewRight;

@property (nonatomic)CGRect keyBoardFrame;
@property(strong,nonatomic)NSMutableArray *messages;
@property (strong, nonatomic) KEMDataStore* dataStore;

@end

@implementation KEMChatRoomVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
//    backgroundImage.frame=self.view.frame;
//    UIView* backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
//    backgroundView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:backgroundImage];
//    [self.view sendSubviewToBack:backgroundImage];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.inputTextField.delegate=self;

    [self setupViewsAndConstraints];
    [self setUpFirebase];
    [self setUpNotificationCenter];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
    self.tabBarController.tabBar.hidden = YES;

    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.inChatRoom = YES;
    
    self.messages = [[NSMutableArray alloc]initWithArray:@[]];
    self.dataStore = [KEMDataStore sharedDataManager];
    NSArray* savedMessages = [self.dataStore fetchChatMessagesForChatRoom:self.chatRoom.firebaseRoomName];
    if ([savedMessages count]>0)
    {
        [self.messages addObjectsFromArray:savedMessages];
    }
    
    if (![self.messages count] == 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.inChatRoom = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //height in points
    if ([self.messages count] !=0)
    {
        NSMutableDictionary *message=self.messages[indexPath.row];
        
        if ([message objectForKey:@"message"]!=nil)
        {
            NSDictionary *message=self.messages[indexPath.row];
            NSString * yourText = message[@"message"];
            return 21 + [self heightForText:yourText];
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return 0;
    }
}

-(CGFloat)heightForText:(NSString *)text
{
    NSInteger MAX_HEIGHT = 9999;
    UITextView * textView = [[UITextView alloc] initWithFrame: CGRectMake(0, 0, self.tableView.frame.size.width * (5/8.0f), MAX_HEIGHT)];
    textView.text = text;
    textView.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
    [textView sizeToFit];
    return textView.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *content=self.messages[indexPath.row];
    
    if (content[@"message"])
    {
        NSString *messageTyped=[NSString stringWithFormat:@"%@", content[@"message"]];
        
        if ([content[@"user"] isEqualToString:self.userName])
        {
            KEMRightMessageCell* cell = (KEMRightMessageCell*)[tableView dequeueReusableCellWithIdentifier:@"messageCell"];
            
            NSMutableAttributedString *attributedUserName = [[NSMutableAttributedString alloc]initWithString:content[@"user"]];
            [attributedUserName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [attributedUserName length])];
            
            NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc]initWithString:messageTyped];
            [attributedMessage addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0] range:NSMakeRange(0, [attributedMessage length])];
            
            if (cell == nil)
            {
                cell = [[KEMRightMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"messageCell"];
            }
            [cell setUpSenderNameLabel];
            [cell setUpMessageLabel];
            cell.senderName.attributedText = attributedUserName;
            cell.message.attributedText = attributedMessage;
            
            return cell;
        }
        else
        {
            KEMLeftMessageCell* cell = (KEMLeftMessageCell*)[tableView dequeueReusableCellWithIdentifier:@"leftMessageCell"];
            
            NSMutableAttributedString *attributedUserName = [[NSMutableAttributedString alloc]initWithString:content[@"user"]];
            [attributedUserName addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:15] range:NSMakeRange(0, [attributedUserName length])];
            
            NSMutableAttributedString *attributedMessage = [[NSMutableAttributedString alloc]initWithString:messageTyped];
            [attributedMessage addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0] range:NSMakeRange(0, [attributedMessage length])];
            
            if (cell == nil)
            {
                cell = [[KEMLeftMessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"leftMessageCell"];
            }
            [cell setUpSenderNameLabel];
            [cell setUpMessageLabel];
            cell.senderName.attributedText = attributedUserName;
            cell.message.attributedText = attributedMessage;
            
            return cell;
        }
    }
    return nil;
}


-(void) setUpFirebase
{
    [self.chatRoom setupFirebaseWithCompletionBlock:^(BOOL completed)
     {
         if (completed)
         {
             [self.chatRoom setUpContentFirebaseWithCompletionBlock:^(BOOL completed)
              {//refine this comparison; if the same text is sent twice, the 2nd won't show
                  if ([ [self.messages lastObject][@"message"] isEqualToString:[self.chatRoom.messages lastObject][@"message"] ])
                  {
                      
                  }
                  else
                  {
                      if ([self.chatRoom.messages count]>0)
                      {
                          [self.messages addObject:[self.chatRoom.messages lastObject]];
                          
                          NSDictionary *message = [self.chatRoom.messages lastObject];
                          [self.dataStore createChatMessage:message[@"message"] From:message[@"user"] For:self.chatRoom.firebaseRoomName Dated:[NSDate date]];
                      }
                     
                
                  
                  [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                      
                      [self.tableView reloadData];
                      if (![self.messages count] == 0)
                      {
                          [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                      }
                  }];
                  }
              }];
         }
     }];
}


-(void) setUpNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//jan
-(void)setViewMovedUp:(BOOL)moveUp
{
    CGRect superViewRect = self.view.frame;
    CGRect usernameViewFramePostKeyboardUp = self.usernameView.frame;
    usernameViewFramePostKeyboardUp.origin.y += self.keyBoardFrame.size.height;
    
    CGRect usernameViewFramePostKeyboardDown = self.usernameView.frame;
    usernameViewFramePostKeyboardDown.origin.y -= self.keyBoardFrame.size.height;
    
    UIEdgeInsets inset = UIEdgeInsetsMake(self.keyBoardFrame.size.height+self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height, 0, 0, 0);
    UIEdgeInsets afterInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height, 0, 0, 0);
    
    if (moveUp)
    {
        superViewRect.origin.y -= self.keyBoardFrame.size.height;
        [UIView transitionWithView:self.usernameView
                          duration:0
                           options:0
                        animations:^{
                            self.view.frame = superViewRect;
                            self.tableView.contentInset = inset;
                            self.usernameView.frame = usernameViewFramePostKeyboardUp;
                            
//                            [NSLayoutConstraint deactivateConstraints:@[self.usernameViewTop]];
//                            self.usernameViewTop=[NSLayoutConstraint constraintWithItem:self.usernameView
//                                                                              attribute:NSLayoutAttributeTop
//                                                                              relatedBy:NSLayoutRelationEqual                                                         toItem:self.view
//                                                                              attribute:NSLayoutAttributeTop
//                                                                             multiplier:1.0
//                                                                               constant:self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height + self.keyBoardFrame.size.height];
//                            [self.view addConstraint:self.usernameViewTop];
                            [self.view setNeedsUpdateConstraints];
                        }
                        completion:nil];
    }
    else
    {
        superViewRect.origin.y += self.keyBoardFrame.size.height;
        [UIView transitionWithView:self.usernameView
                          duration:0
                           options:0
                        animations:^{
                            self.view.frame = superViewRect;
                            self.tableView.contentInset = inset;
                            self.usernameView.frame = usernameViewFramePostKeyboardDown;
                            
//                            [NSLayoutConstraint deactivateConstraints:@[self.usernameViewTop]];
//                            self.usernameViewTop=[NSLayoutConstraint constraintWithItem:self.usernameView
//                                                                              attribute:NSLayoutAttributeTop
//                                                                              relatedBy:NSLayoutRelationEqual                                                         toItem:self.view
//                                                                              attribute:NSLayoutAttributeTop
//                                                                             multiplier:1.0
//                                                                               constant:self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height];
//                            [self.view addConstraint:self.usernameViewTop];
                            [self.view setNeedsUpdateConstraints];
                        }
                        completion:nil];
        self.tableView.contentInset = afterInset;
    }
}

//jan


//jan
-(void)toggleUsernameView
{
    if (self.usernameView.hidden)
    {
        [UIView transitionWithView:self.usernameView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            self.usernameView.hidden=NO;
                        }
                        completion:nil];
    }
    else
    {
        [UIView transitionWithView:self.usernameView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            self.usernameView.hidden=YES;
                        }
                        completion:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    [self.inputTextField resignFirstResponder];
    [self.usernameTextField resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [self.navigationController setNavigationBarHidden:NO];
    [UIView commitAnimations];
}

-(void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *keyboardInfo = [notification userInfo];
    NSValue *keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    _keyBoardFrame = [keyboardFrameBegin CGRectValue];
    if (self.view.frame.origin.y >= 0){
        [self setViewMovedUp:YES];
    }else if (self.view.frame.origin.y < 0){
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide:(NSNotification *)notification{
    if (self.view.frame.origin.y >= 0){
        [self setViewMovedUp:YES];
    }else if (self.view.frame.origin.y < 0){
        [self setViewMovedUp:NO];
    }
}

- (void)setupViewsAndConstraints
{
    [self setupNavigationBar];
    [self setUpInfoLabel];
    [self setupTableView];
    [self setupTextField];
    [self setupSendButton];
//    [self setupMediaButton];
//    [self setUpSettingsButton];
//    [self setupUsernameView];
}

-(void)setUpInfoLabel
{
    self.infoLabel = [[UILabel alloc]initWithFrame:self.tabBarController.tabBar.frame];
    self.infoLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.infoLabel];
}

-(void)setupNavigationBar
{
//    [ removeFromSuperview];
//    [self.navigationController.navigationBar sendSubviewToBack:[self.navigationController.navigationBar.subviews lastObject]];

//    UIImageView* newImageView = [[UIImageView alloc]initWithImage:[UIImage new]];
//        newImageView.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
//        newImageView.backgroundColor = [UIColor whiteColor];
//        [self.navigationController.navigationBar addSubview:newImageView];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"whiteImage"]
                                                  forBarMetrics:UIBarMetricsDefault];
//
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
//    self.navigationItem.backBarButtonItem.enabled = YES;

//    NSArray* array = [self.navigationController.navigationBar subviews];
//    NSLog(@"subs %@", array);
//    self.navigationController.navigationBar.subviews[1] = [[UIImageView alloc]initWithImage:[UIImage new]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //form stackOF
    // Replace titleView
    CGRect headerTitleSubtitleFrame = self.navigationController.navigationBar.frame;
    UIView* headerTitleSubtitleView = [[UILabel alloc] initWithFrame:headerTitleSubtitleFrame];
    headerTitleSubtitleView.backgroundColor = [UIColor clearColor];
    headerTitleSubtitleView.autoresizesSubviews = YES;
    
    CGRect titleFrame = CGRectMake(0, 2, 200, 24);
    UILabel *titleView = [[UILabel alloc] initWithFrame:titleFrame];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:20];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.textColor = [UIColor colorWithRed:(4/255.0f) green:(74/255.0f) blue:(11/255.0f) alpha:1.0];
    titleView.text = self.matchName;
    titleView.adjustsFontSizeToFitWidth = YES;
    [headerTitleSubtitleView addSubview:titleView];
    
    CGRect subtitleFrame = CGRectMake(0, 24, 200, 44-24);
    self.subtitleView = [[UILabel alloc] initWithFrame:subtitleFrame];
    self.subtitleView.backgroundColor = [UIColor clearColor];
    self.subtitleView.font = [UIFont boldSystemFontOfSize:13];
    self.subtitleView.textAlignment = NSTextAlignmentCenter;
    self.subtitleView.textColor = [UIColor colorWithRed:(4/255.0f) green:(74/255.0f) blue:(11/255.0f) alpha:1.0];
    self.subtitleView.text = self.matchDate;
    self.subtitleView.shadowColor = [UIColor darkGrayColor];
    self.subtitleView.adjustsFontSizeToFitWidth = YES;
    [headerTitleSubtitleView addSubview:self.subtitleView];
    
    headerTitleSubtitleView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                                UIViewAutoresizingFlexibleRightMargin |
                                                UIViewAutoresizingFlexibleTopMargin |
                                                UIViewAutoresizingFlexibleBottomMargin);
    
    self.navigationItem.titleView = headerTitleSubtitleView;
}

-(void) setUpSettingsButton
{
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"settings18"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleUsernameView)];
    rightButton.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void) setHeaderTitle:(NSString*)headerTitle andSubtitle:(NSString*)headerSubtitle {
    assert(self.navigationItem.titleView != nil);
    UIView* headerTitleSubtitleView = self.navigationItem.titleView;
    UILabel* titleView = [headerTitleSubtitleView.subviews objectAtIndex:0];
    UILabel* subtitleView = [headerTitleSubtitleView.subviews objectAtIndex:1];
    assert((titleView != nil) && (subtitleView != nil) && ([titleView isKindOfClass:[UILabel class]]) && ([subtitleView isKindOfClass:[UILabel class]]));
    titleView.text = headerTitle;
    subtitleView.text = headerSubtitle;
}

- (void)setupTableView
{
    
    self.tableView = [[UITableView alloc] init];
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view sendSubviewToBack:self.tableView.backgroundView];
    self.tableView.clipsToBounds=YES;
    
    self.tableView.scrollEnabled=YES;
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *tableViewTop = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0
                                                                     constant:self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height];
    
    NSLayoutConstraint *tableViewBottom = [NSLayoutConstraint constraintWithItem:self.tableView
                                           
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0
                                                                        constant:-40.0];
    
    NSLayoutConstraint *tableViewWidth = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:1.0
                                                                       constant:0.0];
    
    NSLayoutConstraint *tableViewLeft = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:0.0];
    
    [self.view addConstraints:@[tableViewTop, tableViewBottom, tableViewWidth, tableViewLeft]];
    
}

- (void)sendButtonTapped
{
    self.sendButton.backgroundColor=[UIColor colorWithRed:0.016 green:0.341 blue:0.22 alpha:0.5];
    
}

-(void)sendButtonNormal
{
    [self dismissKeyboard];
    
    if (![self.inputTextField.text isEqualToString:@""] && ![self.inputTextField.text isEqualToString:@" "]) {
        NSString *message = self.inputTextField.text;
        self.sendButton.titleLabel.textColor=[UIColor grayColor];
        [self.chatRoom.contentFireBase setValue:@{@"user":self.userName,
                                                  @"message":message
                                                  }];
        
//        PFQuery* chatMessageSentQuery = [PFInstallation query];
//        
//        if (self.matchUser)
//        {
//            [chatMessageSentQuery whereKey:@"user" equalTo:self.matchUser];
//            PFPush *push = [[PFPush alloc] init];
//            [push setQuery:chatMessageSentQuery];
//            
//            NSString* messageNotification = [NSString stringWithFormat:@"%@: %@",self.userName, message];
//            
//            [push setMessage:messageNotification];
//            
//            [push sendPushInBackground];
//        }

        self.inputTextField.text = @"";
    }
    self.sendButton.backgroundColor=[UIColor orangeColor];//colorWithRed:(4/255.0f) green:(74/255.0f) blue:(11/255.0f) alpha:1];
    self.sendButton.titleLabel.textColor=[UIColor whiteColor];
}

- (void)setupSendButton
{
    self.sendButton = [[UIButton alloc] init];
    [self.view addSubview:self.sendButton];
    self.sendButton.backgroundColor=[UIColor orangeColor];//colorWithRed:(4/255.0f) green:(74/255.0f) blue:(11/255.0f) alpha:1];
    self.sendButton.layer.cornerRadius=10.0f;
    self.sendButton.layer.masksToBounds=YES;
    [self.sendButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Send" attributes:nil] forState:UIControlStateNormal];
    self.sendButton.titleLabel.textColor=[UIColor whiteColor];
    [self.sendButton addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchDown];
    [self.sendButton addTarget:self action:@selector(sendButtonNormal) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    
    NSLayoutConstraint *sendButtonTop = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.tableView
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:4.0];
    
    NSLayoutConstraint *sendButtonBottom = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:-4.0]; //- self.tabBarController.tabBar.frame.size.height];//self.tabBarController.tabBar.frame];
    
    NSLayoutConstraint *sendButtonLeft = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.inputTextField
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:4.0];
    
    NSLayoutConstraint *sendButtonRight = [NSLayoutConstraint constraintWithItem:self.sendButton
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.tableView
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:-4.0];
    
    [self.view addConstraints:@[sendButtonTop, sendButtonBottom, sendButtonLeft, sendButtonRight]];
}

-(void)setupMediaButton
{
    self.mediaButton = [[UIButton alloc] init];
    [self.view addSubview:self.mediaButton];
    self.mediaButton.backgroundColor = [UIColor colorWithRed:(4/255.0f) green:(74/255.0f) blue:(11/255.0f) alpha:1];
    [self.mediaButton setImage:[UIImage imageNamed:@"photo-abstract-7"] forState:UIControlStateNormal];
    
    [self.mediaButton addTarget:self action:@selector(mediaButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.mediaButton addTarget:self action:@selector(mediaButtonTappedForBackground) forControlEvents:UIControlEventTouchDown];
    self.mediaButton.titleLabel.textColor = [UIColor whiteColor];
    self.mediaButton.layer.cornerRadius=10.0f;
    self.mediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *mediaButtonTop = [NSLayoutConstraint constraintWithItem:self.mediaButton
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.inputTextField
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1
                                                                       constant:0];
    
    NSLayoutConstraint *mediaButtonBottom =[NSLayoutConstraint constraintWithItem:self.mediaButton
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.inputTextField
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1
                                                                         constant:0];
    
    NSLayoutConstraint *mediaButtonLeft =[NSLayoutConstraint constraintWithItem:self.mediaButton
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1
                                                                       constant:4];
    
    NSLayoutConstraint *mediaButtonRight =[NSLayoutConstraint constraintWithItem:self.mediaButton
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.inputTextField
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1
                                                                        constant:-4];
    
    [self.view addConstraints:@[mediaButtonTop, mediaButtonBottom, mediaButtonLeft, mediaButtonRight]];
}

-(void)mediaButtonTappedForBackground
{
    self.mediaButton.backgroundColor = [UIColor colorWithRed:0.016 green:0.341 blue:0.22 alpha:.5];
}

- (void)setupTextField
{
    self.inputTextField = [[UITextField alloc] init];
    [self.view addSubview:self.inputTextField];
    self.inputTextField.layer.cornerRadius=10.0f;
    self.inputTextField.layer.masksToBounds=YES;
    UIColor *borderColor=[UIColor colorWithRed:51/255.0f green:171/255.0f blue:249/255.0f alpha:0.7];//(4/255.0f) green:(74/255.0f) blue:(11/255.0f) alpha:1];
    self.inputTextField.layer.borderColor=[borderColor CGColor];
    self.inputTextField.layer.borderWidth=1.5f;
    self.inputTextField.backgroundColor=[UIColor clearColor];
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.inputTextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.inputTextField setLeftView:spacerView];
    
    self.inputTextField.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *textFieldTop = [NSLayoutConstraint constraintWithItem:self.inputTextField
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.tableView
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0
                                                                     constant:4.0];
    
    NSLayoutConstraint *textFieldBottom = [NSLayoutConstraint constraintWithItem:self.inputTextField
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0
                                                                        constant:-4.0 ];//- self.tabBarController.tabBar.frame.size.height];
    
    NSLayoutConstraint *textFieldLeft = [NSLayoutConstraint constraintWithItem:self.inputTextField
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:4.0];
    
    NSLayoutConstraint *textFieldRight = [NSLayoutConstraint constraintWithItem:self.inputTextField
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.tableView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:-80.0];
    
    [self.view addConstraints:@[textFieldTop, textFieldBottom, textFieldLeft, textFieldRight]];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
