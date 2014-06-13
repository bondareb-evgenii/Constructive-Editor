//
//  AssemblyValidator.m
//  ConstructiveEditor


#import "AssemblyValidator.h"

#import "ActionSheet.h"
#import "Assembly.h"
#import "AssemblyType.h"
#import "AssemblyValidatorGeneral.h"
#import "Detail.h"
#import "DetailType.h"
#import "NSManagedObjectContextExtension.h"
#import "RootAssemblyReference.h"

#import <vector>

struct SmallerAssembliesEnumerationCache
  {
  NSSet* smallerAssembliesCached;
  NSEnumerator* smallerAssembliesCachedEnumerator;
  BOOL enumeratingSmallerAssemblies;
  
  SmallerAssembliesEnumerationCache():
  smallerAssembliesCached(nil), smallerAssembliesCachedEnumerator(nil), enumeratingSmallerAssemblies(NO) {}
  };

@implementation AssemblyValidator

+ (Assembly*)rootAssemblyInContext:(NSManagedObjectContext*)managedObjectContext
  {
  Assembly* rootAssembly = nil;
  /*
   Fetch existing assemblies.
   Create a fetch request, add a sort descriptor, then execute the fetch.
   */
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"RootAssemblyReference" inManagedObjectContext:managedObjectContext];
  [request setEntity:entity];
  
  // Execute the fetch -- create a mutable copy of the result.
  NSError *error = nil;
  NSArray* rootAssemblyReferences = [managedObjectContext executeFetchRequest:request error:&error];
  if (rootAssemblyReferences == nil)
    {
    NSLog(@"Error: %@", error.debugDescription);
    return nil;
    }

  if (1 == rootAssemblyReferences.count)
    rootAssembly = [[rootAssemblyReferences objectAtIndex:0] rootAssembly];
  else if (rootAssemblyReferences.count > 1)
    {
    NSLog(@"There is more then one root assembly in model: %@", rootAssemblyReferences);
    assert(0);
    }
  else if (0 == rootAssemblyReferences.count)
    {
    //create a root assembly ans save a reference for it
    RootAssemblyReference* rootAssemblyReference = (RootAssemblyReference*)[NSEntityDescription insertNewObjectForEntityForName:@"RootAssemblyReference" inManagedObjectContext:managedObjectContext];
    rootAssembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:managedObjectContext];
    AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:managedObjectContext];
    rootAssembly.type = assemblyType;
    rootAssembly.assemblyExtended = nil;
    rootAssembly.type.assemblyBase = nil;
    rootAssemblyReference.rootAssembly = rootAssembly;
    
    // Commit the change.
    [managedObjectContext saveAsyncAndHandleError];
    }
  rootAssemblyReferences = nil;
  return rootAssembly;
  }

+ (BOOL)canDisassemble:(Assembly*)assemblyToCheck withError:(NSError**)error andSteps:(NSMutableArray*)steps;
  {
  return [[AssemblyValidatorGeneral validatorWitAssemblyType:assemblyToCheck.type] canDisassembleWithError:error andSteps:steps];
  }

