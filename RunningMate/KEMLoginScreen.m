//
//  KEMDayCriteria.m
//  RunningMate
//
//  Created by Karim Mourra on 1/29/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "KEMLoginScreen.h"
#import <NMRangeSlider/NMRangeSlider.h>
#import "UserDetailsViewController.h"
#import <Parse/Parse.h>

@interface KEMLoginScreen () {

}

@property (strong, nonatomic) IBOutlet NMRangeSlider *timeRange;
@property (strong, nonatomic) IBOutlet UILabel *lowerLabel;
@property (strong, nonatomic) IBOutlet UILabel *upperLabel;
@property (strong, nonatomic) UIButton* fbButton;
@property (strong, nonatomic) UIImageView* logoView;
@end

@implementation KEMLoginScreen

- (instancetype)init
{
    self = [super init];
    if (self) {
//        [self.tabBarItem initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:1];
        if([PFUser currentUser])
        {
            [self.tabBarItem initWithTitle:@"Logout" image:[UIImage imageNamed:@"paper-piece-minus-7"] selectedImage:nil];
        }
        else
        {
            [self.tabBarItem initWithTitle:@"Login" image:[UIImage imageNamed:@"paper-piece-tick-7"] selectedImage:nil];
        }
    }
    return self;
}

- (UIImage*)imageWithImage:(UIImage *)image convertToWidth:(float)width {
    float ratio = image.size.width / width;
    float height = image.size.height / ratio;
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"concepcionJog"]];
    backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImage.frame=self.view.frame;
    

    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    [self setUpLogo];

//--- the parse way
    self.fbButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.center.x, self.view.center.y, (self.view.frame.size.width*0.7f), 50)];
    self.fbButton.center = self.view.center;
    self.fbButton.backgroundColor = [UIColor colorWithRed:(59/255.0) green:(89/255.0) blue:(152/255.0) alpha:1];
    self.fbButton.titleLabel.frame = self.fbButton.frame;
    
    self.fbButton.layer.masksToBounds = YES;
    self.fbButton.layer.cornerRadius = 10.0f;
    UIColor *borderColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    self.fbButton.layer.borderColor =[borderColor CGColor];
    self.fbButton.layer.borderWidth = 1.0f;
    self.fbButton.titleLabel.textColor = [UIColor whiteColor];
    
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        [self.fbButton setTitle:@"Log out of Facebook!" forState:UIControlStateNormal];
        [self.fbButton addTarget:self action:@selector(logoutButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
            [self.fbButton addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchDown];
    }
    else
    {
        [self.fbButton setTitle:@"Login with Facebook!" forState:UIControlStateNormal];
        [self.fbButton addTarget:self action:@selector(loginButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
            [self.fbButton addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchDown];
    }
    [self.view addSubview:self.fbButton];
    [self positionFbButton];
}

-(void)buttonTapped
{
    self.fbButton.backgroundColor=[UIColor colorWithRed:0.016 green:0.341 blue:0.22 alpha:0.5];
}

-(void)setUpLogo
{
    UIImage* resizedLogo = [self imageWithImage:[UIImage imageNamed:@"logo"] convertToWidth:self.view.frame.size.width];
    self.logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/5, self.view.frame.size.width, 50)];// initWithImage:resizedLogo];
    self.logoView.image = resizedLogo;
    [self.view addSubview:self.logoView];
    
    self.logoView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *logoHeight = [NSLayoutConstraint constraintWithItem:self.logoView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeHeight
                                                                     multiplier:0.0
                                                                       constant:50];
    
    NSLayoutConstraint *logoTop = [NSLayoutConstraint constraintWithItem:self.logoView
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1
                                                                       constant:self.view.frame.size.height/5];
    
    NSLayoutConstraint *logoWidth = [NSLayoutConstraint constraintWithItem:self.logoView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1.0
                                                                      constant:0.0];
    
    NSLayoutConstraint *logoCenterX = [NSLayoutConstraint constraintWithItem:self.logoView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1.0
                                                                        constant:0.0];
    
    [self.view addConstraints:@[logoCenterX,logoHeight,logoWidth,logoTop]];
    
}

