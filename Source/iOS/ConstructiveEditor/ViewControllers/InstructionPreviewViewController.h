//
//  InstructionPreviewViewController.h
//  ConstructiveEditor


#import <UIKit/UIKit.h>

@class Assembly;

@interface InstructionPreviewViewController : UICollectionViewController

@property (nonatomic, weak) Assembly* assembly;

@end
