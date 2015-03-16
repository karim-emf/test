//
//  KEMLocationPreferenceCell.m
//  RunningMate
//
//  Created by Karim Mourra on 1/31/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import "KEMLocationPreferenceCell.h"
#import "KEMDataStore.h"
#import "KEMLocationVC.h"

@interface KEMLocationPreferenceCell ()

@property (strong, nonatomic) KEMDataStore* dataStore;
@property (strong, nonatomic) KEMDailyPreference* preferenceOfTheDay;

@end

@implementation KEMLocationPreferenceCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 50, 20)];
        self.locationLabel.text = @"Location:";
        [self.locationLabel sizeToFit];
        [self.contentView addSubview:self.locationLabel];
        [self positionFirstLabel:self.locationLabel];
        
//        [self setUpSearchBar];
//        [self setUpSearchButton];
        [self setUpMapKitView];
//        [self setUpUseCurrentLocation];
        [self setUpShowCurrentLocationButton];
//        [self setUpPointALocationButton];
//        [self setUpUsePointButton];
//        [self setUpShowCurrentLocationButton];
//        [self setUpRadiusTolerance];
//        [self setUpSearchResultsTable];
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                              action:@selector(showVC)];
//        tap.cancelsTouchesInView = NO;
//        [self.contentView addGestureRecognizer:tap];
        
        NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
//        [notificationCenter addObserver:self selector:@selector(selectCellForIndex) name:@"pinSelected" object:nil];
        [notificationCenter addObserver:self selector:@selector(updateCell) name:@"refereshLocationCell" object:nil];
        
        self.dataStore =[KEMDataStore sharedDataManager];
        self.radiusToleranceField = [[UITextField alloc]init];
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
    
    NSLayoutConstraint *labeltHeight = [NSLayoutConstraint constraintWithItem:label
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.contentView
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:0
                                                                     constant:20.0];
    
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
    
    [self.contentView addConstraints:@[labelLeft,labeltHeight, labelTop, labelWidth]];
}

-(void)updateCell
{
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
    
    if (self.preferenceOfTheDay.chosenLongitude)
    {
        [self.mapView removeAnnotations:[self.mapView annotations]];
        [self.mapView removeOverlays:[self.mapView overlays]];
        self.pointAnnotation = [[MKPointAnnotation alloc]init];
        double savedLatitude = [self.preferenceOfTheDay.chosenLatitude doubleValue];
        double savedLongitude = [self.preferenceOfTheDay.chosenLongitude doubleValue];
        self.pointAnnotation.coordinate = CLLocationCoordinate2DMake(savedLatitude, savedLongitude);
        self.chosenCoords = self.pointAnnotation.coordinate;
        CLGeocoder* geocoder = [CLGeocoder new];
        CLLocation* chosenLocation = [[CLLocation alloc]initWithLatitude:savedLatitude longitude:savedLongitude];
        [geocoder reverseGeocodeLocation:chosenLocation completionHandler:^(NSArray *placemarks, NSError *error)
         {
             self.pointAnnotation.title = @"Chosen Location";
             self.pointAnnotation.subtitle = [NSString stringWithFormat:@"%@",[[placemarks[0] addressDictionary] objectForKey:@"FormattedAddressLines"]];
         }];
        MKCoordinateRegion chosenRegion = MKCoordinateRegionMake(self.pointAnnotation.coordinate, MKCoordinateSpanMake(0, 0));
//        [self.showCurrentLocation addTarget:self action:@selector(showVC) forControlEvents:UIControlEventTouchUpInside];
        [self.mapView setRegion:chosenRegion];
        [self.mapView addAnnotation:self.pointAnnotation];
        //            self.locationCell.delegate = self;
    }
    if (self.preferenceOfTheDay.radiusTolerance)
    {
        self.radiusTolerance = [self.preferenceOfTheDay.radiusTolerance integerValue];
        self.radiusToleranceField.text = [NSString stringWithFormat:@"%@", self.preferenceOfTheDay.radiusTolerance];
        [self checkForChangeInRadius];
    }
}


