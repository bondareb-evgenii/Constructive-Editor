//
//  AppDelegate.m
//  ConstructiveEditor


#import "AppDelegate.h"
#import "Constants.h"
#import "StartMenuViewController.h"
#import "MBProgressHUD.h"
#import "NSManagedObjectContextExtension.h"

NSString* const NSManagedObjectContextWillSaveAsyncNotification = @"NSManagedObjectContextWillSaveAsyncNotification";

@interface AppDelegate ()
  {
  NSURL*                                  _openedURL;
  NSPersistentStoreCoordinator*           _persistentStoreCoordinator;
  NSManagedObjectModel*                   _managedObjectModel;
  NSManagedObjectContext*                 _managedObjectContext;
  NSManagedObjectContext*                 _privateManagedObjectContextForSaving;
  BOOL                                    _goingIntoBackground;
  BOOL                                    _saving;
  NSTimer*                                _savingTimer;
  }
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize startMenuViewController = _startMenuViewController;

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
	
	NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];

	// Allow inferred migration from the original version of the application.
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:_openedURL options:options error:&error])
    {
    NSLog(@"Error: %@", error.debugDescription);
    }    
	
    return _persistentStoreCoordinator;
}


/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext
  {
  if (_managedObjectContext != nil)
    return _managedObjectContext;

  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil)
    {
    _privateManagedObjectContextForSaving = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_privateManagedObjectContextForSaving setUndoManager:nil];
    [_privateManagedObjectContextForSaving setPersistentStoreCoordinator: coordinator];
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setUndoManager:nil];
    [_managedObjectContext setParentContext:_privateManagedObjectContextForSaving];
    
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(contextWillSaveAsync:)
               name:NSManagedObjectContextWillSaveAsyncNotification
             object:_managedObjectContext];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(contextDidSave:)
               name:NSManagedObjectContextDidSaveNotification
             object:_managedObjectContext];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(privateContextDidSave:)
               name:NSManagedObjectContextDidSaveNotification
             object:_privateManagedObjectContextForSaving];
    }
  return _managedObjectContext;
  }

- (void)contextWillSaveAsync:(NSNotification*)saveNotification
  {
  [self tryToSave];
  }

- (void)tryToSave
  {
  _savingTimer = nil;
  if (_saving)
    {
    _savingTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(tryToSave) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_savingTimer forMode:NSRunLoopCommonModes];
    }
  else
    //this call may still freaze the main thread in case if the _privateManagedObjectContextForSaving is currently saving
    [self.managedObjectContext saveAndHandleError];
  }

- (void)contextDidSave:(NSNotification*)saveNotification
  {
  void (^save) (void) = ^
    {
    [_privateManagedObjectContextForSaving saveAndHandleError];
    };

  if ([_privateManagedObjectContextForSaving hasChanges])
    {
    if (_goingIntoBackground)
      [_privateManagedObjectContextForSaving performBlockAndWait:save];
    else
      {
      _saving = YES;
      [_privateManagedObjectContextForSaving performBlock:save];
      }
    }
  }

- (void)privateContextDidSave:(NSNotification*)saveNotification
  {
  _saving = NO;
  [MBProgressHUD hideHUDForView:self.window animated:YES];
  }

- (NSString *)applicationDocumentsDirectory
  {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
  return basePath;
  } 

- (void)setStartMenuViewController:(StartMenuViewController*)startMenuViewController
  {
  if (startMenuViewController == _startMenuViewController)
    return;
  _startMenuViewController = startMenuViewController;
  if(_openedURL)
    {
    self.startMenuViewController.managedObjectContext = [self managedObjectContext];
    [self.startMenuViewController performSegueWithIdentifier:@"OpenURL" sender:nil];
    }
  }
  
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

- (void)closeCurrentDocument
  {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
    
  _openedURL = nil;
  _managedObjectModel = nil;
  _persistentStoreCoordinator = nil;
  _managedObjectContext = nil;
  }

- (void)dealloc
  {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  }
  
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
  {
  if ([url isEqual:_openedURL])
    return YES;
  
  NSURL* copiedFileURL = nil;
  NSFileManager* fileManager = [NSFileManager defaultManager];
  if ([fileManager fileExistsAtPath:url.path] && ![fileManager isWritableFileAtPath:url.path])
    {
    NSString* documentsDirectoryPath = [(AppDelegate*)[UIApplication sharedApplication].delegate applicationDocumentsDirectory];
    NSString* copiedFilePath = [documentsDirectoryPath stringByAppendingPathComponent:[url.path lastPathComponent]];
    while ([fileManager fileExistsAtPath:copiedFilePath])
      {
      copiedFilePath = [[copiedFilePath stringByDeletingPathExtension] stringByAppendingFormat:@" inbox.%@", constructiveEditorSQLiteDocumentExtension];
      }
    copiedFileURL = [NSURL fileURLWithPath:copiedFilePath];
    [[NSFileManager defaultManager] copyItemAtURL:url toURL:copiedFileURL error:nil];
    }
  [self closeCurrentDocument];
  _openedURL = copiedFileURL ? copiedFileURL : url;
  self.startMenuViewController.managedObjectContext = [self managedObjectContext];
  [self.startMenuViewController performSegueWithIdentifier:@"OpenURL" sender:nil];
  return YES;
  }

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
  {
  if (_saving)
    {
    [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    }
  }

- (void)applicationWillResignActive:(UIApplication *)application
  {
  _goingIntoBackground = YES;
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
  }

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
  {
  _goingIntoBackground = NO;
  /*
   Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   */
  }

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  /*
   Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  /*
   Called when the application is about to terminate.
   Save data if appropriate.
   See also applicationDidEnterBackground:.
   */
}

@end
