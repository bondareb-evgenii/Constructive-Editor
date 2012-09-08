//
//  StartMenuViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "StartMenuViewController.h"
#import "Assembly.h"
#import "AppDelegate.h"
#import "AlertView.h"
#import "RootAssemblyViewController.h"
#import "NSManagedObjectContextExtension.h"
#import "PreferencesKeys.h"

@interface StartMenuViewController ()
  {
    __weak IBOutlet UITextField *_newDocumentNameTextField;
    __weak IBOutlet UIButton *_newDocumentCreateButton;
  }
@end

@interface StartMenuViewController (UITextFieldDelegate) <UITextFieldDelegate>
@end

@interface StartMenuViewController (UITableViewDelegate) <UITableViewDelegate>
@end

@interface StartMenuViewController (UITableViewDataSource) <UITableViewDataSource>
@end


@implementation StartMenuViewController

@synthesize managedObjectContext = _managedObjectContext;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
    //Test
}

#pragma mark - View lifecycle

- (void)viewDidLoad
  {
  [super viewDidLoad];
  [(AppDelegate*)[UIApplication sharedApplication].delegate setStartMenuViewController:self];
  }

- (void)viewWillAppear:(BOOL)animated
  {
  [(AppDelegate*)[UIApplication sharedApplication].delegate closeCurrentDocument];
  [super viewWillAppear:animated];
  }

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

- (IBAction)onCreateNewDocument:(id)sender
  {
  [_newDocumentNameTextField resignFirstResponder];
  NSString* newDocumentName = _newDocumentNameTextField.text;
  if (0 == _newDocumentNameTextField.text.length)
    {
    [_newDocumentNameTextField becomeFirstResponder];
    return;
    }
  UIApplication* app = [UIApplication sharedApplication];
  NSString* documentsDirName = [(AppDelegate*)app.delegate applicationDocumentsDirectory];
  NSString* newDocumentPath = [documentsDirName stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", newDocumentName, constructiveEditorSQLiteDocumentExtension]];
  if ([[NSFileManager defaultManager] fileExistsAtPath:newDocumentPath])
    {
    AlertViewClickButtonBlock clickButtonBlock = ^(AlertView *alertView, NSInteger buttonIndex)
        {
        if (kAlertViewCloseButtonIndex != buttonIndex &&
            0 != buttonIndex)
          {
          [[NSFileManager defaultManager] removeItemAtPath:newDocumentPath error:nil];//TODO: handle the error...
          [app.delegate application:app openURL:[NSURL fileURLWithPath: newDocumentPath] sourceApplication:nil annotation:nil];
          }
        };
          
    AlertView* alert = [[AlertView alloc]
        initWithTitle:NSLocalizedString(@"Confirm rewriting", @"Alert view: title")
              message:NSLocalizedString(@"File with the same name already exists. Would you like to rewrite it?", @"Alert view: message")
     clickButtonBlock:clickButtonBlock
    cancelButtonTitle:NSLocalizedString(@"NO", @"Alert view: cancel")
    otherButtonTitles:NSLocalizedString(@"YES", @"Alert view: button"), nil];
    [alert show];
    }
  else
    [app.delegate application:app openURL:[NSURL fileURLWithPath: newDocumentPath] sourceApplication:nil annotation:nil];
  }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if ([segue.identifier isEqualToString:@"OpenURL"])
    {
    _managedObjectContext = [self managedObjectContext];
    /*
     Fetch existing assemblies.
     Create a fetch request, add a sort descriptor, then execute the fetch.
     */
    NSFetchRequest *assembliesRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *assemblyEntity = [NSEntityDescription entityForName:@"Assembly" inManagedObjectContext:_managedObjectContext];
    [assembliesRequest setEntity:assemblyEntity];
    [assembliesRequest setPredicate:[NSPredicate predicateWithFormat:@"(assemblyToInstallTo = nil) AND (assemblyExtended = nil) AND (assemblyTransformed = nil) AND (assemblyRotated = nil)"]];
    
    // Execute the fetch -- create a mutable copy of the result.
    NSError *assembliesError = nil;
    NSArray* rootAssemblies = [[_managedObjectContext executeFetchRequest:assembliesRequest error:&assembliesError] mutableCopy];
    if (rootAssemblies == nil)
      {
      NSLog(@"Error: %@", assembliesError.debugDescription);
      return;
      }

    if (1 == rootAssemblies.count)
      ((RootAssemblyViewController*)segue.destinationViewController).rootAssembly = [rootAssemblies objectAtIndex:0];
    else if (rootAssemblies.count > 1)
      NSLog(@"There is more then one root assembly in model: %@", rootAssemblies);
    else if (0 == rootAssemblies.count)
      {
      Assembly* rootAssembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:self.managedObjectContext];
      rootAssembly.assemblyExtended = nil;
      rootAssembly.assemblyBase = nil;
      ((RootAssemblyViewController*)segue.destinationViewController).rootAssembly = rootAssembly;
      // Commit the change.
      [_managedObjectContext saveAndHandleError];
      }
    rootAssemblies = nil;
    }
  }

@end

@implementation StartMenuViewController (UITextFieldDelegate)
  
- (BOOL)textFieldShouldReturn:(UITextField *)textField
  {
  [self onCreateNewDocument:nil];
  return YES;
  }

@end

@implementation StartMenuViewController (UITableViewDelegate)

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
  {
  [_newDocumentNameTextField resignFirstResponder];
  }
  
@end

@implementation StartMenuViewController (UITableViewDataSource)

  - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    {
    return 0;
    }
    
@end
