//
//  AssemblyTypesShelf.h
//  ConstructiveEditor


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AssemblyType;

@interface AssemblyTypesShelf : NSManagedObject

@property (nonatomic, retain) NSSet *assemblyTypes;
@end

@interface AssemblyTypesShelf (CoreDataGeneratedAccessors)

- (void)addAssemblyTypesObject:(AssemblyType *)value;
- (void)removeAssemblyTypesObject:(AssemblyType *)value;
- (void)addAssemblyTypes:(NSSet *)values;
- (void)removeAssemblyTypes:(NSSet *)values;

@end
