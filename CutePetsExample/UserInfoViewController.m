#import "UserInfoViewController.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "NavigationController.h"

@interface UserInfoViewController () <UIPickerViewDataSource, UIPickerViewDelegate,
    UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property(nonatomic, weak) IBOutlet UILabel *genderQuestionLabel;
@property(nonatomic, weak) IBOutlet UILabel *ageQuestionLabel;
@property(nonatomic, weak) IBOutlet UILabel *petQuestionLabel;

@property(nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property(nonatomic, weak) IBOutlet UIPickerView *pickerView;
@property(nonatomic, weak) IBOutlet UITableView *tableView;

@property(nonatomic, copy) NSArray *ageGroups;
@property(nonatomic, copy) NSArray *petChoices;

@end

@implementation UserInfoViewController

- (NSUInteger)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.ageGroups = @[NSLocalizedString(@"AgeGroup_1", nil),
                     NSLocalizedString(@"AgeGroup_2", nil),
                     NSLocalizedString(@"AgeGroup_3", nil)];

  self.petChoices = @[NSLocalizedString(@"Choice_Cats", nil),
                      NSLocalizedString(@"Choice_Dogs", nil)];


  NSDictionary *attributes = [NSDictionary dictionaryWithObject:self.genderQuestionLabel.font
                                                         forKey:NSFontAttributeName];
  [self.segmentedControl setTitleTextAttributes:attributes
                                       forState:UIControlStateNormal];

  if (self.scrollView) {
    [self.scrollView flashScrollIndicators];
  }

  // Set the screen name for automatic screenview tracking.
  self.screenName = @"User Info";
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self updateInterface];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [self trackAnswers];
}

- (void)updateInterface {
  self.genderQuestionLabel.text = NSLocalizedString(@"Question_Gender", nil);
  self.ageQuestionLabel.text = NSLocalizedString(@"Question_Age", nil);
  self.petQuestionLabel.text = NSLocalizedString(@"Question_Pet", nil);

  [self resetSelections];
}

- (void)resetSelections {
  // Return views to their default state.
  self.segmentedControl.selectedSegmentIndex = 0;
  [self.pickerView selectRow:1 inComponent:0 animated:NO];

  NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
  for (NSIndexPath *indexPath in selectedRows) {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
  }

  NSArray *visibleRows = [self.tableView indexPathsForVisibleRows];
  for (NSIndexPath *indexPath in visibleRows) {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    cell.accessoryType = UITableViewCellAccessoryNone;
  }

  if (self.scrollView) {
    self.scrollView.contentOffset = CGPointZero;
  }
}

- (void)trackAnswers {
  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

  // Create custom dimensions to track gender, age group, and pets owned for the current user.
  NSString *genderValue = self.segmentedControl.selectedSegmentIndex == 0 ? @"Female" : @"Male";
  [tracker set:[GAIFields customDimensionForIndex:1] value:genderValue];

  NSString *ageGroupValue = self.ageGroups[[self.pickerView selectedRowInComponent:0]];
  [tracker set:[GAIFields customDimensionForIndex:2] value:ageGroupValue];

  NSArray *selectedRows = self.tableView.indexPathsForSelectedRows;
  NSString *isCatOwner = [selectedRows containsObject:[NSIndexPath indexPathForRow:0 inSection:0]] ?
      @"Yes" : @"No";
  NSString *isDogOwner = [selectedRows containsObject:[NSIndexPath indexPathForRow:1 inSection:0]] ?
      @"Yes" : @"No";
  [tracker set:[GAIFields customDimensionForIndex:3] value:isCatOwner];
  [tracker set:[GAIFields customDimensionForIndex:4] value:isDogOwner];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return self.ageGroups.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
  if (row < 0 || row >= self.ageGroups.count) {
    NSLog(@"Row %zd out of bounds!", row);
    return nil;
  }

  return self.ageGroups[row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view
{
  if (row < 0 || row >= self.ageGroups.count) {
    NSLog(@"Row %zd out of bounds!", row);
    return nil;
  }

  UILabel* label = (UILabel*)view;
  if (!label)
  {
    label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = self.ageQuestionLabel.font;
  }

  label.text = self.ageGroups[row];
  return label;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.petChoices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row < 0 || indexPath.row >= self.petChoices.count) {
    NSLog(@"Row %zd out of bounds!", indexPath.row);
    return nil;
  }

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
  cell.textLabel.text = self.petChoices[indexPath.row];

  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  cell.accessoryType = UITableViewCellAccessoryNone;
}

@end
