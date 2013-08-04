//
//  InstructionBuilder.h
//  ConstructiveEditor

#import <Foundation/Foundation.h>

@class Assembly;

@interface InstructionBuilder : NSObject

- (id)initWithAssembly:(Assembly*)assembly;
+ (id)builderWithAssembly:(Assembly*)assembly;

- (NSUInteger)pagesCount;
- (void)prepareCell:(UICollectionViewCell*)cell forItemAtPage:(NSUInteger)page;

@end
