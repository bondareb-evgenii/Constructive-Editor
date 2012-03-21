//
//  ViewController.h
//  CoreDataTest1
//
//  Created by Evgenii Bondarev on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
  {
    NSPersistentStoreCoordinator* _persistentStoreCoordinator;
    NSManagedObjectModel*         _managedObjectModel;
    NSManagedObjectContext*       _managedObjectContext;
    
    NSIndexPath*                  _selectedIndexPath;
    NSMutableArray*               _assembliesArray;
    NSMutableArray*               _detailsArray;
    __weak IBOutlet UITableView*  _entitiesTable;
  }

  - (NSString *)applicationDocumentsDirectory;
  - (void)saveContext;

@end
