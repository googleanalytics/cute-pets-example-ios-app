#import "InstructionsViewController.h"

#import "NavigationController.h"

@interface InstructionsViewController ()

@property(nonatomic, weak) IBOutlet UILabel *instructionsLabel;

@end

@implementation InstructionsViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationItem.hidesBackButton = YES;
  self.instructionsLabel.text = NSLocalizedString(@"Instructions", nil);

  // Set the screen name for automatic screenview tracking.
  self.screenName = @"Instructions";
}

- (IBAction)handleStartButton:(id)sender {
  NavigationController *navigationController = (NavigationController *)self.navigationController;
  [navigationController pushNextViewControllerWithCurrentPet:nil];
}

@end
