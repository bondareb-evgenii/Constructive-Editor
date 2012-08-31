//
//  NSManagedObjectContextExtension.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "CoreData/CoreData.h"

@interface NSManagedObjectContext (Extension)
  - (void)saveAndHandleError;
@end
