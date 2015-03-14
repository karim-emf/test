//
//  KJDMapKitViewController.m
//  ChatCode
//
//  Created by Karim Mourra on 11/26/14.
//  Copyright (c) 2014 Karim. All rights reserved.
//

#import "KJDMapKitViewController.h"
#import "AppDelegate.h"

@interface KJDMapKitViewController ()


@property (strong, nonatomic) UIButton *yesButton;
@property (strong, nonatomic) UIButton *noButton;
@property (strong, nonatomic) UILabel *pageTitle;

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@end

@implementation KJDMapKitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDesiredAccuracy:kCLDistanceFilterNone];

    
    #ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER)
//    if ([CLLocationManager instancesRespondToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager  requestWhenInUseAuthorization];
//        [self.locationManager requestAlwaysAuthorization];
        //didnt work bc needed the requestAlwaysAuth in the plist since it had been requested at first with this.
        [self.locationManager startUpdatingLocation];
    }
    #endif
    
    [self setUpMapView];
    
    if ([self allowedToCheckUserLocation])
    {
//        [self.locationManager startUpdatingLocation];
        [self.mapView setShowsUserLocation:YES];
        self.mapView.showsUserLocation = YES;
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        
        if (self.locationManager.location)
        {
            [self locationManager:self.locationManager didUpdateLocations:@[self.locationManager.location]];
        }
        else
        {
            [self.locationManager startUpdatingLocation];
        }
        
    }
    


    MKCoordinateRegion regionToDisplay = MKCoordinateRegionMakeWithDistance(self.currentCoordinates.coordinate, 10, 10);
    
    [self.mapView setRegion:regionToDisplay animated:YES];
    
    self.notificationCenter = [NSNotificationCenter defaultCenter];
}

-(BOOL) allowedToCheckUserLocation
{
    CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
    
    if (authorizationStatus == kCLAuthorizationStatusAuthorized ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        return YES;
    }
    else if(IS_OS_8_OR_LATER)
        //    if ([CLLocationManager instancesRespondToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager  requestWhenInUseAuthorization];
        return NO;
    }
    else
    {
        return NO;
    }
}

//-(void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:YES];
//    
//    self.locationManager.distanceFilter = kCLDistanceFilterNone;
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    [self.locationManager startUpdatingLocation];
//    
//    //View Area
//    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
//    region.center.latitude = self.locationManager.location.coordinate.latitude;
//    region.center.longitude = self.locationManager.location.coordinate.longitude;
//    region.span.longitudeDelta = 0.005f;
//    region.span.longitudeDelta = 0.005f;
//    [self.mapView setRegion:region animated:YES];
//    
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentCoordinates = [locations lastObject];
      [self.locationManager stopUpdatingLocation];
}
//
//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
//{
//    self.currentCoordinates = userLocation.location;
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 10, 10);
//    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
//}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Hey! There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
    NSLog(@"Error: %@",error.description);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.currentCoordinates = [[CLLocation alloc]initWithLatitude:38.8833 longitude:-77.0167];
    
    if ([self allowedToCheckUserLocation])
    {
        [self.locationManager startUpdatingLocation];
    }
}
//-(void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
//{
//    
//}

