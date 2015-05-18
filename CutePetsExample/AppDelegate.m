#import "AppDelegate.h"
#import "GAI.h"

//
// Google Analytics configuration constants
//

// Property ID (provided by https://www.google.com/analytics/web/ ) used to initialize a tracker.
static NSString *const kCutePetsPropertyId = @"UA-54478999-4";

// Dispatch interval for automatic dispatching of hits to Google Analytics.
// Values 0.0 or less will disable periodic dispatching. The default dispatch interval is 120 secs.
static NSTimeInterval const kCutePetsDispatchInterval = 120.0;

// Set log level to have the Google Analytics SDK report debug information only in DEBUG mode.
#if DEBUG
static GAILogLevel const kCutePetsLogLevel = kGAILogLevelVerbose;
#else
static GAILogLevel const kCutePetsLogLevel = kGAILogLevelWarning;
#endif

@interface AppDelegate ()

@property(nonatomic, copy) void (^dispatchHandler)(GAIDispatchResult result);

- (void)initializeGoogleAnalytics;
- (void)sendHitsInBackground;

@end

@implementation AppDelegate

- (void)initializeGoogleAnalytics {
  // Automatically send uncaught exceptions to Google Analytics.
  [GAI sharedInstance].trackUncaughtExceptions = YES;

  // Set the dispatch interval for automatic dispatching.
  [GAI sharedInstance].dispatchInterval = kCutePetsDispatchInterval;

  // Set the appropriate log level for the default logger.
  [GAI sharedInstance].logger.logLevel = kCutePetsLogLevel;

  // Initialize a tracker using a Google Analytics property ID.
  [[GAI sharedInstance] trackerWithTrackingId:kCutePetsPropertyId];
}

// This method sends any queued hits when the app enters the background.
- (void)sendHitsInBackground {
  __block BOOL taskExpired = NO;

  __block UIBackgroundTaskIdentifier taskId =
  [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    taskExpired = YES;
  }];

  if (taskId == UIBackgroundTaskInvalid) {
    return;
  }

  __weak AppDelegate *weakSelf = self;
  self.dispatchHandler = ^(GAIDispatchResult result) {
    // Dispatch hits until we have none left, we run into a dispatch error,
    // or the background task expires.
    if (result == kGAIDispatchGood && !taskExpired) {
      [[GAI sharedInstance] dispatchWithCompletionHandler:weakSelf.dispatchHandler];
    } else {
      [[UIApplication sharedApplication] endBackgroundTask:taskId];
    }
  };

  [[GAI sharedInstance] dispatchWithCompletionHandler:self.dispatchHandler];
}

- (BOOL)application:(UIApplication *)application
      didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [self initializeGoogleAnalytics];
  return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  [self sendHitsInBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Restore the dispatch interval since dispatchWithCompletionHandler:
  // disables automatic dispatching.
  [GAI sharedInstance].dispatchInterval = kCutePetsDispatchInterval;
}

@end
