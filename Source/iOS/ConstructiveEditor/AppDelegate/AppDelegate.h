//
//  AppDelegate.h
//  ConstructiveEditor


#import <UIKit/UIKit.h>

@class StartMenuViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) StartMenuViewController* startMenuViewController;

- (NSString *)applicationDocumentsDirectory;
- (void)closeCurrentDocument;

@end
