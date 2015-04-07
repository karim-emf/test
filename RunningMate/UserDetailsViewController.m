#import "UserDetailsViewController.h"

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "KEMFbProfileInfo.h"
#import "KEMDataStore.h"

@interface UserDetailsViewController ()

@property (strong, nonatomic) KEMDataStore* dataStore;
@property (strong, nonatomic) UIButton* fbButton;

@end

@implementation UserDetailsViewController

#pragma mark -
#pragma mark Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Facebook Profile";

        // Create array for table row titles
        _rowTitleArray = @[@"Location", @"Gender", @"Date of Birth", @"Relationship"];

        // Set default values for the table row data
        _rowDataArray = [@[@"N/A", @"N/A", @"N/A", @"N/A"] mutableCopy];
    }
    return self;
}

#pragma mark -
#pragma mark UIViewController

-(NSString*)obtainDateStringDDMMYYYY
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
    return date;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataStore = [KEMDataStore sharedDataManager];
    [self.dataStore fetchPreferencesOf:[self obtainDateStringDDMMYYYY]];

    self.tableView.backgroundColor = [UIColor colorWithWhite:230.0f/255.0f alpha:1.0f];

    // Load table header view from nib
    [[NSBundle mainBundle] loadNibNamed:@"TableHeaderView" owner:self options:nil];
    self.tableView.tableHeaderView = self.headerView;

    // Add logout navigation bar button
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log Out"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(logoutButtonAction:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
    
self.fbButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width*0.15f, self.view.frame.size.height * 0.7f, (self.view.frame.size.width*0.7f), 50)];

    self.fbButton.backgroundColor = [UIColor colorWithRed:(59/255.0) green:(89/255.0) blue:(152/255.0) alpha:1];
    self.fbButton.titleLabel.frame = self.fbButton.frame;
    
    self.fbButton.layer.masksToBounds = YES;
    self.fbButton.layer.cornerRadius = 10.0f;
    UIColor *borderColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    self.fbButton.layer.borderColor =[borderColor CGColor];
    self.fbButton.layer.borderWidth = 1.0f;
    [self.fbButton setTitle:@"Continue!" forState:UIControlStateNormal];
    self.fbButton.titleLabel.textColor = [UIColor whiteColor];
    
    [self.fbButton addTarget:self action:@selector(dismissThisView) forControlEvents:UIControlEventTouchUpInside];
    [self.fbButton addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchDown];

    [self.view addSubview:self.fbButton];

    [self _loadData];
}

-(void)buttonTapped
{
    self.fbButton.backgroundColor=[UIColor colorWithRed:0.016 green:0.341 blue:0.22 alpha:0.5];
}
-(void) dismissThisView
{
    self.fbButton.backgroundColor=[UIColor colorWithRed:(59/255.0) green:(89/255.0) blue:(152/255.0) alpha:1];
    self.fbButton.titleLabel.textColor=[UIColor whiteColor];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        PFInstallation *installation = [PFInstallation currentInstallation];
        installation[@"user"] = [PFUser currentUser];
        [installation saveInBackground];
        
        [self.dataStore addUserName:self.nameToStore UserCity:self.locationToStore UserGender:self.genderToStore UserDOB:self.bdayToStore UserRelationship:self.relationshipToStore AndProfilePicture:self.pictureToStoreInString ForDate:[self obtainDateStringDDMMYYYY]];
        
        if ([PFUser currentUser])
        {
            [self.dataStore pushPreferencesToParse];
        }
    }];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.rowTitleArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
        // Cannot select these cells
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    // Display the data in the table
    cell.textLabel.text = self.rowTitleArray[indexPath.row];
    cell.detailTextLabel.text = self.rowDataArray[indexPath.row];

    return cell;
}

#pragma mark -
#pragma mark Actions

