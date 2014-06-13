//
//  InstructionBuilder.h
//  ConstructiveEditor

#import <Foundation/Foundation.h>

@class Assembly;

@interface InstructionBuilder : NSObject

- (id)initWithAssembly:(Assembly*)assembly;
+ (id)builderWithAssembly:(Assembly*)assembly;

- (NSUInteger)stepsCount;
- (void)prepareCell:(UICollectionViewCell*)cell forItemAtStep:(NSUInteger)step;

@end