/*
-(void)setUpSearchBar
{
    self.searchBar = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width * 0.7f, 30)];
    self.searchBar.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:self.searchBar];
    self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchBar.layer.cornerRadius=10.0f;
    
    self.searchBar.layer.masksToBounds=YES;
    UIColor *borderColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
//    self.searchBar.rightViewMode=UITextFieldViewModeAlways;
//    self.chatCodeField.rightView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"magnifyingglass"]];
    self.searchBar.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"Type a location and hit search"
                                    attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}
     ];
    self.searchBar.layer.borderColor=[borderColor CGColor];
    self.searchBar.layer.borderWidth=1.0f;
    self.searchBar.textAlignment=NSTextAlignmentLeft;
    self.searchBar.autocapitalizationType=UITextAutocapitalizationTypeNone;
    
    NSLayoutConstraint *searchBarTop = [NSLayoutConstraint constraintWithItem:self.searchBar
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.contentView
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0
                                                                     constant:0.0];
    
    NSLayoutConstraint *searchBarHeight = [NSLayoutConstraint constraintWithItem:self.searchBar
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.contentView
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:0.0
                                                                        constant:30.0];
    
    NSLayoutConstraint *searchBarWidth = [NSLayoutConstraint constraintWithItem:self.searchBar
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.contentView
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:0.7
                                                                       constant:0.0];
    
    NSLayoutConstraint *searchBarCenterX = [NSLayoutConstraint constraintWithItem:self.searchBar
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.contentView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0
                                                                         constant:0.0];
    
    [self.contentView addConstraints:@[searchBarTop, searchBarHeight, searchBarWidth, searchBarCenterX]];
}

-(void)setUpSearchButton
{
    self.searchButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.searchButton.backgroundColor = [UIColor clearColor];
    [self.searchButton setImage:[UIImage imageNamed:@"search-7"] forState:UIControlStateNormal];
//    self.searchButton.imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"search-7"]];
    [self.searchButton addTarget:self action:@selector(searchButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.searchButton];
    self.searchButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *searchButtonTop = [NSLayoutConstraint constraintWithItem:self.searchButton
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.searchBar
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0
                                                                     constant:0.0];
    
    NSLayoutConstraint *searchButtonHeight = [NSLayoutConstraint constraintWithItem:self.searchButton
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.searchBar
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0
                                                                        constant:0.0];
    
    NSLayoutConstraint *searchButtonRight = [NSLayoutConstraint constraintWithItem:self.searchButton
                                                                      attribute:NSLayoutAttributeRight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.contentView
                                                                      attribute:NSLayoutAttributeRight
                                                                     multiplier:1.0
                                                                       constant:0.0];
    
    NSLayoutConstraint *searchButtonLeft = [NSLayoutConstraint constraintWithItem:self.searchButton
                                                                        attribute:NSLayoutAttributeLeft
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.searchBar
                                                                        attribute:NSLayoutAttributeRight
                                                                       multiplier:1.0
                                                                         constant:0.0];
    
    [self.contentView addConstraints:@[searchButtonTop,searchButtonHeight,searchButtonRight,searchButtonLeft]];
}

-(void)searchButtonTapped
{
    [self.mapView removeOverlays:[self.mapView overlays]];
    if (! [self.searchBar.text isEqualToString:@""] )
    {
        NSLog(@"coords 1: %@", self.mapKitView.locationManager.location);
        MKLocalSearchRequest* request = [[MKLocalSearchRequest alloc]init];
        request.naturalLanguageQuery = self.searchBar.text;
        request.region = self.mapView.region;
        MKLocalSearch* search = [[MKLocalSearch alloc]initWithRequest:request];
        
        [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
        {
            NSMutableArray* placemarks = [NSMutableArray array];
            for (MKMapItem* item in response.mapItems)
            {
//                NSLog(@"item: %@", item);
//                NSLog(@"placemark: %@", item.placemark);
                NSLog(@"^^^^^^^ %@", item.placemark.title);
                [placemarks addObject:item.placemark];
                
                //-------------------
                //placemarks have coordinate property, and placemarks are stored in order in self.placemarks, so they can be accessed by clicking the right table cell.
                //-find out how to select a placemark by selecting its pin on the map; make it touchable and highlightable, and that by touching it, appropriate cell gets touched too and vice versa.
                //-------------------
            }
            [self.mapView removeAnnotations:[self.mapView annotations]];
            [self.mapView showAnnotations:placemarks animated:YES];
            
            if (placemarks)
            {
                self.placemarks = placemarks;
                //                MKPlacemark* firstHit=  placemarks[0];
                //                        NSLog(@"coords 2: %@", self.mapKitView.currentCoordinates.coordinate.latitude);
                //                self.mapKitView.currentCoordinates= firstHit.location;
                //                [self.mapKitView.locationManager startUpdatingLocation];
                
            }
            else
            {
                self.placemarks = nil;
            }
            self.mapKitView.placemarks = self.placemarks;
            [self.searchResultsTable reloadData];
        }];
    }
}
*/
-(void)setUpMapKitView
{
    self.mapKitView = [[KJDMapKitViewController alloc] init];
    [self.mapKitView viewWillAppear:NO];
    [self.mapKitView viewDidLoad];
    
    self.mapView = self.mapKitView.mapView;
    self.mapView.delegate = self.mapKitView;
    
    
    [self.mapView setFrame:CGRectMake(0, 30, self.frame.size.width, 10)];
    [self.contentView addSubview:self.mapView];
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *mapKitTop = [NSLayoutConstraint constraintWithItem:self.mapView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.locationLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:5.0];
    
    NSLayoutConstraint *mapKitBottom = [NSLayoutConstraint constraintWithItem:self.mapView
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.contentView
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0
                                                                     constant:-5.0];
    
    NSLayoutConstraint *mapKitWidth = [NSLayoutConstraint constraintWithItem:self.mapView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0
                                                                    constant:-10.0];
    
    NSLayoutConstraint *mapKitLeft = [NSLayoutConstraint constraintWithItem:self.mapView
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0
                                                                   constant:5.0];
    
    [self.contentView addConstraints:@[mapKitTop,mapKitBottom,mapKitWidth,mapKitLeft]];
    
}

