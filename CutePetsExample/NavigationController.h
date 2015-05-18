#import <UIKit/UIKit.h>

@class CutePet;

@interface NavigationController : UINavigationController

- (void)pushNextViewControllerWithCurrentPet:(CutePet *)currentPet;
- (void)startOver;

@end
