//
//  StandardActionsPerformer.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AssemblyType;

@interface StandardActionsPerformer : NSObject

+ (void)performStandardActionNamed:(NSString*)standardActionName onAssemblyType:(AssemblyType*)assemblyTypeToInterpret inView:(UIView*)view withCompletionBlock:(void(^)(BOOL actionPerformed)) completion;

@end
