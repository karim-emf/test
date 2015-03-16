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


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self connectToParseWithOptions:launchOptions];
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self setUpApp];
    self.firstLoad = YES;
    [self checkForCurrentUser];
    
    // Override point for customization after application launch.
    return YES;
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
    KEMTabBarController* tabBarController = [[KEMTabBarController alloc]init];
    KEMLoginScreen* loginView = [KEMLoginScreen new];
//    LoginViewController* dayCriteriaView = [LoginViewController new];
    KEMDaySettings* daySettingsView = [KEMDaySettings new];
    KEMMatchesTVC* matchesTVC = [KEMMatchesTVC new];

    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:(4/255.0f) green:(74/255.0f) blue:(11/255.0f) alpha:.1]];
    
    
    if ([PFUser currentUser])
    {
        tabBarController.viewControllers = @[daySettingsView, matchesTVC, loginView];
    }
    else
    {
        tabBarController.viewControllers = @[loginView, daySettingsView, matchesTVC];
    }
    UINavigationController* navController = [[UINavigationController alloc]initWithRootViewController:tabBarController];
    [navController.navigationBar setTintColor:[UIColor clearColor]];
    self.window.rootViewController = navController;
}

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
}



@end
