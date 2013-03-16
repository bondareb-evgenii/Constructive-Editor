//
//  PreferenceOptionsViewController.m
//  ConstructiveEditor


#import "PreferenceOptionsViewController.h"
#import "PreferencesKeys.h"

@interface PreferenceOptionsViewController ()

@end

@implementation PreferenceOptionsViewController

- (NSIndexPath*)indexPathByPreferenceStringValue:(NSString*)preferenceStringValue
  {
  if ([self.preferenceKey isEqualToString:preferredPicturesSource])
    {
    if ([preferenceStringValue isEqualToString:preferredPicturesSource_Camera])
      return [NSIndexPath indexPathForRow:0 inSection:0];
    if ([preferenceStringValue isEqualToString:preferredPicturesSource_PhotoLibrary])
      return [NSIndexPath indexPathForRow:1 inSection:0];
    }
  else if ([self.preferenceKey isEqualToString:preferredActionOnReinterpretSplitAsDetached])
    {
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretSplitAsDetached_AskMe])
      return [NSIndexPath indexPathForRow:0 inSection:0];
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretSplitAsDetached_RemoveDetails])
      return [NSIndexPath indexPathForRow:1 inSection:0];
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretSplitAsDetached_SplitBaseAssembly])
      return [NSIndexPath indexPathForRow:2 inSection:0];
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretSplitAsDetached_UseDetailsAsDetachedParts])
      return [NSIndexPath indexPathForRow:3 inSection:0];
    }
  else if ([self.preferenceKey isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed])
    {
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_AskMe])
      return [NSIndexPath indexPathForRow:0 inSection:0];
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_RemoveDetails])
      return [NSIndexPath indexPathForRow:1 inSection:0];
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_SplitAssemblyBeforeRotationOrTransformation])
      return [NSIndexPath indexPathForRow:2 inSection:0];
    }
  else if ([self.preferenceKey isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed])
    {
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_AskMe])
      return [NSIndexPath indexPathForRow:0 inSection:0];
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_RemoveEverything])
      return [NSIndexPath indexPathForRow:1 inSection:0];
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_DetachFromAssemblyBeforeRotationOrTransformation])
      return [NSIndexPath indexPathForRow:2 inSection:0];
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_UseBaseAssemblyAsAssemblyBeforeRotationOrTransformation])
      return [NSIndexPath indexPathForRow:3 inSection:0];
    }
  else if ([self.preferenceKey isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached])
    {
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_AskMe])
      return [NSIndexPath indexPathForRow:0 inSection:0];
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_RemoveRotatedOrTransformedAssembly])
      return [NSIndexPath indexPathForRow:1 inSection:0];
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_RotateOrTransformBaseAssembly])
      return [NSIndexPath indexPathForRow:2 inSection:0];
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_UseAssemblyBeforeRotationOrTransformationAsBase])
      return [NSIndexPath indexPathForRow:3 inSection:0];
    }
  else if ([self.preferenceKey isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa])
    {
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_AskMe])
      return [NSIndexPath indexPathForRow:0 inSection:0];
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_RemoveRotatedOrTransformedAssembly])
      return [NSIndexPath indexPathForRow:1 inSection:0];
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_TransformeOrRotateRotatedOrTransformedAssembly])
      return [NSIndexPath indexPathForRow:2 inSection:0];
    if ([preferenceStringValue isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_UseRotatedOrTransformedAssemblyAsTransformedOrRotated])
      return [NSIndexPath indexPathForRow:3 inSection:0];
    }
  else if ([self.preferenceKey isEqualToString:standardActionOnAssembly])
    {
    if ([preferenceStringValue isEqualToString:standardActionOnAssembly_DetachSmallerParts])
      return [NSIndexPath indexPathForRow:0 inSection:0];
    if ([preferenceStringValue isEqualToString:standardActionOnAssembly_SplitToDetails])
      return [NSIndexPath indexPathForRow:1 inSection:0];
    if ([preferenceStringValue isEqualToString:standardActionOnAssembly_Rotate])
      return [NSIndexPath indexPathForRow:2 inSection:0];
    if ([preferenceStringValue isEqualToString:standardActionOnAssembly_Transform])
      return [NSIndexPath indexPathForRow:3 inSection:0];
    }
  return nil;
  }

