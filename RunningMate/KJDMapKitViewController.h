//
//  KJDMapKitViewController.h
//  ChatCode
//
//  Created by Karim Mourra on 11/26/14.
//  Copyright (c) 2014 Karim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface KJDMapKitViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) MKMapView* mapView;
@property(strong,nonatomic) CLLocationManager* locationManager;
@property (strong,nonatomic) CLLocation *currentCoordinates;

@property(strong, nonatomic) NSMutableArray* placemarks;
@property(nonatomic)NSUInteger selectedPinIndex;

@property(strong,nonatomic) NSNotificationCenter* notificationCenter;
@property(nonatomic) BOOL placemarkSelectedFromLocationCellSearchTable;
@property(strong,nonatomic) UIImage* originalPinImage;
@property(strong, nonatomic) MKAnnotationView* prevAnnView;

@property (nonatomic) BOOL currentLocationShown;
@property (nonatomic) BOOL pointOnMapTapped;
@end