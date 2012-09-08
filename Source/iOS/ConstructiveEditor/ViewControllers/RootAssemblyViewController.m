//
//  RootAssemblyViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "RootAssemblyViewController.h"

#import "Assembly.h"
#import "AssemblyCellView.h"
#import "Detail.h"
#import "DetailType.h"
#import "EditAssemblyViewController.h"
#import "AssembliesAndDetailsViewController.h"
#import "ActionSheet.h"
#import "PreferencesKeys.h"
#import "ReinterpretActionHandler.h"
#import "CoreData/CoreData.h"

@interface RootAssemblyViewController ()
  {
  ReinterpretActionHandler*               _interpreter;
  __weak IBOutlet UITableView*            _rootAssemblyTable;
  }
@end

@interface RootAssemblyViewController (UITableViewDataSource) <UITableViewDataSource>
@end

@interface RootAssemblyViewController (UITableViewDelegate) <UITableViewDelegate>
@end

@implementation RootAssemblyViewController

@synthesize rootAssembly = _rootAssembly;

- (void)viewDidLoad
  {
  [super viewDidLoad];
  }

- (void)viewWillAppear:(BOOL)animated
  {
	[super viewWillAppear:animated];
  _rootAssemblyTable.delegate = self;
  _rootAssemblyTable.dataSource = self;
  [_rootAssemblyTable setEditing:NO animated:NO];//nothing to move, add or delete here
  _interpreter = [[ReinterpretActionHandler alloc] initWithViewController:self andSegueToNextViewControllerName:@"ShowRootAssemblyDetails"]; 
	[_rootAssemblyTable reloadData];
  }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
  {
  return YES;
  }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if ([@"EditRootAssemblyInterpreted"     isEqualToString:segue.identifier] ||
      [@"EditRootAssemblyNotInterpreted"  isEqualToString:segue.identifier])
    ((EditAssemblyViewController*)segue.destinationViewController).assembly = _rootAssembly;
  else if([@"ShowRootAssemblyDetails" isEqualToString:segue.identifier])
    ((AssembliesAndDetailsViewController*)segue.destinationViewController).assembly = _rootAssembly;
  }
  
- (IBAction)interpret:(id)sender
  {
  [_interpreter interpretAssembly:_rootAssembly];
  }
  
- (IBAction)reinterpret:(id)sender
  {
  [_interpreter reinterpretAssembly:_rootAssembly];
  }
  
@end

@implementation RootAssemblyViewController (UITableViewDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
  {
  if (tableView != _rootAssemblyTable)
    return 0;
  return 1;
  }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
  {
  if (tableView != _rootAssemblyTable)
    return 0;
  return 1;
  }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
  {
  if (tableView != _rootAssemblyTable)
    return nil;
  return NSLocalizedString(@"End result", @"Root assembly table header");
  }
  
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _rootAssemblyTable || indexPath.section != 0 || indexPath.row != 0)
    return nil;
    
  BOOL isAssemblyInterpreted = _rootAssembly.detailsInstalled.count ||
                               nil != _rootAssembly.assemblyBase ||
                               nil != _rootAssembly.assemblyBeforeTransformation ||
                               nil != _rootAssembly.assemblyBeforeRotation;
  AssemblyCellView* cell = (AssemblyCellView*)[tableView dequeueReusableCellWithIdentifier: isAssemblyInterpreted
                         ? @"AssemblyInterpretedCell"
                         : @"AssemblyNotInterpretedCell"];
  cell.picture.image = [_rootAssembly pictureToShow]
                     ? [_rootAssembly pictureToShow]
                     : [UIImage imageNamed:@"camera.png"];
  return cell;
  }
  
@end

@implementation RootAssemblyViewController (UITableViewDelegate)
@end

