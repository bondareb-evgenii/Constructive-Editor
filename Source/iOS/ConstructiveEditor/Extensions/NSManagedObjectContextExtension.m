//
//  NSManagedObjectContextExtension.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "NSManagedObjectContextExtension.h"
#import "Constants.h"

@implementation NSManagedObjectContext (Extension)

- (void)saveAsyncAndHandleError
  {
  if ([self hasChanges])
    [[NSNotificationCenter defaultCenter] postNotificationName:NSManagedObjectContextWillSaveAsyncNotification object:self];
  }

- (void)saveAndHandleError
  {
  NSLog(@"Saving context: %@", self);
  NSError *error = nil;
  if ([self hasChanges] && ![self save:&error])
    {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);//error.debugDescription
      abort();
    }
  }

@end
