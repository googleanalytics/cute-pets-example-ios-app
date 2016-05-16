#import "NavigationController.h"

#import "CutePet.h"
#import "GAI.h"
#import "ResultsViewController.h"
#import "UserInfoViewController.h"
#import "VoteViewController.h"

@interface NavigationController ()

@property(nonatomic, strong) NSMutableArray *allNames;
@property(nonatomic, strong) NSMutableArray *allImageNames;

@property(nonatomic, copy) NSArray *allPets;
@property(nonatomic, strong) NSMutableArray *availablePets;

@end

@implementation NavigationController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return self.topViewController.supportedInterfaceOrientations;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.allNames = [@[@"Coda",
                     @"Indie",
                     @"Kit",
                     @"Patches",
                     @"Pepper",
                     @"Rain",
                     @"Skip",
                     @"Snuggles",
                     @"Sox",
                     @"Tibbs"] mutableCopy];
  self.allImageNames = [self loadImageNames];

  self.allPets = [self loadAllPets];
  self.availablePets = [self.allPets mutableCopy];

  self.navigationBar.topItem.title = NSLocalizedString(@"AppName", nil);
}

- (void)shuffleArray:(NSMutableArray *)names {
  if (!names.count) {
    return;
  }

  NSUInteger count = names.count;
  for (NSUInteger i = count; i > 1; i--) {
    NSUInteger j = arc4random_uniform((u_int32_t)i);
    [names exchangeObjectAtIndex:(i - 1) withObjectAtIndex:j];
  }
}

- (NSArray *)loadAllPets {
  [self shuffleArray:self.allNames];
  [self shuffleArray:self.allImageNames];

  if (self.allNames.count != self.allImageNames.count) {
    NSLog(@"Arrays have mismatched sizes");
    return nil;
  }

  // Assign a random pet name to a random pet image.
  NSUInteger count = self.allNames.count;
  NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:count];
  for (NSUInteger i = 0; i < count; i++) {
    CutePet *pet = [[CutePet alloc] initWithName:self.allNames[i]
                                       imageName:[self.allImageNames[i] lastPathComponent]];
    if (pet) {
      [mutableArray addObject:pet];
    }
  }

  return [mutableArray copy];
}

- (NSMutableArray *)loadImageNames {
  NSArray *contents = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg"
                                                         inDirectory:nil];
  if (!contents) {
    NSLog(@"Failed to load directory contents");
    return nil;
  }

  // Only get the image names that contain a dash.
  NSPredicate *dashPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject,
                                                                     NSDictionary *bindings) {
    if ([evaluatedObject isKindOfClass:[NSString class]]) {
      NSString *name = [evaluatedObject lastPathComponent];
      return [[name stringByDeletingPathExtension] componentsSeparatedByString:@"-"].count > 1;
    }
    return NO;
  }];

  return [[contents filteredArrayUsingPredicate:dashPredicate] mutableCopy];
}

- (void)pushNextViewControllerWithCurrentPet:(CutePet *)currentPet {
  // If no more comparisons left, show the last view controller.
  if (!self.availablePets.count) {
    ResultsViewController *resultsController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"ResultsViewController"];
    resultsController.sortedPets = self.allPets;
    [self pushViewController:resultsController animated:YES];

    // Dispatch any pending hits.
    [[GAI sharedInstance] dispatch];
    return;
  }

  // Get a random pet if we don't have a current one.
  if (!currentPet) {
    currentPet = [self popRandomPet];
  }

  // Randomize the position of the current pet.
  CutePet *otherPet = [self popRandomPet];
  NSMutableArray *pets = [@[currentPet, otherPet] mutableCopy];
  [self shuffleArray:pets];

  // Show the next comparison.
  VoteViewController *voteController =
      [self.storyboard instantiateViewControllerWithIdentifier:@"VoteViewController"];
  voteController.pets = pets;

  [self pushViewController:voteController animated:YES];
}

- (void)startOver {
  // Reshuffle the pet images and their names.
  self.allPets = [self loadAllPets];
  self.availablePets = [self.allPets mutableCopy];
  [self popToRootViewControllerAnimated:YES];
}

- (CutePet *)popRandomPet {
  if (!self.availablePets.count) {
    return nil;
  }

  NSUInteger randomIndex = arc4random_uniform((u_int32_t)self.availablePets.count);
  CutePet *randomPet = self.availablePets[randomIndex];
  [self.availablePets removeObjectAtIndex:randomIndex];
  return randomPet;
}

@end
