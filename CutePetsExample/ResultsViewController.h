#import "GAITrackedViewController.h"

// Extend GAITrackedViewController to enable automatic screenview tracking for this view controller.
// Set the view controller's screen name in viewDidLoad.
@interface ResultsViewController : GAITrackedViewController

@property(nonatomic, copy) NSArray *sortedPets;

@end
