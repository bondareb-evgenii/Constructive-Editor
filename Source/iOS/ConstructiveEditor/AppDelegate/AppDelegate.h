//
//  AppDelegate.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StartMenuViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) StartMenuViewController* startMenuViewController;

- (NSString *)applicationDocumentsDirectory;
- (void)closeCurrentDocument;

@end
