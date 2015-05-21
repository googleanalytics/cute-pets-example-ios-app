#import "GAITrackedViewController.h"

// Extend GAITrackedViewController to enable automatic screenview tracking for this view controller.
// Set the view controller's screen name in viewDidLoad.
@interface VoteViewController : GAITrackedViewController

@property(nonatomic, copy) NSArray *pets;

@end
