//
//  KEMMatchesTVC.m
//  RunningMate
//
//  Created by Karim Mourra on 3/3/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "KEMMatchesTVC.h"
#import "KEMDataStore.h"
#import "KEMChatRoomVC.h"
#import "KEMChatRoom.h"
#import <Parse/Parse.h>
#import "KEMFbProfileInfo.h"
#import "KEMMatchDateCell.h"
#import "KEMMatchIDCell.h"



@interface KEMMatchesTVC ()

@property (strong, nonatomic) KEMDataStore* dataStore;
@property (strong, nonatomic) NSMutableArray* matches;
@property (strong, nonatomic) NSMutableDictionary* matchesByDate;
@property (strong, nonatomic) UIImageView *logoImageView;

@property (strong, nonatomic) KEMChatRoom *chatRoom;
@property (strong, nonatomic) NSString* userName;
@property (strong, nonatomic) PFUser* matchUser;

@property (strong, nonatomic) NSMutableArray* blinkingCellIdentifyers;

@end

@implementation KEMMatchesTVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self.tabBarItem initWithTitle:@"Matches" image:[UIImage imageNamed:@"message-7" ] selectedImage:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(/*CGRectGetHeight(self.navigationController.navigationBar.frame)*/ + [UIApplication sharedApplication].statusBarFrame.size.height, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    
    self.logoImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo"]];
    
    self.logoImageView.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    
    [self.navigationController.navigationBar addSubview:self.logoImageView];
    //    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    //    [self.navigationController.navigationBar sendSubviewToBack:tileImageView];
    
    
    self.dataStore = [KEMDataStore sharedDataManager];
    [self.dataStore fetchMatches];
    self.matches = self.dataStore.matches;//might not even need this
    self.matchesByDate =self.dataStore.matchesByDate;
    
    KEMFbProfileInfo* fbProfileInfo = [self.dataStore fetchFbProfileInfo];
    self.userName = [self shortenName:fbProfileInfo.fbName];
    
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if ( ! [PFUser currentUser])
    {
        [self alertIfNotLoggedIn];
    }
    
    self.blinkingCellIdentifyers = [@[] mutableCopy];
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(addIdentifyerForBlinkingCell:) name:@"chatReceived" object:nil];
    [notificationCenter addObserver:self selector:@selector(callReloadData) name:@"newMatch" object:nil];
}

-(void)callReloadData
{
    [self.tableView reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSDate*)convertStringToNSDate:(NSString*)dateString
{

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    dateFromString = [dateFormatter dateFromString:dateString];
    return dateFromString;
    
    /*
     
REVERSE
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *stringDate = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"%@", stringDate);
     */
}

-(void)viewDidAppear:(BOOL)animated
{
//    UIViewController* matchVC = self.tabBarController.viewControllers[1];

    self.tabBarItem.image = [UIImage imageNamed:@"message-7"];
    [self.tabBarItem setTitle:@"Matches"];

    [self.tabBarItem setTitleTextAttributes:@{
                                                 NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:10.0f],
                                                 NSForegroundColorAttributeName: [UIColor grayColor]
                                                 }
                                   forState:UIControlStateNormal];
    
    [self.tabBarItem setTitleTextAttributes:@{
                                              NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:10.0f],
                                              NSForegroundColorAttributeName: [UIColor whiteColor]
                                              }
                                   forState:UIControlStateSelected];
    


}

-(void)alertIfNotLoggedIn
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You are not logged in!"
                                                    message:@"You can chat with existing matches but new matches won't be added until you log in!"
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"Got it!", nil];
    [alert show];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = NO;
    [self.navigationController.navigationBar bringSubviewToFront:self.logoImageView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.matches[indexPath.row] class] isSubclassOfClass:[NSString class]])
    {
        return 50;
    }
    else
    {
        return 100;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* matchDates = [self.matchesByDate allKeys];
    NSArray* sortedMatchDates = [matchDates sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.matches = [[NSMutableArray alloc]initWithArray:@[]];
    for (NSString* date in sortedMatchDates)
    {
        NSDate* convertedDate = [self convertStringToNSDate:date];
        [self.matches addObject:convertedDate];
        [self.matches addObjectsFromArray:self.matchesByDate[date]];
    }
    return [self.matches count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.matches[indexPath.row] class] isSubclassOfClass:[NSDate class]])
    {
        KEMMatchDateCell* cell = (KEMMatchDateCell*)[tableView dequeueReusableCellWithIdentifier:@"matchDateCell"];
        
        if (cell == nil)
        {
            cell = [[KEMMatchDateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"matchDateCell"];
        }
        cell.dateLabel.text = self.matches[indexPath.row];
        
        return  cell;
//        stdCell.textLabel.text = self.matches[indexPath.row];
    }
    else
    {
        KEMMatchIDCell* cell = (KEMMatchIDCell*)[tableView dequeueReusableCellWithIdentifier:@"matchIDCell"];
        
        if (cell == nil)
        {
            cell = [[KEMMatchIDCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"matchIDCell"];
        }
        cell.nameLabel.text = [self shortenName:((KEMMatch*)self.matches[indexPath.row]).fbName];
        
        if ( ! ((KEMMatch*)self.matches[indexPath.row]).fbProfilePic || [((KEMMatch*)self.matches[indexPath.row]).fbProfilePic isEqualToString:@"N/A"])
        {
            cell.profilePicView.image = [UIImage imageNamed:@"genericProfile"];
        }
        else
        {
            cell.profilePicView.image = [self stringToUIImage:((KEMMatch*)self.matches[indexPath.row]).fbProfilePic];
        }
        
        if ([self.blinkingCellIdentifyers containsObject:@(indexPath.row)])
        {
            [self blinkCell:cell];
        }

        return  cell;
//        stdCell.textLabel.text =[self shortenName:((KEMMatch*)self.matches[indexPath.row]).fbName];
    }
}

- (void) addIdentifyerForBlinkingCell:(NSNotification *)notification
{
        NSNumber* identifyer = notification.userInfo[@"row"];
    [self.blinkingCellIdentifyers addObject:identifyer];
    [self.tableView reloadData];
}
- (void) blinkCell:(UITableViewCell*)cell
{
//    NSInteger row = [notification.userInfo[@"row"] integerValue];
//    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:row inSection:0];
//    UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
    [self performCellBlink:cell];
}

- (void) performCellBlink: (UITableViewCell*) cell
{
    cell.backgroundColor = [UIColor yellowColor];
    [self performSelector:@selector(continueCellBlink:) withObject:cell afterDelay:0.3];
}

- (void) continueCellBlink: (UITableViewCell*) cell
{
    NSIndexPath* cellIP = [[self tableView] indexPathForCell:cell];
    
    if ([self.blinkingCellIdentifyers containsObject:@(cellIP.row)])
    {
        cell.backgroundColor = [UIColor clearColor];
        [self performSelector:@selector(performCellBlink:) withObject:cell afterDelay:0.3];
    }
    else
    {
        [self endCellBlink:cell];
    }
}

- (void) endCellBlink: (UITableViewCell*) cell
{
    cell.backgroundColor = [UIColor clearColor];
}



-(UIImage *)stringToUIImage:(NSString *)string
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    return [UIImage imageWithData:data];
}

