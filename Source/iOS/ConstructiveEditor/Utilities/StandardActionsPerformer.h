//
//  StandardActionsPerformer.h
//  ConstructiveEditor


#import <Foundation/Foundation.h>

@class AssemblyType;

@interface StandardActionsPerformer : NSObject

+ (void)performStandardActionNamed:(NSString*)standardActionName onAssemblyType:(AssemblyType*)assemblyTypeToInterpret inView:(UIView*)view withCompletionBlock:(void(^)(BOOL actionPerformed)) completion;

@end