//-(void)showVC
//{
//    KEMLocationVC* locationVC = [KEMLocationVC new];
//    [self presentViewController:locationVC animated:YES completion:^{
//        
//    }];
//}

-(void)setUpShowCurrentLocationButton
{
    self.showCurrentLocation = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 20,0, 40, 40)];
//    [self.showCurrentLocation setImage:[UIImage imageNamed:@"compass-point-7"] forState:UIControlStateNormal];
    self.showCurrentLocation.backgroundColor = [UIColor orangeColor];
    [self.showCurrentLocation setTitle:@"Edit" forState:UIControlStateNormal];
    [self.showCurrentLocation setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.showCurrentLocation.layer.masksToBounds=YES;
    self.showCurrentLocation.layer.cornerRadius=10.0f;
    UIColor *borderColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    self.showCurrentLocation.layer.borderColor=[borderColor CGColor];
    self.showCurrentLocation.layer.borderWidth=1.0f;
    
    self.showCurrentLocation.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.showCurrentLocation addTarget:self action:@selector(showVC) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:self.showCurrentLocation];
    
    NSLayoutConstraint* buttomBottom = [NSLayoutConstraint constraintWithItem:self.showCurrentLocation
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.mapView
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0
                                                                     constant:-20.0];
    
    NSLayoutConstraint* buttomRight = [NSLayoutConstraint constraintWithItem:self.showCurrentLocation
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.mapView
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1.0
                                                                    constant:-20.0];
    
    NSLayoutConstraint* buttomHeight = [NSLayoutConstraint constraintWithItem:self.showCurrentLocation
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.mapView
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:0.0
                                                                     constant:30.0];
    
    NSLayoutConstraint* buttomWidth = [NSLayoutConstraint constraintWithItem:self.showCurrentLocation
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.showCurrentLocation
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0.0
                                                                    constant:60.0];
    
    [self.mapView addConstraints:@[buttomBottom, buttomRight, buttomHeight, buttomWidth]];
}

