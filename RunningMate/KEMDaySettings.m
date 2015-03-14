//
//  KEMDaySettings.m
//  RunningMate
//
//  Created by Karim Mourra on 1/30/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "KEMDaySettings.h"
#import <NMRangeSlider/NMRangeSlider.h>
#import "KEMTimeRangeCell.h"
#import "KEMDistanceRangeCell.h"
#import "KEMDurationRangeCell.h"

#import "KEMConversationPreferenceCell.h"
#import "KEMMyMusicPreferenceCell.h"
#import "KEMPartnerMusicPreferenceCell.h"
#import "KEMSpeedTolerance.h"
#import "KEMSpeedSlowest.h"
#import "KEMSpeedFastest.h"
#import "KEMDataStore.h"

#import "KEMLocationVC.h"

@interface KEMDaySettings ()

@property (strong,nonatomic) NSDictionary* criterias;
@property (strong,nonatomic) NSMutableArray* times;
@property (nonatomic) NSInteger count;
@property (strong, nonatomic) KEMDataStore* dataStore;
@property (strong, nonatomic) KEMDailyPreference* preferenceOfTheDay;

@property(strong,nonatomic) CLLocationManager* locationManager;
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@end

@implementation KEMDaySettings

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self.tabBarItem initWithTitle:@"Preferences" image:[UIImage imageNamed:@"note-write-7" ] selectedImage:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager  requestWhenInUseAuthorization];
    
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background*"]];
    backgroundImage.frame=self.view.frame;
    self.tableView.backgroundView = backgroundImage;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.count = 0;
    self.times = [@[@"times"] mutableCopy];
    [self updateCriterias:self.times];
    
    [self setUpTapRecognizers];
    
    self.dataStore = [KEMDataStore sharedDataManager];
    //-------------------
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *year = [formatter stringFromDate:now];
    [formatter setDateFormat:@"MM"];
    NSString *month = [formatter stringFromDate:now];
    [formatter setDateFormat:@"dd"];
    NSString *day = [formatter stringFromDate:now];
    NSString *date = [day stringByAppendingFormat:@"-%@-%@", month, year];
    
    [self.dataStore fetchPreferencesOf:date];
    //-------------------
    
    self.preferenceOfTheDay = [self.dataStore.dailyPreferences objectForKey:date];
    if (! self.preferenceOfTheDay)
    {
        [self.dataStore createDailyPreference];
        self.preferenceOfTheDay = [self.dataStore.dailyPreferences objectForKey:date];
        //shouldnt this say self.preferenceoftheday = datastore.dailypreferences? (the thing above)
    }
    
    //not showing up
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Exit" style:UIBarButtonItemStyleDone target:nil action:nil];
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver:self selector:@selector(refreshLocationCell) name:@"refereshLocationCell" object:nil];
    
    
}

-(void)refreshLocationCell
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:self.criterias[@"Location"], nil] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

-(void)setUpTapRecognizers
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
//    self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                                                  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
//    self.navigationController.navigationBar.translucent = YES;
    self.navigationItem.backBarButtonItem.enabled = YES;
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)updateCriterias:(NSArray*)times
{

    self.criterias = @{@"time":times,
                       @"Duration":@([times count]+2),
                       @"Distance":@([times count]+3),
                       @"Location":@([times count]+4),
                       @"Conversation":@([times count]+5),
                       @"MyMusic":@([times count]+6),
                       @"PartnerMusic":@([times count]+7),
                       @"averageSpeed":@([times count]+8),
                       @"slowestSpeed":@([times count]+9),
                       @"fastestSpeed":@([times count]+10)};
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dismissKeyboard
{
    [self.toDistance resignFirstResponder];
    [self.fromDistance resignFirstResponder];
    [self.searchBar resignFirstResponder];
    [self.radiusToleranceField resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.criterias count]+ [self.times count]+2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.criterias[@"Location"] integerValue])
    {
        return 150;
    }
    else if (indexPath.row == 2)
    {
        return 50;
    }
    else if (indexPath.row >= [self.criterias[@"averageSpeed"] integerValue] && indexPath.row <= [self.criterias[@"fastestSpeed"] integerValue] )
    {
        return 200;
    }
    else
    {
        return 100;
    }

}