-(void)positionFbButton
{
    self.fbButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *fbButtonHeight = [NSLayoutConstraint constraintWithItem:self.fbButton
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:0.0
                                                                     constant:50];
    
    NSLayoutConstraint *fbButtonBottom = [NSLayoutConstraint constraintWithItem:self.fbButton
                                           
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0
                                                                        constant:-(self.tabBarController.tabBar.frame.size.height * 2)];
    
    NSLayoutConstraint *fbButtonWidth = [NSLayoutConstraint constraintWithItem:self.fbButton
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:0.70
                                                                       constant:0.0];
    
    NSLayoutConstraint *fbButtonCenterX = [NSLayoutConstraint constraintWithItem:self.fbButton
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0
                                                                      constant:0.0];
    
    [self.view addConstraints:@[fbButtonBottom,fbButtonCenterX,fbButtonHeight,fbButtonWidth]];
    
}

- (IBAction)logoutButtonTouchHandler:(id)sender
{
    self.fbButton.backgroundColor=[UIColor colorWithRed:(59/255.0) green:(89/255.0) blue:(152/255.0) alpha:1];
    self.fbButton.titleLabel.textColor=[UIColor whiteColor];
    
    [PFUser logOut];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log out completed"
                                                    message:@"Please be aware that matches won't occur until you log back in!"
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Dismiss", nil];
    [alert show];
    
    [self.fbButton setTitle:@"Login with Facebook!" forState:UIControlStateNormal];
    [self.fbButton removeTarget:self action:@selector(logoutButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.fbButton addTarget:self action:@selector(loginButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)loginButtonTouchHandler:(id)sender
{
    self.fbButton.backgroundColor=[UIColor colorWithRed:(59/255.0) green:(89/255.0) blue:(152/255.0) alpha:1];
    self.fbButton.titleLabel.textColor=[UIColor whiteColor];
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unsuccessful Login"
                                                            message:@"Please try again"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
        else
        {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
            } else {
                NSLog(@"User with facebook logged in!");
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Awesome!"
                                                            message:@"Your login was successful!"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            
            [alert show];
            
            [self.fbButton setTitle:@"Log out of Facebook!" forState:UIControlStateNormal];
            [self.fbButton removeTarget:self action:@selector(loginButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
            [self.fbButton addTarget:self action:@selector(logoutButtonTouchHandler:) forControlEvents:UIControlEventTouchUpInside];
            [self _presentUserDetailsViewControllerAnimated:YES];
        }
    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

#pragma mark -
#pragma mark UserDetailsViewController

- (void)_presentUserDetailsViewControllerAnimated:(BOOL)animated {
    UserDetailsViewController *detailsViewController = [[UserDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self presentViewController:detailsViewController animated:YES completion:^{
        
    }];
//    [self.navigationController pushViewController:detailsViewController animated:animated];
}


/*

//---anypic!
//- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
//    [self handleFacebookSession];
//}
//
//- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
//    [self handleLogInError:error];
//}
//
//- (void)handleFacebookSession {
//    if ([PFUser currentUser]) {
//        if (self.delegate && [self.delegate respondsToSelector:@selector(logInViewControllerDidLogUserIn:)]) {
//            [self.delegate performSelector:@selector(logInViewControllerDidLogUserIn:) withObject:[PFUser currentUser]];
//        }
//        return;
//    }
//    
//    NSString *accessToken = [[[FBSession activeSession] accessTokenData] accessToken];
//    NSDate *expirationDate = [[[FBSession activeSession] accessTokenData] expirationDate];
//    NSString *facebookUserId = [[[FBSession activeSession] accessTokenData] userID];
//    
//    if (!accessToken || !facebookUserId) {
//        NSLog(@"Login failure. FB Access Token or user ID does not exist");
//        return;
//    }
//    if ([[FBSession activeSession] respondsToSelector:@selector(clearAffinitizedThread)]) {
//        [[FBSession activeSession] performSelector:@selector(clearAffinitizedThread)];
//    }
//    
//    [PFFacebookUtils logInWithFacebookId:facebookUserId
//                             accessToken:accessToken
//                          expirationDate:expirationDate
//                                   block:^(PFUser *user, NSError *error) {
//                                       
//                                       if (!error) {
////                                           [self.hud removeFromSuperview];
//                                           if (self.delegate) {
//                                               if ([self.delegate respondsToSelector:@selector(logInViewControllerDidLogUserIn:)]) {
//                                                   [self.delegate performSelector:@selector(logInViewControllerDidLogUserIn:) withObject:user];
//                                               }
//                                           }
//                                       } else {
//                                           [self cancelLogIn:error];
//                                       }
//                                   }];
//}
//
//- (void)cancelLogIn:(NSError *)error {
//    
//    if (error) {
//        [self handleLogInError:error];
//    }
//    
////    [self.hud removeFromSuperview];
//    [[FBSession activeSession] closeAndClearTokenInformation];
//    [PFUser logOut];
////    [(AppDelegate *)[[UIApplication sharedApplication] delegate] presentLoginViewController:NO];
//}
//
//- (void)handleLogInError:(NSError *)error {
//    if (error) {
//        NSLog(@"Error: %@", [[error userInfo] objectForKey:@"com.facebook.sdk:ErrorLoginFailedReason"]);
//        NSString *title = NSLocalizedString(@"Login Error", @"Login error title in PAPLogInViewController");
//        NSString *message = NSLocalizedString(@"Something went wrong. Please try again.", @"Login error message in PAPLogInViewController");
//        
//        if ([[[error userInfo] objectForKey:@"com.facebook.sdk:ErrorLoginFailedReason"] isEqualToString:@"com.facebook.sdk:UserLoginCancelled"]) {
//            return;
//        }
//        
//        if (error.code == kPFErrorFacebookInvalidSession) {
//            NSLog(@"Invalid session, logging out.");
//            [[FBSession activeSession] closeAndClearTokenInformation];
//            return;
//        }
//        
//        if (error.code == kPFErrorConnectionFailed) {
//            NSString *ok = NSLocalizedString(@"OK", @"OK");
//            NSString *title = NSLocalizedString(@"Offline Error", @"Offline Error");
//            NSString *message = NSLocalizedString(@"Something went wrong. Please try again.", @"Offline message");
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
//                                                            message:message
//                                                           delegate:nil
//                                                  cancelButtonTitle:nil
//                                                  otherButtonTitles:ok, nil];
//            [alert show];
//            
//            return;
//        }
//        
//        NSString *ok = NSLocalizedString(@"OK", @"OK");
//        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
//                                                            message:message
//                                                           delegate:self
//                                                  cancelButtonTitle:nil
//                                                  otherButtonTitles:ok, nil];
//        [alertView show];
//    }
//}


- (IBAction)loginButtonTouchHandler:(id)sender
{

    NSArray *permissions = @[];//@[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];

    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error)
     {
        [self.activityIndicator stopAnimating];
        
        if (!user)
        {
            NSString *errorMessage = nil;
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
        else if (user.isNew)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logged in!"
                                                            message:@"User signed up and logged in through Facebook!"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
            
            NSLog(@"User signed up and logged in through Facebook!");
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logged in!"
                                                            message:@"User logged in through Facebook!"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
            
            NSLog(@"User logged in through Facebook!");
        }
    }];
    
    [self.activityIndicator startAnimating];
 //=======
    
//    // Set permissions required from the facebook user account
//    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
//    
//    // Login PFUser using Facebook
//    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
////        [_activityIndicator stopAnimating]; // Hide loading indicator
//        
//        if (!user) {
//            NSString *errorMessage = nil;
//            if (!error) {
//                NSLog(@"Uh oh. The user cancelled the Facebook login.");
//                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
//            } else {
//                NSLog(@"Uh oh. An error occurred: %@", error);
//                errorMessage = [error localizedDescription];
//            }
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
//                                                            message:errorMessage
//                                                           delegate:nil
//                                                  cancelButtonTitle:nil
//                                                  otherButtonTitles:@"Dismiss", nil];
//            [alert show];
//        } else {
//            if (user.isNew) {
//                NSLog(@"User with facebook signed up and logged in!");
//            } else {
//                NSLog(@"User with facebook logged in!");
//            }
////            [self _presentUserDetailsViewControllerAnimated:YES];
//        }
//    }];
//    
////    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}

- (void)_presentUserDetailsViewControllerAnimated:(BOOL)animated
{
//    UserDetailsViewController *detailsViewController = [[UserDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped];
//    [self.navigationController pushViewController:detailsViewController animated:animated];
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
    float screenWidth = self.view.frame.size.width;
    self.timeRange = [[NMRangeSlider alloc]initWithFrame:CGRectMake(20, 60, screenWidth-40, 30)];
    [self.timeRange addTarget:self action:@selector(timeRangeChanged:) forControlEvents:UIControlEventValueChanged];
    self.timeRange.stepValue = 1;
    self.timeRange.stepValueContinuously = NO;
    
    NSNumber* currentHour = [self obtainCurrentHourAndMins][0];
    NSNumber* currentMins = [self obtainCurrentHourAndMins][1];
    
    NSArray* nextQuarter = [self convertToNextQuarter:@[currentHour, currentMins]];
    
    NSNumber* minHour = nextQuarter[0];
    NSNumber* minNextPoint = nextQuarter[2];
    
    self.timeRange.minimumValue = [minHour floatValue]*4 + [minNextPoint floatValue];
    NSLog(@"min val : %f", self.timeRange.minimumValue);
    self.timeRange.maximumValue = 24.0 * 4;
    [self.timeRange setLowerValue:self.timeRange.minimumValue upperValue:self.timeRange.maximumValue animated:NO];
    
    
//    self.timeRange.lowerValue = self.timeRange.minimumValue;
//    self.timeRange.upperValue = self.timeRange.maximumValue;
    
    self.timeRange.minimumRange = 1;
    
    self.lowerLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.timeRange.lowerCenter.x + self.timeRange.frame.origin.x, self.timeRange.lowerCenter.y - 30, 60, 20)];
    self.upperLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.timeRange.upperCenter.x + self.timeRange.frame.origin.x, self.timeRange.upperCenter.y - 60, 60, 20)];
    

    //-----
    CGPoint lowerCenter;
    lowerCenter.x = (self.timeRange.frame.origin.x);//(self.timeRange.lowerCenter.x + self.timeRange.frame.origin.x);
    NSLog(@"low center x : %f", lowerCenter.x);
    lowerCenter.y = (self.timeRange.center.y + 30.0f);
    self.lowerLabel.center = lowerCenter;
    self.lowerLabel.text = [NSString stringWithFormat:@"%@", [self convertToHourMinuteFormat:(int)self.timeRange.lowerValue]];
    
    CGPoint upperCenter;
    upperCenter.x = (self.timeRange.frame.size.width);
    NSLog(@"Up center x : %f", upperCenter.x);
    upperCenter.y = (self.timeRange.center.y - 30.0f);
    self.upperLabel.center = upperCenter;
    self.upperLabel.text = [NSString stringWithFormat:@"%@", [self convertToHourMinuteFormat:(int)self.timeRange.upperValue]];
    //-----

    
    [self.timeRange layoutSubviews];
    [self.timeRange setNeedsLayout];
    
    [self.view addSubview:self.timeRange];
    [self.view addSubview:self.lowerLabel];
    [self.view addSubview:self.upperLabel];


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
}

*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
