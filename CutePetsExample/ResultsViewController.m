#import "ResultsViewController.h"

#import "CutePet.h"
#import "NavigationController.h"

@interface ResultsViewController () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) IBOutlet UILabel *label;
@property(nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation ResultsViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationItem.hidesBackButton = YES;
  self.navigationController.navigationBarHidden = NO;

  [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];

  self.label.text = NSLocalizedString(@"Results", nil);

  // Set the screen name for automatic screenview tracking.
  self.screenName = @"Results";
}

- (void)viewDidAppear:(BOOL)animated {
  // When overriding viewDidAppear of a GAITrackedViewController, make sure to call
  // [super viewDidAppear:] to automatically track the screen. The screen name must
  // already be set.
  [super viewDidAppear:animated];

  [self.tableView flashScrollIndicators];
}

- (IBAction)handleStartOverButton:(id)sender {
  NavigationController *navigationController = (NavigationController *)self.navigationController;
  [navigationController startOver];
}

- (void)setSortedPets:(NSArray *)sortedPets {
  // Sort pets by descending score.
  NSArray *sorted = [sortedPets sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    CutePet *pet1 = obj1;
    CutePet *pet2 = obj2;
    return pet1.score < pet2.score;
  }];

  if (![sorted isEqualToArray:_sortedPets]) {
    _sortedPets = [sorted copy];
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row < 0 || indexPath.row >= self.sortedPets.count) {
    NSLog(@"Row %zd out of bounds!", indexPath.row);
    return nil;
  }

  CutePet *pet = self.sortedPets[indexPath.row];

  // Use custom cell from storyboard.
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
  UIImageView *imageView = (UIImageView *)[cell viewWithTag:1];
  imageView.image = [UIImage imageNamed:pet.imageName];

  UILabel *label = (UILabel *)[cell viewWithTag:2];
  label.text = pet.name;

  return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  BOOL isPhone = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
  return isPhone ? 44.0 : 76.0;
}

@end
