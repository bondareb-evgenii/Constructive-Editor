//
//  ReinterpretActionHandler.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Assembly;

@interface ReinterpretActionHandler : NSObject

+ (void)performStandardActionNamed:(NSString*)standardActionName onAssembly:(Assembly*)assembly inView:(UIView*)view withCompletionBlock:(void(^)(BOOL actionPerformed)) completion;

@end