- (NSString*)preferenceStringValueByIndexPath:(NSIndexPath*)indexPath
  {
  NSInteger row = indexPath.row;
  if ([self.preferenceKey isEqualToString:preferredPicturesSource])
    {
    switch (row)
      {
      case 0:
        return preferredPicturesSource_Camera;
        break;
      default://1
        return preferredPicturesSource_PhotoLibrary;
        break;
      }
    }
  else if ([self.preferenceKey isEqualToString:preferredActionOnReinterpretSplitAsDetached])
    {
    switch (row)
      {
      case 0:
        return preferredActionOnReinterpretSplitAsDetached_AskMe;
        break;
      case 1:
        return preferredActionOnReinterpretSplitAsDetached_RemoveDetails;
        break;
      case 2:
        return preferredActionOnReinterpretSplitAsDetached_SplitBaseAssembly;
        break;
      default://3
        return preferredActionOnReinterpretSplitAsDetached_UseDetailsAsDetachedParts;
        break;
      }
    }
  else if ([self.preferenceKey isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed])
    {
    switch (row)
      {
      case 0:
        return preferredActionOnReinterpretSplitAsRotatedOrTransformed_AskMe;
        break;
      case 1:
        return preferredActionOnReinterpretSplitAsRotatedOrTransformed_RemoveDetails;
        break;
      default://3
        return preferredActionOnReinterpretSplitAsRotatedOrTransformed_SplitAssemblyBeforeRotationOrTransformation;
        break;
      }
    }
  else if ([self.preferenceKey isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed])
    {
    switch (row)
      {
      case 0:
        return preferredActionOnReinterpretDetachedAsRotatedOrTransformed_AskMe;
        break;
      case 1:
        return preferredActionOnReinterpretDetachedAsRotatedOrTransformed_RemoveEverything;
        break;
      case 2:
        return preferredActionOnReinterpretDetachedAsRotatedOrTransformed_DetachFromAssemblyBeforeRotationOrTransformation;
        break;
      default://3
        return preferredActionOnReinterpretDetachedAsRotatedOrTransformed_UseBaseAssemblyAsAssemblyBeforeRotationOrTransformation;
        break;
      }
    }
  else if ([self.preferenceKey isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached])
    {
    switch (row)
      {
      case 0:
        return preferredActionOnReinterpretRotatedOrTransformedAsDetached_AskMe;
        break;
      case 1:
        return preferredActionOnReinterpretRotatedOrTransformedAsDetached_RemoveRotatedOrTransformedAssembly;
        break;
      case 2:
        return preferredActionOnReinterpretRotatedOrTransformedAsDetached_RotateOrTransformBaseAssembly;
        break;
      default://3
        return preferredActionOnReinterpretRotatedOrTransformedAsDetached_UseAssemblyBeforeRotationOrTransformationAsBase;
        break;
      }
    }
  else if ([self.preferenceKey isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa])
    {
    switch (row)
      {
      case 0:
        return preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_AskMe;
        break;
      case 1:
        return preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_RemoveRotatedOrTransformedAssembly;
        break;
      case 2:
        return preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_TransformeOrRotateRotatedOrTransformedAssembly;
        break;
      default://3
        return preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_UseRotatedOrTransformedAssemblyAsTransformedOrRotated;
        break;
      }
    }
  else if ([self.preferenceKey isEqualToString:standardActionOnAssembly])
    {
    switch (row)
      {
      case 0:
        return standardActionOnAssembly_DetachSmallerParts;
        break;
      case 1:
        return standardActionOnAssembly_SplitToDetails;
        break;
      case 2:
        return standardActionOnAssembly_Rotate;
        break;
      default://3
        return standardActionOnAssembly_Transform;
        break;
      }
    }
  return nil;
  }

- (void)selectCellForCurrentPreferenceValue
  {
  NSInteger selectedRow = [self indexPathByPreferenceStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:self.preferenceKey]].row;
  NSInteger rowsCount = [self.tableView numberOfRowsInSection:0];
  for (int i = 0; i < rowsCount; ++i)
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]].accessoryType =
        i != selectedRow ? UITableViewCellAccessoryNone
                         : UITableViewCellAccessoryCheckmark;
  }

- (void)setPreferenceKey:(NSString *)preferenceKey
  {
  _preferenceKey = preferenceKey;
  [self selectCellForCurrentPreferenceValue];
  }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
  {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  [[NSUserDefaults standardUserDefaults] setObject:[self preferenceStringValueByIndexPath:indexPath] forKey:self.preferenceKey];
  [self selectCellForCurrentPreferenceValue];
  }

@end
