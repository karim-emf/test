//
//  KEMLocationPreferenceCell.h
//  RunningMate
//
//  Created by Karim Mourra on 1/31/15.
//  Copyright (c) 2015 Karim Mourra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "KJDMapKitViewController.h"

//@protocol changePictureProtocol <NSObject>
//-(void)showVC;
//@end

@interface KEMLocationPreferenceCell : UITableViewCell</*UITableViewDelegate, UITableViewDataSource, */UITextFieldDelegate>



@property(strong, nonatomic) MKMapView* mapView;
@property(strong, nonatomic) KJDMapKitViewController* mapKitView;
@property(strong, nonatomic) UITextField* searchBar;
@property(strong, nonatomic) UITextField* radiusToleranceField;
@property(strong, nonatomic) UILabel* radiusToleranceLabel;
@property(strong, nonatomic) UILabel* locationLabel;
//@property (nonatomic) id<changePictureProtocol> delegate;

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

-(void)checkForChangeInRadius;

-(void)updateCell;


@end
