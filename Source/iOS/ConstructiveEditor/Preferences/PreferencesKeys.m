//
//  PreferencesKeys.m
//  ConstructiveEditor


NSString* const preferredAskAboutImplicitPartsDeletion = @"preferredAskAboutImplicitPartsDeletion";
  BOOL const preferredAskAboutImplicitPartsDeletion_Default = YES;
NSString* const preferredPicturesSource = @"preferredPicturesSource";
  NSString* const preferredPicturesSource_Camera = @"preferredPicturesSource_Camera";
  NSString* const preferredPicturesSource_PhotoLibrary = @"preferredPicturesSource_PhotoLibrary";
NSString* const preferredActionOnReinterpretSplitAsDetached = @"preferredActionOnReinterpretSplitAsDetached";
  NSString* const preferredActionOnReinterpretSplitAsDetached_AskMe = @"preferredActionOnReinterpretSplitAsDetached_AskMe";
  NSString* const preferredActionOnReinterpretSplitAsDetached_RemoveDetails = @"preferredActionOnReinterpretSplitAsDetached_RemoveDetails";
  NSString* const preferredActionOnReinterpretSplitAsDetached_SplitBaseAssembly = @"preferredActionOnReinterpretSplitAsDetached_SplitBaseAssembly";
  NSString* const preferredActionOnReinterpretSplitAsDetached_UseDetailsAsDetachedParts = @"preferredActionOnReinterpretSplitAsDetached_UseDetailsAsDetachedParts";
  NSString* const preferredActionOnReinterpretSplitAsDetached_Default = @"preferredActionOnReinterpretSplitAsDetached_AskMe";
NSString* const preferredActionOnReinterpretSplitAsRotatedOrTransformed = @"preferredActionOnReinterpretSplitAsRotatedOrTransformed";
  NSString* const preferredActionOnReinterpretSplitAsRotatedOrTransformed_AskMe = @"preferredActionOnReinterpretSplitAsRotatedOrTransformed_AskMe";
  NSString* const preferredActionOnReinterpretSplitAsRotatedOrTransformed_RemoveDetails = @"preferredActionOnReinterpretSplitAsRotatedOrTransformed_RemoveDetails";
  NSString* const preferredActionOnReinterpretSplitAsRotatedOrTransformed_SplitAssemblyBeforeRotationOrTransformation = @"preferredActionOnReinterpretSplitAsRotatedOrTransformed_SplitAssemblyBeforeRotationOrTransformation";
  NSString* const preferredActionOnReinterpretSplitAsRotatedOrTransformed_Default = @"preferredActionOnReinterpretSplitAsRotatedOrTransformed_AskMe";
NSString* const preferredActionOnReinterpretDetachedAsRotatedOrTransformed = @"preferredActionOnReinterpretDetachedAsRotatedOrTransformed";
  NSString* const preferredActionOnReinterpretDetachedAsRotatedOrTransformed_AskMe = @"preferredActionOnReinterpretDetachedAsRotatedOrTransformed_AskMe";
  NSString* const preferredActionOnReinterpretDetachedAsRotatedOrTransformed_RemoveEverything = @"preferredActionOnReinterpretDetachedAsRotatedOrTransformed_RemoveEverything";
  NSString* const preferredActionOnReinterpretDetachedAsRotatedOrTransformed_DetachFromAssemblyBeforeRotationOrTransformation = @"preferredActionOnReinterpretDetachedAsRotatedOrTransformed_DetachFromAssemblyBeforeRotationOrTransformation";
  NSString* const preferredActionOnReinterpretDetachedAsRotatedOrTransformed_UseBaseAssemblyAsAssemblyBeforeRotationOrTransformation = @"preferredActionOnReinterpretDetachedAsRotatedOrTransformed_UseBaseAssemblyAsAssemblyBeforeRotationOrTransformation";
  NSString* const preferredActionOnReinterpretDetachedAsRotatedOrTransformed_Default = @"preferredActionOnReinterpretDetachedAsRotatedOrTransformed_AskMe";
NSString* const preferredActionOnReinterpretRotatedOrTransformedAsDetached = @"preferredActionOnReinterpretRotatedOrTransformedAsDetached";
  NSString* const preferredActionOnReinterpretRotatedOrTransformedAsDetached_AskMe = @"preferredActionOnReinterpretRotatedOrTransformedAsDetached_AskMe";
  NSString* const preferredActionOnReinterpretRotatedOrTransformedAsDetached_UseAssemblyBeforeRotationOrTransformationAsBase = @"preferredActionOnReinterpretRotatedOrTransformedAsDetached_UseAssemblyBeforeRotationOrTransformationAsBase";
  NSString* const preferredActionOnReinterpretRotatedOrTransformedAsDetached_RotateOrTransformBaseAssembly = @"preferredActionOnReinterpretRotatedOrTransformedAsDetached_RotateOrTransformBaseAssembly";
  NSString* const preferredActionOnReinterpretRotatedOrTransformedAsDetached_RemoveRotatedOrTransformedAssembly = @"preferredActionOnReinterpretRotatedOrTransformedAsDetached_RemoveRotatedOrTransformedAssembly";
  NSString* const preferredActionOnReinterpretRotatedOrTransformedAsDetached_Default = @"preferredActionOnReinterpretRotatedOrTransformedAsDetached_AskMe";
NSString* const preferredActionOnReinterpretRotatedAsTransformedAndViceVersa = @"preferredActionOnReinterpretRotatedAsTransformedAndViceVersa";
  NSString* const preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_AskMe = @"preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_AskMe";
  NSString* const preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_UseRotatedOrTransformedAssemblyAsTransformedOrRotated = @"preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_UseRotatedOrTransformedAssemblyAsTransformedOrRotated";
  NSString* const preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_TransformeOrRotateRotatedOrTransformedAssembly = @"preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_TransformeOrRotateRotatedOrTransformedAssembly";
  NSString* const preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_RemoveRotatedOrTransformedAssembly = @"preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_RemoveRotatedOrTransformedAssembly";
  NSString* const preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_Default = @"preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_AskMe";
NSString* const standardActionOnAssembly = @"standardActionOnAssembly";
  NSString* const standardActionOnAssembly_SplitToDetails = @"standardActionOnAssembly_SplitToDetails";
  NSString* const standardActionOnAssembly_DetachSmallerParts = @"standardActionOnAssembly_DetachSmallerParts";
  NSString* const standardActionOnAssembly_Rotate = @"standardActionOnAssembly_Rotate";
  NSString* const standardActionOnAssembly_Transform = @"standardActionOnAssembly_Transform";
  NSString* const standardActionOnAssembly_Default = @"standardActionOnAssembly_DetachSmallerParts";
NSString* const preferredPaperSize = @"preferredPaperSize";
  NSString* const preferredPaperSize_A4 = @"preferredPaperSize_A4";
  NSString* const preferredPaperSize_A3 = @"preferredPaperSize_A3";
  NSString* const preferredPaperSize_Default = @"preferredPaperSize_A4";
NSString* const preferredPaperOrientation = @"preferredPaperOrientation";
  NSString* const preferredPaperOrientation_Portrait = @"preferredPaperOrientation_Portrait";
  NSString* const preferredPaperOrientation_Landscape = @"preferredPaperOrientation_Landscape";
  NSString* const preferredPaperOrientation_Default = @"preferredPaperOrientation_Portrait";
NSString* const averageDetailAddedVolumeInCubicPins = @"averageDetailAddedVolumeInCubicPins";
  float const averageDetailAddedVolumeInCubicPinsDefault = 6.3;//default is 6.3: float value between [1;10]
