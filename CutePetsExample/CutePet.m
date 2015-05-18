#import "CutePet.h"

@implementation CutePet

- (id)initWithName:(NSString *)name imageName:(NSString *)imageName {
  self = [super init];
  if (self) {
    _name = [name copy];
    _imageName = [imageName copy];
  }
  return self;
}

@end