/*
-(void)returnToCurrentPosition
{
    MKCoordinateRegion currentRegion = MKCoordinateRegionMake(self.mapKitView.locationManager.location.coordinate, MKCoordinateSpanMake(0, 0));
    [self.mapView setRegion:currentRegion];
}

-(void)setUpUseCurrentLocation
{
    self.useCurrentLocationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 40)];
    self.useCurrentLocationButton.backgroundColor = [UIColor blueColor];
    [self.useCurrentLocationButton setTitle:@"Use Your Current Location" forState:UIControlStateNormal];
//    self.useCurrentLocationButton.titleLabel.text = @"Use Your Current Location";
//    self.useCurrentLocationButton.titleLabel.textColor = [UIColor whiteColor];
//    [self.useCurrentLocationButton.titleLabel sizeToFit];
    [self.useCurrentLocationButton addTarget:self action:@selector(useCurrentLocationTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.useCurrentLocationButton];
    self.useCurrentLocationButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *currentLocationButtonTop = [NSLayoutConstraint constraintWithItem:self.useCurrentLocationButton
                                                                                attribute:NSLayoutAttributeTop
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.mapView
                                                                                attribute:NSLayoutAttributeBottom
                                                                               multiplier:1.0
                                                                                 constant:0.0];
    
    NSLayoutConstraint *currentLocationButtonHeight = [NSLayoutConstraint constraintWithItem:self.useCurrentLocationButton
                                                                                   attribute:NSLayoutAttributeHeight
                                                                                   relatedBy:NSLayoutRelationEqual
                                                                                      toItem:self.contentView
                                                                                   attribute:NSLayoutAttributeHeight
                                                                                  multiplier:0.0
                                                                                    constant:30.0];
    
    NSLayoutConstraint *currentLocationButtonWidth = [NSLayoutConstraint constraintWithItem:self.useCurrentLocationButton
                                                                                  attribute:NSLayoutAttributeWidth
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self.contentView
                                                                                  attribute:NSLayoutAttributeWidth
                                                                                 multiplier:1.0
                                                                                   constant:0.0];
    
    NSLayoutConstraint *currentLocationButtonCenterX = [NSLayoutConstraint constraintWithItem:self.useCurrentLocationButton
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:self.contentView
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                   multiplier:1.0
                                                                                     constant:0.0];
    
    [self.contentView addConstraints:@[currentLocationButtonCenterX, currentLocationButtonHeight, currentLocationButtonTop, currentLocationButtonWidth]];
}
-(void)useCurrentLocationTouched
{
    [self.mapView removeOverlays:[self.mapView overlays]];
    [self returnToCurrentPosition];
    MKPointAnnotation* currentLocationAnnotation = [[MKPointAnnotation alloc]init];
    self.chosenCoords = self.mapView.userLocation.coordinate;
    currentLocationAnnotation.coordinate = self.chosenCoords;
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self.mapView addAnnotation:currentLocationAnnotation];
//    MKAnnotationView* annView = [self.mapView viewForAnnotation:currentLocationAnnotation];
//    [self.mapKitView mapView:self.mapView didSelectAnnotationView:annView];
    [self checkForChangeInRadius];
}

-(void)setUpPointALocationButton
{
    self.pointALocationButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 40)];
    self.pointALocationButton.backgroundColor = [UIColor purpleColor];
    [self.pointALocationButton setTitle:@"Point A Location On the Map!" forState:UIControlStateNormal];
//    self.pointALocationButton.titleLabel.text = @"Point A Location On the Map!";
//    self.pointALocationButton.titleLabel.textColor = [UIColor whiteColor];
//    [self.pointALocationButton.titleLabel sizeToFit];
    [self.pointALocationButton addTarget:self action:@selector(pointButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.pointALocationButton];
    self.pointALocationButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *pointButtonTop = [NSLayoutConstraint constraintWithItem:self.pointALocationButton
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.useCurrentLocationButton
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0
                                                                       constant:0.0];
    
    NSLayoutConstraint *pointButtonHeight = [NSLayoutConstraint constraintWithItem:self.pointALocationButton
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.contentView
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:0.0
                                                                          constant:30.0];
    
    NSLayoutConstraint *pointButtonWidth = [NSLayoutConstraint constraintWithItem:self.pointALocationButton
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.contentView
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1.0
                                                                         constant:0.0];
    
    NSLayoutConstraint *pointButtonCenterX = [NSLayoutConstraint constraintWithItem:self.pointALocationButton
                                                                          attribute:NSLayoutAttributeCenterX
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.contentView
                                                                          attribute:NSLayoutAttributeCenterX
                                                                         multiplier:1.0
                                                                           constant:0.0];
    
    [self.contentView addConstraints:@[pointButtonCenterX, pointButtonHeight, pointButtonTop, pointButtonWidth]];
}

-(void)pointButtonTapped
{
    CGFloat xCoordinate = self.mapView.layer.bounds.size.width/2.0f;
    CGFloat yCoordinate = (self.mapView.layer.bounds.size.height * 0.7f)/2.0f;
    self.pointedLocation = [[MKPinAnnotationView alloc]initWithFrame:CGRectMake(xCoordinate, yCoordinate, 20, 20)];
    
    self.pointedLocation.pinColor = MKPinAnnotationColorPurple;
    [self.mapView addSubview:self.pointedLocation];
    self.pointALocationButton.hidden = YES;
    self.useThisPointButton.hidden = NO;
}

-(void)setUpUsePointButton
{
    self.useThisPointButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    self.useThisPointButton.backgroundColor = [UIColor orangeColor];
    [self.useThisPointButton setTitle:@"Use this point!" forState:UIControlStateNormal];
//    self.useThisPointButton.titleLabel.text = @"Use this point!";
//    self.useThisPointButton.titleLabel.textColor = [UIColor whiteColor];
//    [self.useThisPointButton.titleLabel sizeToFit];
    [self.useThisPointButton addTarget:self action:@selector(useThisPointButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.useThisPointButton];
    self.useThisPointButton.hidden = YES;
    self.useThisPointButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *pointButtonTop = [NSLayoutConstraint constraintWithItem:self.useThisPointButton
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.useCurrentLocationButton
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0
                                                                       constant:0.0];
    
    NSLayoutConstraint *pointButtonHeight = [NSLayoutConstraint constraintWithItem:self.useThisPointButton
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.contentView
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:0.0
                                                                          constant:30.0];
    
    NSLayoutConstraint *pointButtonWidth = [NSLayoutConstraint constraintWithItem:self.useThisPointButton
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.contentView
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1.0
                                                                         constant:0.0];
    
    NSLayoutConstraint *pointButtonCenterX = [NSLayoutConstraint constraintWithItem:self.useThisPointButton
                                                                          attribute:NSLayoutAttributeCenterX
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.contentView
                                                                          attribute:NSLayoutAttributeCenterX
                                                                         multiplier:1.0
                                                                           constant:0.0];
    
    [self.contentView addConstraints:@[pointButtonCenterX, pointButtonHeight, pointButtonTop, pointButtonWidth]];
}

-(void)useThisPointButtonTapped
{
    [self.pointedLocation setDragState:MKAnnotationViewDragStateEnding animated:YES];
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self.mapView removeOverlays:[self.mapView overlays]];
    self.pointAnnotation = [[MKPointAnnotation alloc]init];
    CLLocationCoordinate2D centreCoords = [self.mapView centerCoordinate];
    self.pointAnnotation.coordinate = CLLocationCoordinate2DMake(centreCoords.latitude, centreCoords.longitude);
    self.chosenCoords = self.pointAnnotation.coordinate;
    CLGeocoder* geocoder = [CLGeocoder new];
    CLLocation* centreLocation = [[CLLocation alloc]initWithLatitude:centreCoords.latitude longitude:centreCoords.longitude];
    [geocoder reverseGeocodeLocation:centreLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         self.pointAnnotation.title = @"Chosen Location";
         self.pointAnnotation.subtitle = [NSString stringWithFormat:@"%@",[[placemarks[0] addressDictionary] objectForKey:@"FormattedAddressLines"]];
     }];
    
    [self.mapView addAnnotation:self.pointAnnotation];
    
    self.useThisPointButton.hidden = YES;
    self.pointALocationButton.hidden = NO;
    [self checkForChangeInRadius];
    
    //comments: when selected, does not show title.
}

-(void)setUpSearchResultsTable
{
    self.searchResultsTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 50) style:UITableViewStylePlain];
    self.searchResultsTable.delegate = self;
    self.searchResultsTable.dataSource = self;
    [self.contentView addSubview:self.searchResultsTable];
    self.searchResultsTable.translatesAutoresizingMaskIntoConstraints =NO;
    
    NSLayoutConstraint *searchResultsTop = [NSLayoutConstraint constraintWithItem:self.searchResultsTable
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.pointALocationButton
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:0.0];
    
    NSLayoutConstraint *searchResultsBot = [NSLayoutConstraint constraintWithItem:self.searchResultsTable
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.radiusToleranceLabel
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.0
                                                                         constant:0.0];
    
    NSLayoutConstraint *searchResultsWidth = [NSLayoutConstraint constraintWithItem:self.searchResultsTable
                                                                          attribute:NSLayoutAttributeWidth
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.contentView
                                                                          attribute:NSLayoutAttributeWidth
                                                                         multiplier:0.90
                                                                           constant:0.0];
    
    NSLayoutConstraint *searchResultsCenterX = [NSLayoutConstraint constraintWithItem:self.searchResultsTable
                                                                            attribute:NSLayoutAttributeCenterX
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.contentView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                           multiplier:1.0
                                                                             constant:0.0];
    
    [self.contentView addConstraints:@[searchResultsTop, searchResultsWidth, searchResultsCenterX, searchResultsBot]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.placemarks)
    {
        return [self.placemarks count];
    }
    else
    {
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    if ([cell.contentView.subviews count] >0)
    {
        for (NSInteger i=0; i< [cell.contentView.subviews count]; i++)
        {
            [cell.contentView.subviews[i] removeFromSuperview];
        }
    }
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
//    UILabel *subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, cell.frame.size.height/2.0f, cell.frame.size.width, cell.frame.size.height/2.0f)];
    if (self.placemarks)
    {
        MKPlacemark* placemark = self.placemarks[indexPath.row];
        titleLabel.text =placemark.name;
//        subTitleLabel.text = placemark.title;
    }
    else
    {
        titleLabel.text = @"No results to display";
    }
    
    [titleLabel sizeToFit];
//    [subTitleLabel sizeToFit];
    [cell.contentView addSubview:titleLabel];
//    [cell.contentView addSubview:subTitleLabel];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.prevAnnView)
    {
        [self.mapKitView mapView:self.mapView didDeselectAnnotationView:self.prevAnnView];
        self.prevAnnView = nil;
    }
    else if (self.mapKitView.prevAnnView)
    {
        [self.mapKitView mapView:self.mapView didDeselectAnnotationView:self.mapKitView.prevAnnView];
        self.mapKitView.prevAnnView = nil;
    }
    MKPointAnnotation* selectedPointAnnotation = self.placemarks[indexPath.row];
    MKAnnotationView* annView = [self.mapView viewForAnnotation:selectedPointAnnotation];
    self.mapKitView.placemarkSelectedFromLocationCellSearchTable = YES;
    [self.mapKitView mapView:self.mapView didSelectAnnotationView:annView];
    self.prevAnnView = annView;
    self.mapKitView.prevAnnView = self.prevAnnView;
    self.chosenCoords = selectedPointAnnotation.coordinate;
    [self checkForChangeInRadius];
}
*/