- (void)logoutButtonAction:(id)sender {
    // Logout user, this automatically clears the cache
    [PFUser logOut];

    // Return to login view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Data

- (void)_loadData {
    // If the user is already logged in, display any previously cached values before we get the latest from Facebook.
    if ([PFUser currentUser]) {
        [self _updateProfileData];
    }

    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;

            NSString *facebookID = userData[@"id"];


            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];

            if (facebookID) {
                userProfile[@"facebookId"] = facebookID;
            }

            NSString *name = userData[@"name"];
            if (name) {
                userProfile[@"name"] = name;
            }

            NSString *location = userData[@"location"][@"name"];
            if (location) {
                userProfile[@"location"] = location;
            }

            NSString *gender = userData[@"gender"];
            if (gender) {
                userProfile[@"gender"] = gender;
            }

            NSString *birthday = userData[@"birthday"];
            if (birthday) {
                userProfile[@"birthday"] = birthday;
            }

            NSString *relationshipStatus = userData[@"relationship_status"];
            if (relationshipStatus) {
                userProfile[@"relationship"] = relationshipStatus;
            }

            userProfile[@"pictureURL"] = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];

            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            [[PFUser currentUser] saveInBackground];

            [self _updateProfileData];
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            [self logoutButtonAction:nil];
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
}

// Set received values if they are not nil and reload the table
- (void)_updateProfileData
{
    self.locationToStore = @"N/A";
    self.genderToStore = @"N/A";
    self.bdayToStore = @"N/A";
    self.relationshipToStore = @"N/A";
    self.nameToStore = @"N/A";
    self.pictureToStoreInString = @"N/A";
    self.pictureToStore = [NSData new];

    NSString *location = [PFUser currentUser][@"profile"][@"location"];
    if (location) {
        self.rowDataArray[0] = location;
        self.locationToStore = location;
    }

    NSString *gender = [PFUser currentUser][@"profile"][@"gender"];
    if (gender) {
        self.rowDataArray[1] = gender;
        self.genderToStore = gender;
    }

    NSString *birthday = [PFUser currentUser][@"profile"][@"birthday"];
    if (birthday) {
        self.rowDataArray[2] = birthday;
        self.bdayToStore = birthday;
    }

    NSString *relationshipStatus = [PFUser currentUser][@"profile"][@"relationship"];
    if (relationshipStatus) {
        self.rowDataArray[3] = relationshipStatus;
        self.relationshipToStore = relationshipStatus;
    }

    [self.tableView reloadData];

    // Set the name in the header view label
    NSString *name = [PFUser currentUser][@"profile"][@"name"];
    if (name) {
        self.headerNameLabel.text = name;
        self.nameToStore = name;
    }

    NSString *userProfilePhotoURLString = [PFUser currentUser][@"profile"][@"pictureURL"];
    // Download the user's facebook profile picture
    if (userProfilePhotoURLString) {
        NSURL *pictureURL = [NSURL URLWithString:userProfilePhotoURLString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:pictureURL];

        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

                                   if (connectionError == nil && data != nil)
                                   {
                                       self.dataStore.profilePicInString =[self imageToNSString:[UIImage imageWithData:data]];
                                       self.pictureToStoreInString = self.dataStore.profilePicInString;
                                       
                                       self.headerImageView.image = [UIImage imageWithData:data];
                                       self.imageData = data;

                                       // Add a nice corner radius to the image
                                       self.headerImageView.layer.cornerRadius = 8.0f;
                                       self.headerImageView.layer.masksToBounds = YES;
                                   } else {
                                       NSLog(@"Failed to load profile photo.");
                                   }
                                   
                                   if (self.headerImageView.image)
                                   {
                                       self.pictureToStore = self.imageData;
                                   }
                                   
//                                   [self.dataStore addUserName:self.nameToStore UserCity:self.locationToStore UserGender:self.genderToStore UserDOB:self.bdayToStore UserRelationship:self.relationshipToStore AndProfilePicture:self.pictureToStoreInString ForDate:[self obtainDateStringDDMMYYYY]];
                                   
                               }];
    }
}

-(NSString *)imageToNSString:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
    
    return [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

@end