+ (void)showExportMenuForRootAssembly:(Assembly*)rootAssembly inView:(UIView *)view previewInstructionBlock:(PreviewInstructionBlock)previewInstructionBlock
  {
  //model is OK and can be exported if only one validation rule is broken: some assemblies are not broken up yet, all the other rules should be satisfied. For example if some assembly is split to 1 detail (less then 2) then the model cannot be expoted until the user removes the detail
  NSError* error = nil;
  NSMutableArray* globalStepsArray = [[NSMutableArray alloc] initWithCapacity:10];
  BOOL isEntireModelValid = [self canDisassemble:rootAssembly withError:&error andSteps:globalStepsArray];
  
  if (isEntireModelValid)
    {
    ActionSheet* actionSheet = [[ActionSheet alloc]
         initWithTitle: NSLocalizedString(@"Export instruction to:", @"Action sheet: title")
      clickButtonBlock:^(ActionSheet* ActionSheet, NSInteger buttonIndex)
        {
        switch (buttonIndex)
          {
          case 0://PDF document
            {
            previewInstructionBlock(rootAssembly, kExportFileFormatPDF, globalStepsArray);
            break;
            }
          case 1://cancel
          default:
            break;
          }
        }
     cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
destructiveButtonTitle: nil
     otherButtonTitles: NSLocalizedString(@"PDF document", @"Action sheet: button"),
                        nil];
    [actionSheet showInView:view];
    }
  else
    {
    switch (error.code)
      {
      case kModelValidationErrorCodeAssemblyNotBrokenUp:
        {
        ActionSheet* actionSheet = [[ActionSheet alloc]
             initWithTitle: NSLocalizedString(@"Some assemblies are not broken up. Would you like to export instruction anyway to:", @"Action sheet: title")
          clickButtonBlock:^(ActionSheet* ActionSheet, NSInteger buttonIndex)
            {
            switch (buttonIndex)
              {
              case 0://PDF document
                {
                previewInstructionBlock(rootAssembly, kExportFileFormatPDF, globalStepsArray);
                break;
                }
              case 1://cancel
              default:
                break;
              }
            }
         cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
    destructiveButtonTitle: nil
         otherButtonTitles: NSLocalizedString(@"PDF document", @"Action sheet: button"),
                            nil];
        [actionSheet showInView:view];
        break;
        }
      case kModelValidationErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously:
      case kModelValidationErrorCodeLessThenTwoDetailsInSplitAssembly:
      case kModelValidationErrorCodeNoPartsDetachedFromAssembly:
      case kModelValidationErrorCodeDetailHasNoConnectionPoint:
      case kModelValidationErrorCodeSubassemblyHasNoConnectionPoint:
        {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Model is not valid.", @"Model validation error message") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Button title") otherButtonTitles:nil] show];
        break;
        }
      default:
        break;
      }
    }
  }

+ (void)calculateInstalledAssembliesGroupsForAssemblyType:(AssemblyType*)assemblyType intoArray:(NSMutableArray**)assembliesGroups andDictionary:(NSMutableDictionary**)assembliesGroupsDictionary
  {
  *assembliesGroups = [[NSMutableArray alloc] initWithCapacity:assemblyType.assembliesInstalled.count];
  *assembliesGroupsDictionary = [[NSMutableDictionary alloc] initWithCapacity:assemblyType.assembliesInstalled.count];
  NSArray* assembliesInstalled = [assemblyType.assembliesInstalled allObjects];
  for (Assembly* assembly in assembliesInstalled)
    {
    NSValue* key = [NSValue valueWithNonretainedObject:assembly.type];
    NSMutableArray* assemblies = [*assembliesGroupsDictionary objectForKey:key];
    if (assemblies.count)
      [assemblies addObject:assembly];
    else
      {
      assemblies = [[NSMutableArray alloc] initWithCapacity:1];
      [assemblies addObject:assembly];
      [*assembliesGroups addObject:key];
      [*assembliesGroupsDictionary setObject:assemblies forKey:key];
      }
    }
  }

+ (void)calculateInstalledDetailsGroupsForAssemblyType:(AssemblyType*)assemblyType intoArray:(NSMutableArray**)detailsGroups andDictionary:(NSMutableDictionary**)detailsGroupsDictionary
  {
  *detailsGroups = [[NSMutableArray alloc] initWithCapacity:assemblyType.detailsInstalled.count];
  *detailsGroupsDictionary = [[NSMutableDictionary alloc] initWithCapacity:assemblyType.detailsInstalled.count];
  NSArray* detailsInstalled = [assemblyType.detailsInstalled allObjects];
  for (Detail* detail in detailsInstalled)
    {
    NSValue* key = [NSValue valueWithNonretainedObject:detail.type];
    NSMutableArray* details = [*detailsGroupsDictionary objectForKey:key];
    if (details.count)
      [details addObject:detail];
    else
      {
      details = [[NSMutableArray alloc] initWithCapacity:1];
      [details addObject:detail];
      [*detailsGroups addObject:key];
      [*detailsGroupsDictionary setObject:details forKey:key];
      }
    }

  }

@end
