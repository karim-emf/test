//
//  KEMLocationVC.h
//  RunningMate
//
//  Created by Karim Mourra on 3/12/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "KJDMapKitViewController.h"

@interface KEMLocationVC : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property(strong, nonatomic) MKMapView* mapView;
@property(strong, nonatomic) KJDMapKitViewController* mapKitView;
@property(strong, nonatomic) UITextField* searchBar;
@property(strong, nonatomic) UITextField* radiusToleranceField;
@property(strong, nonatomic) UILabel* radiusToleranceLabel;
@property(strong, nonatomic) UILabel* measurementLabel;

@property(strong, nonatomic) UIButton* searchButton;
@property(strong, nonatomic) UITableView* searchResultsTable;
@property(strong, nonatomic) MKPlacemark* currentPlacemark;
@property(strong, nonatomic) NSMutableArray* placemarks;
@property(strong, nonatomic) UIButton* showCurrentLocation;
@property(strong, nonatomic) MKPinAnnotationView* pointedLocation;
@property(strong, nonatomic) MKPointAnnotation* pointAnnotation;
@property(strong, nonatomic) UIButton* pointALocationButton;
@property(strong, nonatomic) UIButton* useThisPointButton;
@property(strong, nonatomic) UIButton* useCurrentLocationButton;

@property(strong, nonatomic) MKAnnotationView* prevAnnView;

@property (nonatomic) NSInteger radiusTolerance;
@property (nonatomic) CLLocationCoordinate2D chosenCoords;
//@property(strong, nonatomic) CLGeocoder* geocoder;

@property (strong,nonatomic) UISegmentedControl* locationStylePick;
@property (strong, nonatomic) UIButton* doneButton;

@property (strong, nonatomic) NSLayoutConstraint *mapKitTop;
@property (strong, nonatomic) NSLayoutConstraint *mapKitBottom;

@property (strong, nonatomic) NSLayoutConstraint *searchBarTop;
@property (strong, nonatomic) NSLayoutConstraint *searchBarHeight;
@property (strong, nonatomic) NSLayoutConstraint *searchBarWidth;
@property (strong, nonatomic) NSLayoutConstraint *searchBarCenterX;

@property (strong, nonatomic) NSLayoutConstraint *searchResultsHeight;
@property (strong, nonatomic) NSLayoutConstraint *searchResultsBot;
@property (strong, nonatomic) NSLayoutConstraint *searchResultsWidth;
@property (strong, nonatomic) NSLayoutConstraint *searchResultsCenterX;

@property (strong, nonatomic) UIImageView* floatingPin;

-(void)checkForChangeInRadius;

@end