-(NSString*)shortenName:(NSString*)nameStr
{
    NSArray* firstAndLastStrings = [nameStr componentsSeparatedByString:@" "];
    
    if ([firstAndLastStrings count] > 2)
    {
        NSString* firstName = [firstAndLastStrings objectAtIndex:0];
        NSString* middleName = [firstAndLastStrings objectAtIndex:1];
        NSString* lastName = [firstAndLastStrings objectAtIndex:2];
        char middleInitialChar = [middleName characterAtIndex:0];
        char lastInitialChar = [lastName characterAtIndex:0];
        NSString* newNameStr = [NSString stringWithFormat:@"%@ %c %c.", firstName, middleInitialChar, lastInitialChar];
        return newNameStr;
    }
    else
    {
        NSString* firstName = [firstAndLastStrings objectAtIndex:0];
        NSString* lastName = [firstAndLastStrings objectAtIndex:1];
        char lastInitialChar = [lastName characterAtIndex:0];
        NSString* newNameStr = [NSString stringWithFormat:@"%@ %c.", firstName, lastInitialChar];
        return newNameStr;
    }
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( ! [[self.matches[indexPath.row] class] isSubclassOfClass:[NSString class]])
    {
        if ([self.blinkingCellIdentifyers containsObject:@(indexPath.row)])
        {
            [self.blinkingCellIdentifyers removeObject:@(indexPath.row)];
        }
        
        
        KEMMatch* selectedMatch = self.matches[indexPath.row];
        self.chatRoom=[[KEMChatRoom alloc]init];
        
        PFQuery* matchUserQuery= [PFUser query];// queryWithClassName:@"User"];
        [matchUserQuery whereKey:@"objectId" equalTo:selectedMatch.objID];
        [matchUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
        {
            if (!error && [objects count]>0)
            {
//                PFObject* preference = objects[0];
                self.matchUser = objects[0];//preference[@"user"];
            }
            
            self.chatRoom.firebaseRoomName= [self makeFirebaseRoomNameFromDate:selectedMatch.runDate MatchObjID:selectedMatch.objID AndUserObjID:[PFUser currentUser].objectId];
            
            KEMChatRoomVC *destinationViewController = [KEMChatRoomVC new];
            destinationViewController.chatRoom=self.chatRoom;
            destinationViewController.userName = self.userName;
            destinationViewController.matchDate = ((KEMMatch*)self.matches[indexPath.row]).runDate;
            destinationViewController.matchName = [self shortenName:((KEMMatch*)self.matches[indexPath.row]).fbName];
            destinationViewController.matchUser = self.matchUser;
            
            [self.navigationController.navigationBar sendSubviewToBack:self.logoImageView];
            [self.navigationController pushViewController:destinationViewController animated:YES];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self endCellBlink:[[self tableView] cellForRowAtIndexPath:indexPath]];
        }];
        
    }
}

-(NSString*)makeFirebaseRoomNameFromDate:(NSString*)Date MatchObjID:(NSString*)matchObjID AndUserObjID:(NSString*)userObjID
{
    NSString* firstObjID;
    NSString* secondObjID;
    NSComparisonResult result = [matchObjID compare:userObjID];
    if (result == NSOrderedAscending)
    {
        firstObjID = matchObjID;
        secondObjID = userObjID;
    }
    else if (result == NSOrderedDescending)
    {
        firstObjID = userObjID;
        secondObjID = matchObjID;
    }
    else
    {
        NSLog(@"AAAAAAHHHHHHHHRRRRRRRGGGGGGGG !!!!!");
    }
    return [NSString stringWithFormat:@"%@-%@-%@",Date, firstObjID, secondObjID];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
