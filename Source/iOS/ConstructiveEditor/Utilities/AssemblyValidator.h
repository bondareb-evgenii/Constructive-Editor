//
//  AssemblyValidator.h
//  ConstructiveEditor


#import <Foundation/Foundation.h>

typedef enum
  {
  kModelValidationErrorCodeOK = 0,
  kModelValidationErrorCodeAssemblyNotBrokenUp,//model can still be exported
  kModelValidationErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously,
  kModelValidationErrorCodeLessThenTwoDetailsInSplitAssembly,
  kModelValidationErrorCodeNoPartsDetachedFromAssembly,
  kModelValidationErrorCodeDetailHasNoConnectionPoint,
  kModelValidationErrorCodeSubassemblyHasNoConnectionPoint,
  } ModelValidationErrorCode;

@class Assembly;

typedef void (^PreviewInstructionBlock)(Assembly* assembly);

@interface AssemblyValidator : NSObject

+ (Assembly*)rootAssemblyInContext:(NSManagedObjectContext*)context;
+ (BOOL)isAssemblyComplete:(Assembly*)assemblyToCheck withError:(NSError**)error;
+ (void)showExportMenuForRootAssembly:(Assembly*)rootAssembly inView:(UIView *)view previewInstructionBlock:(PreviewInstructionBlock)previewInstructionBlock;

@end
