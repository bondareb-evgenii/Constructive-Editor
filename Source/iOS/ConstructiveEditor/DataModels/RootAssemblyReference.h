//
//  RootAssemblyReference.h
//  ConstructiveEditor

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Assembly;

@interface RootAssemblyReference : NSManagedObject

@property (nonatomic, retain) Assembly *rootAssembly;

@end