-(void)addTimeCell
{
    self.count +=1;
    [self.times addObject:[NSString stringWithFormat:@"time %ld", (long)self.count]];
//    NSLog(@"time array: \n %@", self.times);
    [self updateCriterias:self.times];
    [self.tableView reloadData];
    
    [self showVC];

}

-(void)showVC
{
    KEMLocationVC* locationVC = [KEMLocationVC new];
    [self presentViewController:locationVC animated:YES completion:^{

    }];
}

-(void)deleteTimeCell:(UIButton*)sender
{
    [self.times removeObjectAtIndex:sender.tag - 1];
//    NSLog(@"at action, tag: %ld", (long)sender.tag);
    [self updateCriterias:self.times];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* stdCell = [UITableViewCell new];
    stdCell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.row == 0)
    {
        return stdCell;
    }
    else if (indexPath.row == 2)
    {
        UITableViewCell* firstCell = [UITableViewCell new];
        UIButton* addTime = [[UIButton alloc]initWithFrame:CGRectMake(35, 15, 250, 20)];

        [addTime setTitle:@"Add another Time Range!" forState:UIControlStateNormal];
        [addTime setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        addTime.backgroundColor = [UIColor orangeColor];
        [addTime addTarget:self action:@selector(addTimeCell) forControlEvents:UIControlEventTouchUpInside];
        [firstCell addSubview:addTime];
        firstCell.backgroundColor = [UIColor clearColor];
        return firstCell;
    }
    else if (indexPath.row <= [self.times count]+1)
    {
        KEMTimeRangeCell* cell = (KEMTimeRangeCell*)[tableView dequeueReusableCellWithIdentifier:@"timeRangeCell"];
        if (cell == nil)
        {
            cell = [[KEMTimeRangeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"timeRangeCell"];
        }
        
        if (self.preferenceOfTheDay.startTime && self.preferenceOfTheDay.endTime ) // this might be wrong because the object could exist but the start and end time properties would be nil
        {
//            cell.recordedLowerValue = self.preferenceOfTheDay.startTime;
            cell.timeRange.lowerValue = [self.preferenceOfTheDay.startTime floatValue];
//            cell.recordedUpperValue = self.preferenceOfTheDay.endTime;
            cell.timeRange.upperValue = [self.preferenceOfTheDay.endTime floatValue];
            [cell updateSliderLabels];
        }
        cell.deleteCell.tag = indexPath.row;
        NSLog(@"at creation, tag: %ld", (long)cell.deleteCell.tag);
        [cell.deleteCell addTarget:self action:@selector(deleteTimeCell:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    else if (indexPath.row == [self.criterias[@"Duration"] integerValue])
    {
        KEMDurationRangeCell* cell = (KEMDurationRangeCell*)[tableView dequeueReusableCellWithIdentifier:@"durationRangeCell"];
        if (cell == nil)
        {
            cell = [[KEMDurationRangeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"durationRangeCell"];
        }
        if (self.preferenceOfTheDay.durationMax && self.preferenceOfTheDay.durationMin )         {
            cell.durationRange.lowerValue = [self.preferenceOfTheDay.durationMin floatValue];
            cell.durationRange.upperValue = [self.preferenceOfTheDay.durationMax floatValue];
            [cell updateSliderLabels];
        }
        return cell;
    }
    else if (indexPath.row == [self.criterias[@"Distance"] integerValue])
    {
        KEMDistanceRangeCell* cell = (KEMDistanceRangeCell*)[tableView dequeueReusableCellWithIdentifier:@"distanceRangeCell"];
        if (cell == nil)
        {
            cell = [[KEMDistanceRangeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"distanceRangeCell"];
        }
        if (self.preferenceOfTheDay.distanceMax && self.preferenceOfTheDay.distanceMin )
        {
            cell.fromDistance.text = [NSString stringWithFormat:@"%@", self.preferenceOfTheDay.distanceMin];
            cell.toDistance.text = [NSString stringWithFormat:@"%@", self.preferenceOfTheDay.distanceMax];
        }
        self.toDistance = cell.toDistance;
        self.fromDistance = cell.fromDistance;
        return cell;
    }
    else if (indexPath.row == [self.criterias[@"Location"] integerValue])
    {
        KEMLocationPreferenceCell* cell = (KEMLocationPreferenceCell*)[tableView dequeueReusableCellWithIdentifier:@"locationPreferenceCell"];
        if (cell == nil)
        {
            cell = [[KEMLocationPreferenceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"locationPreferenceCell"];
        }
        if (self.preferenceOfTheDay.chosenLongitude)
        {
            [cell.mapView removeAnnotations:[cell.mapView annotations]];
            [cell.mapView removeOverlays:[cell.mapView overlays]];
            cell.mapKitView.pointOnMapTapped = YES;
            cell.pointAnnotation = [[MKPointAnnotation alloc]init];
            double savedLatitude = [self.preferenceOfTheDay.chosenLatitude doubleValue];
            double savedLongitude = [self.preferenceOfTheDay.chosenLongitude doubleValue];
            cell.pointAnnotation.coordinate = CLLocationCoordinate2DMake(savedLatitude, savedLongitude);
            cell.chosenCoords = cell.pointAnnotation.coordinate;
            CLGeocoder* geocoder = [CLGeocoder new];
            CLLocation* chosenLocation = [[CLLocation alloc]initWithLatitude:savedLatitude longitude:savedLongitude];
            [geocoder reverseGeocodeLocation:chosenLocation completionHandler:^(NSArray *placemarks, NSError *error)
             {
                 cell.pointAnnotation.title = @"Chosen Location";
                 cell.pointAnnotation.subtitle = [NSString stringWithFormat:@"%@",[[placemarks[0] addressDictionary] objectForKey:@"FormattedAddressLines"]];
             }];
            MKCoordinateRegion chosenRegion = MKCoordinateRegionMake(cell.pointAnnotation.coordinate, MKCoordinateSpanMake(0, 0));
            [cell.showCurrentLocation addTarget:self action:@selector(showVC) forControlEvents:UIControlEventTouchUpInside];
            [cell.mapView setRegion:chosenRegion];
            [cell.mapView addAnnotation:cell.pointAnnotation];
//            cell.delegate = self;
        }
        if (self.preferenceOfTheDay.radiusTolerance)
        {
            cell.radiusTolerance = [self.preferenceOfTheDay.radiusTolerance integerValue];
            cell.radiusToleranceField.text = [NSString stringWithFormat:@"%@", self.preferenceOfTheDay.radiusTolerance];
            [cell checkForChangeInRadius];
        }
        
        return cell;
    }
    else if (indexPath.row == [self.criterias[@"Conversation"] integerValue])
    {
        KEMConversationPreferenceCell* cell = (KEMConversationPreferenceCell*)[tableView dequeueReusableCellWithIdentifier:@"conversationPreferenceCell"];
        if (cell == nil)
        {
            cell = [[KEMConversationPreferenceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"conversationPreferenceCell"];
        }
        if ([self.preferenceOfTheDay.conversationPreference isEqualToNumber:@0])
        {
            cell.preferencePick.selectedSegmentIndex = 2;
        }
        else if ([self.preferenceOfTheDay.conversationPreference isEqualToNumber:@1])
        {
            cell.preferencePick.selectedSegmentIndex = 0;
        }
        else if ([self.preferenceOfTheDay.conversationPreference isEqualToNumber:@-1])
        {
            cell.preferencePick.selectedSegmentIndex = 1;
        }
        return cell;
    }
    else if (indexPath.row == [self.criterias[@"MyMusic"] integerValue])
    {
        KEMMyMusicPreferenceCell* cell = (KEMMyMusicPreferenceCell*)[tableView dequeueReusableCellWithIdentifier:@"myMusicPreferenceCell"];
        if (cell == nil)
        {
            cell = [[KEMMyMusicPreferenceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myMusicPreferenceCell"];
        }
        if ([self.preferenceOfTheDay.personalMusicPreference isEqualToNumber:@0])
        {
            cell.preferencePick.selectedSegmentIndex = 1;
        }
        else if ([self.preferenceOfTheDay.personalMusicPreference isEqualToNumber:@1])
        {
            cell.preferencePick.selectedSegmentIndex = 0;
        }
        return cell;
    }
    else if (indexPath.row == [self.criterias[@"PartnerMusic"] integerValue])
    {
        KEMPartnerMusicPreferenceCell* cell = (KEMPartnerMusicPreferenceCell*)[tableView dequeueReusableCellWithIdentifier:@"partnerMusicPreferenceCell"];
        if (cell == nil)
        {
            cell = [[KEMPartnerMusicPreferenceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"partnerMusicPreferenceCell"];
        }
        if ([self.preferenceOfTheDay.partnerMusicPreference isEqualToNumber:@0])
        {
            cell.preferencePick.selectedSegmentIndex = 1;
        }
        else if ([self.preferenceOfTheDay.partnerMusicPreference isEqualToNumber:@1])
        {
            cell.preferencePick.selectedSegmentIndex = 0;
        }
        return cell;
    }
    else if (indexPath.row == [self.criterias[@"averageSpeed"] integerValue])
    {
        KEMSpeedTolerance* cell = (KEMSpeedTolerance*)[tableView dequeueReusableCellWithIdentifier:@"speedToleranceCell"];
        if (cell == nil)
        {
            cell = [[KEMSpeedTolerance alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"speedToleranceCell"];
        }
        
        if (self.preferenceOfTheDay.averageSpeedKmH)
        {
            CGFloat speedFloat = [self.preferenceOfTheDay.averageSpeedKmH floatValue];
            NSInteger speedUnit = trunc(speedFloat);
            NSInteger speedDecimal = roundf((speedFloat - speedUnit)*10);
            
            cell.speedUnit = [NSString stringWithFormat:@"%ld", (long)speedUnit];
            cell.speedDecimal = [NSString stringWithFormat:@"%ld", speedDecimal*10];
            
            [cell.speedPicker selectRow:speedUnit inComponent:0 animated:NO];
            [cell.speedPicker selectRow:speedDecimal inComponent:2 animated:NO];
        }
        else
        {
            cell.speedUnit = @"0";
            cell.speedDecimal = @"0";
        }
        return cell;
    }
    else if (indexPath.row == [self.criterias[@"slowestSpeed"] integerValue])
    {
        KEMSpeedSlowest* cell = (KEMSpeedSlowest*)[tableView dequeueReusableCellWithIdentifier:@"speedSlowestCell"];
        if (cell == nil)
        {
            cell = [[KEMSpeedSlowest alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"speedSlowestCell"];
        }
        
        if (self.preferenceOfTheDay.slowestSpeedKmH)
        {
            CGFloat speedFloat = [self.preferenceOfTheDay.slowestSpeedKmH floatValue];
            NSInteger speedUnit = trunc(speedFloat);
            NSInteger speedDecimal = roundf((speedFloat - speedUnit)*10);
            
            cell.speedUnit = [NSString stringWithFormat:@"%ld", (long)speedUnit];
            cell.speedDecimal = [NSString stringWithFormat:@"%ld", speedDecimal*10];
            
            [cell.speedPicker selectRow:speedUnit inComponent:0 animated:NO];
            [cell.speedPicker selectRow:speedDecimal inComponent:2 animated:NO];
        }
        else
        {
            cell.speedUnit = @"0";
            cell.speedDecimal = @"0";
        }
        return cell;
    }
    else if (indexPath.row == [self.criterias[@"fastestSpeed"] integerValue])
    {
        KEMSpeedFastest* cell = (KEMSpeedFastest*)[tableView dequeueReusableCellWithIdentifier:@"speedFastestCell"];
        if (cell == nil)
        {
            cell = [[KEMSpeedFastest alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"speedFastestCell"];
        }
        
        if (self.preferenceOfTheDay.fastestSpeedKmH)
        {
            CGFloat speedFloat = [self.preferenceOfTheDay.fastestSpeedKmH floatValue];
            NSInteger speedUnit = trunc(speedFloat);
            NSInteger speedDecimal = roundf((speedFloat - speedUnit)*10);
            
            cell.speedUnit = [NSString stringWithFormat:@"%ld", (long)speedUnit];
            cell.speedDecimal = [NSString stringWithFormat:@"%ld", speedDecimal*10];
            
            [cell.speedPicker selectRow:speedUnit inComponent:0 animated:NO];
            [cell.speedPicker selectRow:speedDecimal inComponent:2 animated:NO];
        }
        else
        {
            cell.speedUnit = @"0";
            cell.speedDecimal = @"0";
        }
        return cell;
    }
    
    return stdCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
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
