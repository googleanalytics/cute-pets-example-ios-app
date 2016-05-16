#import "VoteViewController.h"

#import "CutePet.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"
#import "NavigationController.h"

@interface VoteViewController ()

@property(nonatomic, weak) IBOutlet UIButton *buttonA;
@property(nonatomic, weak) IBOutlet UIButton *buttonB;

@property(nonatomic, weak) IBOutlet UIImageView *imageViewA;
@property(nonatomic, weak) IBOutlet UIImageView *imageViewB;

@property(nonatomic, weak) IBOutlet UILabel *label;

@property(nonatomic, copy) NSArray *portraitConstraints;
@property(nonatomic, copy) NSArray *landscapeConstraints;

@end

@implementation VoteViewController

#pragma mark - View Controller Life-cycle

- (void)viewDidLoad {
  [super viewDidLoad];

  self.label.text = NSLocalizedString(@"TapPrompt", nil);

  self.navigationItem.hidesBackButton = YES;
  self.navigationController.navigationBarHidden = YES;

  [self configureConstraints];

  // Set the screen name for automatic screenview tracking.
  self.screenName = @"Vote";
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  if (self.pets.count >= 2) {
    self.imageViewA.image = [UIImage imageNamed:[self.pets[0] imageName]];
    self.imageViewB.image = [UIImage imageNamed:[self.pets[1] imageName]];

    [self.buttonA setTitle:[self.pets[0] name] forState:UIControlStateNormal];
    [self.buttonB setTitle:[self.pets[1] name] forState:UIControlStateNormal];
  }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

  [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints {
  [super updateViewConstraints];

  UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
  if (UIInterfaceOrientationIsPortrait(orientation)) {
    if (self.landscapeConstraints) {
      [self.view removeConstraints:self.landscapeConstraints];
    }

    if (self.portraitConstraints) {
      [self.view addConstraints:self.portraitConstraints];
    }
  } else {
    if (self.portraitConstraints) {
      [self.view removeConstraints:self.portraitConstraints];
    }

    if (self.landscapeConstraints) {
      [self.view addConstraints:self.landscapeConstraints];
    }
  }
}

- (void)configureConstraints {
  NSMutableArray *tempArray = [NSMutableArray array];

  // Construct all of the constraints for portrait orientation.
  [tempArray addObject:[NSLayoutConstraint constraintWithItem:self.label
                                                    attribute:NSLayoutAttributeCenterY
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.view
                                                    attribute:NSLayoutAttributeCenterY
                                                   multiplier:1.0
                                                     constant:0.0]];

  [tempArray addObject:[NSLayoutConstraint constraintWithItem:self.buttonA
                                                    attribute:NSLayoutAttributeWidth
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.view
                                                    attribute:NSLayoutAttributeWidth
                                                   multiplier:1.0
                                                     constant:0.0]];

  [tempArray addObject:[NSLayoutConstraint constraintWithItem:self.buttonA
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.view
                                                    attribute:NSLayoutAttributeHeight
                                                   multiplier:0.4
                                                     constant:0.0]];

  [tempArray addObject:[NSLayoutConstraint constraintWithItem:self.buttonA
                                                    attribute:NSLayoutAttributeTop
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.view
                                                    attribute:NSLayoutAttributeTop
                                                   multiplier:1.0
                                                     constant:0.0]];

  self.portraitConstraints = [tempArray copy];

  tempArray = [NSMutableArray array];

  // Construct all of the constraints for landscape orientation.
  [tempArray addObject:[NSLayoutConstraint constraintWithItem:self.label
                                                    attribute:NSLayoutAttributeCenterY
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.view
                                                    attribute:NSLayoutAttributeCenterY
                                                   multiplier:0.25
                                                     constant:0.0]];

  [tempArray addObject:[NSLayoutConstraint constraintWithItem:self.buttonA
                                                    attribute:NSLayoutAttributeWidth
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.view
                                                    attribute:NSLayoutAttributeWidth
                                                   multiplier:0.5
                                                     constant:0.0]];

  [tempArray addObject:[NSLayoutConstraint constraintWithItem:self.buttonA
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.view
                                                    attribute:NSLayoutAttributeHeight
                                                   multiplier:0.75
                                                     constant:0.0]];

  [tempArray addObject:[NSLayoutConstraint constraintWithItem:self.buttonA
                                                    attribute:NSLayoutAttributeBottom
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.view
                                                    attribute:NSLayoutAttributeBottom
                                                   multiplier:1.0
                                                     constant:0.0]];

  self.landscapeConstraints = [tempArray copy];
}

- (IBAction)handlePetButton:(id)sender {
  self.buttonA.enabled = NO;
  self.buttonB.enabled = NO;

  CutePet *selectedPet = [sender isEqual:self.buttonA] ? self.pets[0] : self.pets[1];
  selectedPet.score = selectedPet.score + 1;

  [self trackVoteWithSelectedPet:selectedPet];

  NavigationController *navigationController = (NavigationController *)self.navigationController;
  [navigationController pushNextViewControllerWithCurrentPet:selectedPet];
}

#pragma mark - Analytics

- (void)trackVoteWithSelectedPet:(CutePet *)selectedPet {
  if (!selectedPet) {
    return;
  }

  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

  // Create events to track the selected image and selected name.
  [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Image"
                                                        action:@"Vote"
                                                         label:selectedPet.imageName
                                                         value:@(1)] build]];

  [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Name"
                                                        action:@"Vote"
                                                         label:selectedPet.name
                                                         value:@(1)] build]];
}

@end