/*
-(void)setUpRadiusTolerance
{
    [self setUpRadiusLabel];
    [self setUpRadiusField];
}

-(void)setUpRadiusLabel
{
    self.radiusToleranceLabel = [[UILabel alloc]init];
    self.radiusToleranceLabel.text = @"Radius tolerance:";
    self.radiusToleranceLabel.backgroundColor = [UIColor clearColor];
    [self.radiusToleranceLabel sizeToFit];
    [self.contentView addSubview:self.radiusToleranceLabel];
    self.radiusToleranceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    //    NSLayoutConstraint *radiusToleranceLabelTop = [NSLayoutConstraint constraintWithItem:self.radiusToleranceLabel
    //                                                                                attribute:NSLayoutAttributeTop
    //                                                                                relatedBy:NSLayoutRelationEqual
    //                                                                                   toItem:self.searchResultsTable
    //                                                                                attribute:NSLayoutAttributeBottom
    //                                                                               multiplier:1.0
    //                                                                                 constant:0.0];
    
    NSLayoutConstraint *radiusToleranceLabelHeight = [NSLayoutConstraint constraintWithItem:self.radiusToleranceLabel
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self.contentView
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                 multiplier:0.0
                                                                                   constant:30.0];
    
    NSLayoutConstraint *radiusToleranceLabelBottom = [NSLayoutConstraint constraintWithItem:self.radiusToleranceLabel
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self.contentView
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                 multiplier:1.0
                                                                                   constant:-5.0];
    
    NSLayoutConstraint *radiusToleranceLabelLeft = [NSLayoutConstraint constraintWithItem:self.radiusToleranceLabel
                                                                                attribute:NSLayoutAttributeLeft
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.contentView
                                                                                attribute:NSLayoutAttributeLeft
                                                                               multiplier:1.0
                                                                                 constant:5.0];
    
    [self.contentView addConstraints:@[radiusToleranceLabelBottom, radiusToleranceLabelHeight, radiusToleranceLabelLeft]];
}

-(void)setUpRadiusField
{
    self.radiusToleranceField = [[UITextField alloc]init];
    self.radiusToleranceField.backgroundColor = [UIColor lightTextColor];
    [self.radiusToleranceField addTarget:self action:@selector(checkForChangeInRadius) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:self.radiusToleranceField];
    self.radiusToleranceField.translatesAutoresizingMaskIntoConstraints = NO;
    self.radiusToleranceField.delegate = self;
    self.radiusToleranceField.layer.masksToBounds = YES;
    self.radiusToleranceField.layer.cornerRadius = 10.0f;



    self.radiusToleranceField.keyboardType = UIKeyboardTypeDecimalPad;
    
    self.radiusToleranceField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"0"
                                    attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}
     ];
    UIColor *borderColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    self.radiusToleranceField.layer.borderColor=[borderColor CGColor];
    self.radiusToleranceField.layer.borderWidth = 1.0f;
    self.radiusToleranceField.textAlignment=NSTextAlignmentCenter;
    self.radiusToleranceField.autocapitalizationType=UITextAutocapitalizationTypeNone;
    
    NSLayoutConstraint *radiusToleranceFieldHeight = [NSLayoutConstraint constraintWithItem:self.radiusToleranceField
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self.radiusToleranceLabel
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                 multiplier:1.0
                                                                                   constant:0.0];
    
    NSLayoutConstraint *radiusToleranceFieldBottom = [NSLayoutConstraint constraintWithItem:self.radiusToleranceField
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:self.radiusToleranceLabel
                                                                                  attribute:NSLayoutAttributeBottom
                                                                                 multiplier:1.0
                                                                                   constant:0.0];
    
    NSLayoutConstraint *radiusToleranceLabelFieldLeft = [NSLayoutConstraint constraintWithItem:self.radiusToleranceField
                                                                                     attribute:NSLayoutAttributeLeft
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self.radiusToleranceLabel
                                                                                     attribute:NSLayoutAttributeRight
                                                                                    multiplier:1.0
                                                                                      constant:0.0];
    
    NSLayoutConstraint *radiusToleranceLabelFieldRight = [NSLayoutConstraint constraintWithItem:self.radiusToleranceField
                                                                                      attribute:NSLayoutAttributeRight
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:self.contentView
                                                                                      attribute:NSLayoutAttributeRight
                                                                                     multiplier:1.0
                                                                                       constant:0.0];
    
    [self.contentView addConstraints:@[radiusToleranceFieldBottom, radiusToleranceFieldHeight, radiusToleranceLabelFieldLeft, radiusToleranceLabelFieldRight]];
    self.radiusToleranceField.enabled = NO;
}

*/
-(void)checkForChangeInRadius
{
    [self.mapView removeOverlays:[self.mapView overlays]];
    NSNumber* radiusFieldNumber = [self createNSNumberFromNSString:self.radiusToleranceField.text];
    
    if (![self.radiusToleranceField.text isEqual:@""])
    {
        self.radiusTolerance = [radiusFieldNumber integerValue];
        
        MKCircle* locationTolerance = [MKCircle circleWithCenterCoordinate:self.chosenCoords radius:self.radiusTolerance];
        [self.mapView addOverlay:locationTolerance];
    }
}

