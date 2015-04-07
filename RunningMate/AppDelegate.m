//
//  AppDelegate.m
//  RunningMate
//
//  Created by Karim Mourra on 1/29/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "AppDelegate.h"
#import "KEMLoginScreen.h"
#import "KEMMatchesTVC.h"
#import "KEMTabBarController.h"
#import "KEMDaySettings.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Firebase/Firebase.h>
#import "KEMDataStore.h"
#import "KEMFirebaseLiaison.h"


@interface AppDelegate ()

@property (strong, nonatomic) KEMDataStore* dataStore;
@property (strong, nonatomic) KEMTabBarController* tabBarController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self connectToParseWithOptions:launchOptions];
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self setUpApp];
    [self setUpParseNotificationForApplication:application];
    self.firstLoad = YES;
    [self checkForCurrentUser];
    self.dataStore = [KEMDataStore sharedDataManager];
    
    KEMFirebaseLiaison* firebaseLiaison = [KEMFirebaseLiaison firebaseLiaisonSingleton];
    [firebaseLiaison registerForChatNotificationsOfActiveChats];
    
    return YES;
}


-(void)setUpParseNotificationForApplication:(UIApplication *)application
{
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[PFFacebookUtils session] close];
}

-(void)checkForCurrentUser
{
    PFUser* currentUser = [PFUser currentUser];
    if (currentUser)
    {
        NSLog(@"current user logged");
    }
    else
    {
        NSLog(@"no user");
    }
}

-(void) connectToParseWithOptions:(NSDictionary *)launchOptions
{
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    
    [Parse enableLocalDatastore];
    // Initialize Parse.
    [Parse setApplicationId:@"Chyxnoegs8vjRHlcDh40U3XiSs7L9Q8hRmj9cRkI"
                  clientKey:@"ZHOn0GlN7Exc4ZfAueGo2CZfK9MRmgPjp44VqXb5"];
    //****** from parse
    [PFFacebookUtils initializeFacebook];
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
}



-(void)setUpApp
{
    self.tabBarController = [[KEMTabBarController alloc]init];
    KEMLoginScreen* loginView = [KEMLoginScreen new];
    KEMDaySettings* daySettingsView = [KEMDaySettings new];
    KEMMatchesTVC* matchesTVC = [KEMMatchesTVC new];

    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:(4/255.0f) green:(74/255.0f) blue:(11/255.0f) alpha:.1]];
    
    UINavigationController *navSetting = [[UINavigationController alloc] initWithRootViewController:daySettingsView];
    UINavigationController *navMatches = [[UINavigationController alloc] initWithRootViewController:matchesTVC];
    
    if ([PFUser currentUser])
    {
        self.tabBarController.viewControllers = @[navSetting, navMatches, loginView];
    }
    else
    {
        self.tabBarController.viewControllers = @[loginView, navSetting, navMatches];
    }
    self.window.rootViewController = self.tabBarController;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self suscribeToParseNotificationsWithDeviceToken:deviceToken];
}

-(void)suscribeToParseNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

-(NSArray*)obtainMatchesTVCAndNavigationControllerFromTabBar
{
    NSArray* VCs = self.tabBarController.viewControllers;
    
    for (UIViewController* vc in VCs)
    {
        if ([vc.class isSubclassOfClass:[UINavigationController class]])
        {
            UIViewController* childVC = ((UIViewController*) vc.childViewControllers[0]);
            
            if ([childVC.class isSubclassOfClass:[KEMMatchesTVC class]])
            {
                KEMMatchesTVC* matchVC = vc.childViewControllers[0];
                return @[matchVC, vc];
            }
        }
    }
    return nil;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive)
    {
        KEMMatchesTVC* matchVC = [self obtainMatchesTVCAndNavigationControllerFromTabBar][0];
        
        if (matchVC)
        {
            matchVC.tabBarItem.image = [[UIImage imageNamed:@"message!"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [matchVC.tabBarItem setTitle:@"New Chat!"];
            [matchVC.tabBarItem setTitleTextAttributes:@{
                                                         NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f],
                                                         NSForegroundColorAttributeName: [UIColor yellowColor]
                                                         }
                                              forState:UIControlStateNormal];
        }
        
        

//        UIViewController* vc = VCs[0];
//        NSLog(@"--- %@", vc.class);
//        NSString* navControllerClassName = @"UINavigationController";
//        NSPredicate *predicateForNavControllers = [NSPredicate predicateWithFormat:@"SELF.class == %@", navControllerClassName];
//        NSArray *navControllers = [VCs filteredArrayUsingPredicate:predicateForNavControllers];
//        
//        NSPredicate *predicateForMatchesTVC = [NSPredicate predicateWithFormat:@"class == %@", @"KEMMatchesTVC"];
//        NSArray *matchesTVCs = [navControllers filteredArrayUsingPredicate:predicateForMatchesTVC];
//        UIViewController* matchVC = matchesTVCs[0];
        
        //bad! detect which one is matchVC
//        UIViewController* matchVC = self.tabBarController.viewControllers[1];
        
        //now we need to reverse this when we hit the tab
        //we also need to
        //in matchTVC change the cell when there is a new message in it
        //remove old notifications!
        
    }
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{    
    if ([userInfo[@"aps"][@"alert"] isEqualToString:@"You have a new match!"])
    {
        [PFPush handlePush:userInfo];
        self.dataStore.notificationFromParse = YES;
        [self.dataStore pushPreferencesToParse];
        
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:@"newMatch" object:nil];
    }
    //delete to remove parse notifs
//    else
//    {
//        if ( ! self.inChatRoom)
//        {
//            [PFPush handlePush:userInfo];
//        }
//    }
}

//-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
//{
//    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"A new chat was received!" message:notification.alertBody delegate:nil 	cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alertView show];
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    UIApplication *app = [UIApplication sharedApplication];
    UIBackgroundTaskIdentifier bgTask;
    KEMFirebaseLiaison* firebaseLiaison = [KEMFirebaseLiaison firebaseLiaisonSingleton];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
    }];
    [firebaseLiaison registerForChatNotificationsOfActiveChats];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        application.applicationIconBadgeNumber = 0;
    
    //if save buttton has been hit, reorder the tab view. method returns array [1] is navController.
}



@end
