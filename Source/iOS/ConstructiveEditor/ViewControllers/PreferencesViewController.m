//
//  PreferencesViewController.m
//  ConstructiveEditor


#import "PreferencesViewController.h"
#import "PreferenceOptionsViewController.h"
#import "PreferencesKeys.h"

@interface PreferencesViewController ()
  {
    __weak IBOutlet UISwitch* _preferredAskAboutImplicitPartsDeletionSwitch;
    __weak IBOutlet UILabel*  _preferredPicturesSourceLabel;
    __weak IBOutlet UILabel*  _standardActionOnAssemblyLabel;
    __weak IBOutlet UILabel*  _preferredActionOnReinterpretSplitAsDetachedLabel;
    __weak IBOutlet UILabel*  _preferredActionOnReinterpretSplitAsRotatedOrTransformedLabel;
    __weak IBOutlet UILabel*  _preferredActionOnReinterpretDetachedAsRotatedOrTransformedLabel;
    __weak IBOutlet UILabel*  _preferredActionOnReinterpretRotatedOrTransformedAsDetachedLabel;
    __weak IBOutlet UILabel*  _preferredActionOnReinterpretRotatedAsTransformedAndViceVersaLabel;
    __weak IBOutlet UILabel*  _preferredPaperSizeLabel;
    __weak IBOutlet UILabel*  _preferredPaperOrientationLabel;
  }
@end

@implementation PreferencesViewController

