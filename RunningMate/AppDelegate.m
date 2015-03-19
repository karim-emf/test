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
#import "KEMDataStore.h"


@interface AppDelegate ()

@property (strong, nonatomic) KEMDataStore* dataStore;

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
//    [NSThread sleepForTimeInterval:1];
    
    // Override point for customization after application launch.
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
    
//    NSOperationQueue *secondQueue = [NSOperationQueue new];
//    [secondQueue addOperationWithBlock:^{
        [Parse enableLocalDatastore];
        
        // Initialize Parse.
        [Parse setApplicationId:@"Chyxnoegs8vjRHlcDh40U3XiSs7L9Q8hRmj9cRkI"
                      clientKey:@"ZHOn0GlN7Exc4ZfAueGo2CZfK9MRmgPjp44VqXb5"];
        
        //****** from parse
        [PFFacebookUtils initializeFacebook];
        
        // [Optional] Track statistics around application opens.
        [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        
//    }];
}



-(void)setUpApp
{
    KEMTabBarController* tabBarController = [[KEMTabBarController alloc]init];
    
    KEMLoginScreen* loginView = [KEMLoginScreen new];
    KEMDaySettings* daySettingsView = [KEMDaySettings new];
    KEMMatchesTVC* matchesTVC = [KEMMatchesTVC new];

    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:(4/255.0f) green:(74/255.0f) blue:(11/255.0f) alpha:.1]];
    
    UINavigationController *navSetting = [[UINavigationController alloc] initWithRootViewController:daySettingsView];
    UINavigationController *navMatches = [[UINavigationController alloc] initWithRootViewController:matchesTVC];
    
    if ([PFUser currentUser])
    {
        tabBarController.viewControllers = @[navSetting, navMatches, loginView];
    }
    else
    {
        tabBarController.viewControllers = @[loginView, navSetting, navMatches];
    }
    
//    UINavigationController* navController = [[UINavigationController alloc]initWithRootViewController:tabBarController];

    self.window.rootViewController = tabBarController; //navController;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    NSLog(@"parse installation ID: %@", currentInstallation.installationId);
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{    
    if ([userInfo[@"aps"][@"alert"] isEqualToString:@"You have a new match!"])
    {
        [PFPush handlePush:userInfo];
        self.dataStore.notificationFromParse = YES;
        [self.dataStore pushPreferencesToParse];
    }
    else
    {
        if ( ! self.inChatRoom)
        {
            [PFPush handlePush:userInfo];
        }
    }
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        application.applicationIconBadgeNumber = 0;
}



@end