-(NSNumber*) createNSNumberFromNSString:(NSString*)text
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *number = [f numberFromString:text];
    return number;
}

/*
-(void)selectCellForIndex
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:self.mapKitView.selectedPinIndex inSection:0];
    [self.searchResultsTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    
    MKPointAnnotation* selectedPointAnnotation = self.placemarks[self.mapKitView.selectedPinIndex];//[self.mapView annotations][self.mapKitView.selectedPinIndex];
    self.chosenCoords = selectedPointAnnotation.coordinate;
    [self checkForChangeInRadius];
}

-(void)locationHasBeenChosen
{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *year = [formatter stringFromDate:now];
    [formatter setDateFormat:@"MM"];
    NSString *month = [formatter stringFromDate:now];
    [formatter setDateFormat:@"dd"];
    NSString *day = [formatter stringFromDate:now];
    NSString *date = [day stringByAppendingFormat:@"-%@-%@", month, year];
    
    NSNumber* chosenLatitude = @(self.chosenCoords.latitude);
    NSNumber* chosenLongitude = @(self.chosenCoords.longitude);
    NSNumber* radiusTolerance = @(self.radiusTolerance);
    
    [self.dataStore addLocationLatitude:chosenLatitude Longitude:chosenLongitude AndRadius:radiusTolerance ToPreferenceFor:date];
}
 */
 

@end
