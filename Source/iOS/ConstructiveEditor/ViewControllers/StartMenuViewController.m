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
#import "DirectoryWatcher.h"
#import "RootAssemblyViewController.h"
#import "NSManagedObjectContextExtension.h"
#import "PreferencesKeys.h"

@interface StartMenuViewController ()
  {
    __weak IBOutlet UITextField*  _newDocumentNameTextField;
    __weak IBOutlet UIButton*     _newDocumentCreateButton;
    __weak IBOutlet UITableView*  _documentsTable;
    DirectoryWatcher*             _docWatcher;
    NSMutableArray*               _documentURLs;
  }
@end

@interface StartMenuViewController (UITextFieldDelegate) <UITextFieldDelegate>
@end

@interface StartMenuViewController (UITableViewDelegate) <UITableViewDelegate>
@end

@interface StartMenuViewController (UITableViewDataSource) <UITableViewDataSource>
@end

@interface StartMenuViewController (DirectoryWatcherDelegate) <DirectoryWatcherDelegate>
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
  AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
  _docWatcher = [DirectoryWatcher watchFolderWithPath:[appDelegate applicationDocumentsDirectory] delegate:self];
  _documentURLs = [NSMutableArray array];
  // scan for existing documents
  [self directoryDidChange:_docWatcher];
  
  [appDelegate setStartMenuViewController:self];
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
        if (1 == buttonIndex)
          {
          [app.delegate application:app openURL:[NSURL fileURLWithPath: newDocumentPath] sourceApplication:nil annotation:nil];
          }
        if (2 == buttonIndex)
          {
          [[NSFileManager defaultManager] removeItemAtPath:newDocumentPath error:nil];//TODO: handle the error...
          [app.delegate application:app openURL:[NSURL fileURLWithPath: newDocumentPath] sourceApplication:nil annotation:nil];
          }
        };
          
    AlertView* alert = [[AlertView alloc]
        initWithTitle:NSLocalizedString(@"Confirm rewriting", @"Alert view: title")
              message:NSLocalizedString(@"File with the same name already exists. Would you like to rewrite it?", @"Alert view: message")
     clickButtonBlock:clickButtonBlock
    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Alert view: cancel")
    otherButtonTitles:NSLocalizedString(@"Open existing file", @"Alert view: button"), NSLocalizedString(@"Rewrite", @"Alert view: button"), nil];
    [alert show];
    }
  else
    [app.delegate application:app openURL:[NSURL fileURLWithPath: newDocumentPath] sourceApplication:nil annotation:nil];
  }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if ([segue.identifier isEqualToString:@"OpenURL"])
    {
    [self.navigationController popToViewController:self animated:NO];
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
  
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
  {
  UIApplication* app = [UIApplication sharedApplication];
  [app.delegate application:app openURL:[NSURL fileURLWithPath: [[_documentURLs objectAtIndex:indexPath.row] path]] sourceApplication:nil annotation:nil];
  }
  
@end

@implementation StartMenuViewController (UITableViewDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
  {
  return 1;
  }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
  {
  return _documentURLs.count;
  }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
  {
  return NSLocalizedString(@"Existing Documents", @"Table view header");
  }

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
  {
  static NSString *cellIdentifier = @"DocumentTableViewCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  NSURL *fileURL = [_documentURLs objectAtIndex:indexPath.row];
  cell.textLabel.text = [[fileURL path] lastPathComponent];
  return cell;
  }
    
@end

@implementation StartMenuViewController (DirectoryWatcherDelegate)

- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher
  {
	[_documentURLs removeAllObjects];    // clear out the old docs and start over
	
	NSString *documentsDirectoryPath = [(AppDelegate*)[UIApplication sharedApplication].delegate applicationDocumentsDirectory];
	
	NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectoryPath error:NULL];
    
	for (NSString* curFileName in [documentsDirectoryContents objectEnumerator])
    {
		NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:curFileName];
		NSURL *fileURL = [NSURL fileURLWithPath:filePath];
		
		BOOL isDirectory;
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];

    // proceed to add the document URL to our list (ignore any folders including the "Inbox" and "Pictures" folder) and files with unsupported extensions
    if (!isDirectory && [curFileName.pathExtension isEqualToString:constructiveEditorSQLiteDocumentExtension])
      [_documentURLs addObject:fileURL];
    }
	
	[_documentsTable reloadData];
  }

@end
