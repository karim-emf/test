#import <UIKit/UIKit.h>

@interface UserDetailsViewController : UITableViewController <NSURLConnectionDelegate>

// UITableView header view properties
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UILabel *headerNameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *headerImageView;

// UITableView row data properties
@property (nonatomic, strong) NSArray *rowTitleArray;
@property (nonatomic, strong) NSMutableArray *rowDataArray;

@property (nonatomic, strong) NSString* locationToStore;
@property (nonatomic, strong) NSString* genderToStore;
@property (nonatomic, strong) NSString* bdayToStore;
@property (nonatomic, strong) NSString* relationshipToStore;
@property (nonatomic, strong) NSString* nameToStore;
@property (nonatomic, strong) NSData* pictureToStore;
@property (nonatomic, strong) NSString* pictureToStoreInString;
@property (nonatomic, strong) NSData* imageData;



@end
