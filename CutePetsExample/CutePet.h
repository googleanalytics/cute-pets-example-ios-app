#import <Foundation/Foundation.h>

@interface CutePet : NSObject

@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSString *imageName;
@property(nonatomic, assign) NSInteger score;

- (id)initWithName:(NSString *)name imageName:(NSString *)imageName;

@end
