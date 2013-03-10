//
//  Picture.h
//  ConstructiveEditor

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AssemblyType, DetailType;

@interface Picture : NSManagedObject

@property (nonatomic, retain) UIImage*      image;

@end
