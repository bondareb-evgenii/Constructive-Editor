//
//  ReinterpretActionHandler.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Assembly;

@interface ReinterpretActionHandler : NSObject

@property (nonatomic, readonly) Assembly* assembly;

- (id)initWithViewController:(UIViewController*)viewController andSegueToNextViewControllerName:(NSString*)segueName;

- (void)interpretAssembly:(Assembly*)assembly;
- (void)reinterpretAssembly:(Assembly*)assembly;

@end
