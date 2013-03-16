//
//  NSManagedObjectContextExtension.h
//  ConstructiveEditor


#import "CoreData/CoreData.h"

@interface NSManagedObjectContext (Extension)
  - (void)saveAsyncAndHandleError;
  - (void)saveAndHandleError;
@end