- (void)viewWillAppear:(BOOL)animated
  {
  NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
  
  BOOL askAboutImplicitPartsDeletion = preferredAskAboutImplicitPartsDeletion_Default;
  NSNumber* askAboutImplicitPartsDeletionNumber = [preferences objectForKey:preferredAskAboutImplicitPartsDeletion];
  if (askAboutImplicitPartsDeletionNumber)
    askAboutImplicitPartsDeletion = [askAboutImplicitPartsDeletionNumber boolValue];
    
  _preferredAskAboutImplicitPartsDeletionSwitch.on = askAboutImplicitPartsDeletion;
  
  NSString* preferredPicturesSourceStringValue = [preferences stringForKey:preferredPicturesSource];
  if ([preferredPicturesSourceStringValue isEqualToString:preferredPicturesSource_Camera])
    _preferredPicturesSourceLabel.text = NSLocalizedString(@"Camera", @"Table view label text");
  else if ([preferredPicturesSourceStringValue isEqualToString:preferredPicturesSource_PhotoLibrary])
    _preferredPicturesSourceLabel.text = NSLocalizedString(@"Photo library", @"Table view label text");
    
  NSString* standardActionOnAssemblyStringValue = [preferences stringForKey:standardActionOnAssembly];
  if ([standardActionOnAssemblyStringValue isEqualToString:standardActionOnAssembly_DetachSmallerParts])
    _standardActionOnAssemblyLabel.text = NSLocalizedString(@"Detach smaller parts", @"Table view label text");
  else if ([standardActionOnAssemblyStringValue isEqualToString:standardActionOnAssembly_SplitToDetails])
    _standardActionOnAssemblyLabel.text = NSLocalizedString(@"Split to details", @"Table view label text");
  else if ([standardActionOnAssemblyStringValue isEqualToString:standardActionOnAssembly_Rotate])
    _standardActionOnAssemblyLabel.text = NSLocalizedString(@"Rotate", @"Table view label text");
  else if ([standardActionOnAssemblyStringValue isEqualToString:standardActionOnAssembly_Transform])
    _standardActionOnAssemblyLabel.text = NSLocalizedString(@"Transform", @"Table view label text");
  
  NSString* preferredActionOnReinterpretSplitAsDetachedStringValue = [preferences stringForKey:preferredActionOnReinterpretSplitAsDetached];
  if ([preferredActionOnReinterpretSplitAsDetachedStringValue isEqualToString:preferredActionOnReinterpretSplitAsDetached_AskMe])
    _preferredActionOnReinterpretSplitAsDetachedLabel.text = NSLocalizedString(@"Ask me", @"Table view label text");
  else if ([preferredActionOnReinterpretSplitAsDetachedStringValue isEqualToString:preferredActionOnReinterpretSplitAsDetached_RemoveDetails])
    _preferredActionOnReinterpretSplitAsDetachedLabel.text = NSLocalizedString(@"Remove details", @"Table view label text");
  else if ([preferredActionOnReinterpretSplitAsDetachedStringValue isEqualToString:preferredActionOnReinterpretSplitAsDetached_SplitBaseAssembly])
    _preferredActionOnReinterpretSplitAsDetachedLabel.text = NSLocalizedString(@"Split base assembly to details", @"Table view label text");
  else if ([preferredActionOnReinterpretSplitAsDetachedStringValue isEqualToString:preferredActionOnReinterpretSplitAsDetached_UseDetailsAsDetachedParts])
    _preferredActionOnReinterpretSplitAsDetachedLabel.text = NSLocalizedString(@"Use details as detached parts", @"Table view label text");
    
  NSString* preferredActionOnReinterpretSplitAsRotatedOrTransformedStringValue = [preferences stringForKey:preferredActionOnReinterpretSplitAsRotatedOrTransformed];
  if ([preferredActionOnReinterpretSplitAsRotatedOrTransformedStringValue isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_AskMe])
    _preferredActionOnReinterpretSplitAsRotatedOrTransformedLabel.text = NSLocalizedString(@"Ask me", @"Table view label text");
  else if ([preferredActionOnReinterpretSplitAsRotatedOrTransformedStringValue isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_RemoveDetails])
    _preferredActionOnReinterpretSplitAsRotatedOrTransformedLabel.text = NSLocalizedString(@"Remove details", @"Table view label text");
  else if ([preferredActionOnReinterpretSplitAsRotatedOrTransformedStringValue isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_SplitAssemblyBeforeRotationOrTransformation])
    _preferredActionOnReinterpretSplitAsRotatedOrTransformedLabel.text = NSLocalizedString(@"Split new assembly", @"Table view label text");
    
  NSString* preferredActionOnReinterpretDetachedAsRotatedOrTransformedStringValue = [preferences stringForKey:preferredActionOnReinterpretDetachedAsRotatedOrTransformed];
  if ([preferredActionOnReinterpretDetachedAsRotatedOrTransformedStringValue isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_AskMe])
    _preferredActionOnReinterpretDetachedAsRotatedOrTransformedLabel.text = NSLocalizedString(@"Ask me", @"Table view label text");\
  else if ([preferredActionOnReinterpretDetachedAsRotatedOrTransformedStringValue isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_RemoveEverything])
    _preferredActionOnReinterpretDetachedAsRotatedOrTransformedLabel.text = NSLocalizedString(@"Remove detached parts", @"Table view label text");
  else if ([preferredActionOnReinterpretDetachedAsRotatedOrTransformedStringValue isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_DetachFromAssemblyBeforeRotationOrTransformation])
    _preferredActionOnReinterpretDetachedAsRotatedOrTransformedLabel.text = NSLocalizedString(@"Detach parts from new assembly", @"Table view label text");
  else if ([preferredActionOnReinterpretDetachedAsRotatedOrTransformedStringValue isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_UseBaseAssemblyAsAssemblyBeforeRotationOrTransformation])
    _preferredActionOnReinterpretDetachedAsRotatedOrTransformedLabel.text = NSLocalizedString(@"Use base as rotated/transformed", @"Table view label text");
    
  NSString* preferredActionOnReinterpretRotatedOrTransformedAsDetachedStringValue = [preferences stringForKey:preferredActionOnReinterpretRotatedOrTransformedAsDetached];
  if ([preferredActionOnReinterpretRotatedOrTransformedAsDetachedStringValue isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_AskMe])
    _preferredActionOnReinterpretRotatedOrTransformedAsDetachedLabel.text = NSLocalizedString(@"Ask me", @"Table view label text");
  else if ([preferredActionOnReinterpretRotatedOrTransformedAsDetachedStringValue isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_RemoveRotatedOrTransformedAssembly])
    _preferredActionOnReinterpretRotatedOrTransformedAsDetachedLabel.text = NSLocalizedString(@"Remove rotated/transformed assembly", @"Table view label text");
  else if ([preferredActionOnReinterpretRotatedOrTransformedAsDetachedStringValue isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_UseAssemblyBeforeRotationOrTransformationAsBase])
    _preferredActionOnReinterpretRotatedOrTransformedAsDetachedLabel.text = NSLocalizedString(@"Use rotated/transformed as base", @"Table view label text");
  else if ([preferredActionOnReinterpretRotatedOrTransformedAsDetachedStringValue isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_RotateOrTransformBaseAssembly])
    _preferredActionOnReinterpretRotatedOrTransformedAsDetachedLabel.text = NSLocalizedString(@"Rotate/transform base assembly", @"Table view label text");
    
  NSString* preferredActionOnReinterpretRotatedAsTransformedAndViceVersaStringValue = [preferences stringForKey:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa];
  if ([preferredActionOnReinterpretRotatedAsTransformedAndViceVersaStringValue isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_AskMe])
    _preferredActionOnReinterpretRotatedAsTransformedAndViceVersaLabel.text = NSLocalizedString(@"Ask me", @"Table view label text");
  else if ([preferredActionOnReinterpretRotatedAsTransformedAndViceVersaStringValue isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_UseRotatedOrTransformedAssemblyAsTransformedOrRotated])
    _preferredActionOnReinterpretRotatedAsTransformedAndViceVersaLabel.text = NSLocalizedString(@"Use rotated <-> transformed", @"Table view label text");
  else if ([preferredActionOnReinterpretRotatedAsTransformedAndViceVersaStringValue isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_RemoveRotatedOrTransformedAssembly])
    _preferredActionOnReinterpretRotatedAsTransformedAndViceVersaLabel.text = NSLocalizedString(@"Remove rotated/transformed", @"Table view label text");
  else if ([preferredActionOnReinterpretRotatedAsTransformedAndViceVersaStringValue isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_TransformeOrRotateRotatedOrTransformedAssembly])
    _preferredActionOnReinterpretRotatedAsTransformedAndViceVersaLabel.text = NSLocalizedString(@"Transform rotated and vice versa", @"Table view label text");
    
  NSString* preferredPaperSizeStringValue = [preferences stringForKey:preferredPaperSize];
  if ([preferredPaperSizeStringValue isEqualToString:preferredPaperSize_A4])
    _preferredPaperSizeLabel.text = NSLocalizedString(@"A4", @"Table view label text");
  else if ([preferredPaperSizeStringValue isEqualToString:preferredPaperSize_A3])
    _preferredPaperSizeLabel.text = NSLocalizedString(@"A3", @"Table view label text");
    
  NSString* preferredPaperOrientationStringValue = [preferences stringForKey:preferredPaperOrientation];
  if ([preferredPaperOrientationStringValue isEqualToString:preferredPaperOrientation_Portrait])
    _preferredPaperOrientationLabel.text = NSLocalizedString(@"Portrait", @"Table view label text");
  else if ([preferredPaperOrientationStringValue isEqualToString:preferredPaperOrientation_Landscape])
    _preferredPaperOrientationLabel.text = NSLocalizedString(@"Landscape", @"Table view label text");
  }
  
- (IBAction)onAskAboutImplicitPartsDeletionChanged:(id)sender
  {
  [[NSUserDefaults standardUserDefaults] setBool:_preferredAskAboutImplicitPartsDeletionSwitch.on forKey:preferredAskAboutImplicitPartsDeletion];
  }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  PreferenceOptionsViewController* preferenceOptionsViewController = (PreferenceOptionsViewController*)segue.destinationViewController;
  preferenceOptionsViewController.preferenceKey = segue.identifier;
  }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
  {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  }

@end
