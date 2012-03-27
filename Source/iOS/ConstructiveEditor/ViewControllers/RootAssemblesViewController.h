//
//  RootAssemblesViewController.h
//  ConstructiveEditor
//
//  Created by Evgenii Bondarev on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootAssemblesViewController : UIViewController
  {
    NSPersistentStoreCoordinator*     _persistentStoreCoordinator;
    NSManagedObjectModel*             _managedObjectModel;
    NSManagedObjectContext*           _managedObjectContext;
    
    NSIndexPath*                      _selectedIndexPath;
    NSMutableArray*                   _rootAssembliesArray;
    NSUInteger                        _addItemIndex;
    __weak IBOutlet UITableView*      _rootAssembliesTable;
    __weak IBOutlet UIBarButtonItem*  _editOrDoneButton;
  }

  - (NSString *)applicationDocumentsDirectory;
  - (void)saveContext;

@end