//-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
//{
//    for (MKAnnotationView *annView in views)
//    {
//        CGRect endFrame = annView.frame;
//        annView.frame = CGRectOffset(endFrame, 0, -500);
//        [UIView animateWithDuration:0.5
//                         animations:^{ annView.frame = endFrame; }];
//    }
//}
-(void) setUpMapView
{
    self.mapView = [[MKMapView alloc] init];
    [self.view addSubview:self.mapView];
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *mapViewTop = [NSLayoutConstraint constraintWithItem:self.mapView
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.view
                                                                    attribute:NSLayoutAttributeTop
                                                                   multiplier:1.0
                                                                     constant:0.0];
    
    NSLayoutConstraint *mapViewBottom = [NSLayoutConstraint constraintWithItem:self.mapView
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0
                                                                        constant:0.0];
    
    NSLayoutConstraint *mapViewWidth = [NSLayoutConstraint constraintWithItem:self.mapView
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:1.0
                                                                       constant:0.0];
    
    NSLayoutConstraint *mapViewLeft = [NSLayoutConstraint constraintWithItem:self.mapView
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:0.0];
    
    [self.view addConstraints:@[mapViewTop, mapViewBottom, mapViewWidth, mapViewLeft]];
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:(MKCircle *)overlay];
    circleView.fillColor = [UIColor colorWithRed:.65 green:.78 blue:.09 alpha:0.5];
    return circleView;
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    view.image = self.originalPinImage;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    UIApplication* app = [UIApplication sharedApplication];
    AppDelegate* myAppDelegate = (AppDelegate*)app.delegate;
    
    if (myAppDelegate.firstLoad == YES)
    {
        self.originalPinImage = view.image;
        myAppDelegate.firstLoad = NO;
    }
    
    if (self.prevAnnView)
    {
        [self mapView:self.mapView didDeselectAnnotationView:self.prevAnnView];
        self.prevAnnView = nil;
    }
//    [self.mapView deselectAnnotation:self.mapView.selectedAnnotations[0] animated:YES];
    
    //center the new custom green pin. i think pin has a property of its center
    //this is where you obtain which pin was selected for dataManager
    view.highlighted = YES;

    view.image = [UIImage imageNamed:@"selectedPin"];
    if ([self.placemarks containsObject:view.annotation])
    {
        self.selectedPinIndex = [self.placemarks indexOfObject:view.annotation];

        if (! self.placemarkSelectedFromLocationCellSearchTable)
        {
            [self.notificationCenter postNotificationName:@"pinSelected" object:nil];
        }
        self.placemarkSelectedFromLocationCellSearchTable = NO;
    }
    self.prevAnnView = view;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *locationAnnotationIdentifier = @"locationAnnotationIdentifier";
    static NSString *plainAnnotationIdentifier = @"plainAnnotationIdentifier";
    static NSString *pointedAnnotationIdentifier = @"pointedAnnotationIdentifier";
    
    if (self.currentLocationShown)
    {
        MKPinAnnotationView *pinView =
        (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:locationAnnotationIdentifier];
        
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:locationAnnotationIdentifier];
            UIImage *flagImage = [UIImage imageNamed:@"selectedPin"];
            // You may need to resize the image here.
            annotationView.image = flagImage;
            annotationView.centerOffset = CGPointMake(0, -1*(annotationView.frame.size.height/2));
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    else if(self.pointOnMapTapped)
    {
        MKPinAnnotationView *pinView =
        (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:pointedAnnotationIdentifier];
        
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:pointedAnnotationIdentifier];
            UIImage *flagImage = [UIImage imageNamed:@"selectedPin"];
                        annotationView.image = flagImage;
            annotationView.centerOffset = CGPointMake(0, -1*(annotationView.frame.size.height/2));
            
            // You may need to resize the image here.
//            annotationView.image = self.originalPinImage;
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
//        
//        pinView.image = self.originalPinImage;
//        return pinView;
    }
    else if (annotation == self.mapView.userLocation)
    {
        return nil;
    }
    else
    {
        MKPinAnnotationView *pinView =
        (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:plainAnnotationIdentifier];
        
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                            reuseIdentifier:plainAnnotationIdentifier];
            UIImage *flagImage = [UIImage imageNamed:@"stdPin"];
            annotationView.image = flagImage;
            annotationView.centerOffset = CGPointMake(0, -1*(annotationView.frame.size.height/2));
            
            // You may need to resize the image here.
            //            annotationView.image = self.originalPinImage;
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    
}


- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if (self.pointOnMapTapped)
    {
        [self.notificationCenter postNotificationName:@"startingToPointOnMap" object:nil];
    }
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.pointOnMapTapped)
    {
        [self.notificationCenter postNotificationName:@"finishedPointingOnMap" object:nil];
    }
}

@end
