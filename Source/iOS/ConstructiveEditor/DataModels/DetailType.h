//
//  DetailType.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Detail;

@interface DetailType : NSManagedObject

@property (nonatomic, retain) UIColor* color;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) UIImage* picture;
@property (nonatomic, retain) UIImage* picturePrepared;
@property (nonatomic, retain) UIImage* scalePicture;
@property (nonatomic, retain) NSValue* scalePictureSize;
@property (nonatomic, retain) NSSet *details;
@end

@interface DetailType (CoreDataGeneratedAccessors)

- (UIImage*)pictureToShow;
- (void)addDetailsObject:(Detail *)value;
- (void)removeDetailsObject:(Detail *)value;
- (void)addDetails:(NSSet *)values;
- (void)removeDetails:(NSSet *)values;

@end
