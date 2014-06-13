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

typedef enum
  {
  kExportFileFormatPDF
  } ExportFileFormat;

@class Assembly;
@class AssemblyType;
@class InstructionStep;

typedef void (^PreviewInstructionBlock)(Assembly* assembly, ExportFileFormat exportFileFormat, NSArray* steps);

@interface AssemblyValidator : NSObject

+ (Assembly*)rootAssemblyInContext:(NSManagedObjectContext*)context;
+ (BOOL)canDisassemble:(Assembly*)assemblyToCheck withError:(NSError**)error andSteps:(NSMutableArray*)steps;
+ (void)showExportMenuForRootAssembly:(Assembly*)rootAssembly inView:(UIView *)view previewInstructionBlock:(PreviewInstructionBlock)previewInstructionBlock;
+ (void)calculateInstalledAssembliesGroupsForAssemblyType:(AssemblyType*)assemblyType intoArray:(NSMutableArray**)assembliesGroups andDictionary:(NSMutableDictionary**)assembliesGroupsDictionary;
+ (void)calculateInstalledDetailsGroupsForAssemblyType:(AssemblyType*)assemblyType intoArray:(NSMutableArray**)detailsGroups andDictionary:(NSMutableDictionary**)detailsGroupsDictionary;

@end
