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

@property (nonatomic, retain) UIColor*  color;
@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString* classIdentifier;
@property (nonatomic, retain) NSNumber* length;
@property (nonatomic, retain) UIImage*  picture;
@property (nonatomic, retain) UIImage*  picturePrepared;
//coordinates of (0,0) and (1,1) points of the modified picture in the original picture's coordinate system
@property (nonatomic, retain) NSNumber* preparedPicturePoint0_0X;
@property (nonatomic, retain) NSNumber* preparedPicturePoint0_0Y;
@property (nonatomic, retain) NSNumber* preparedPicturePoint1_1X;
@property (nonatomic, retain) NSNumber* preparedPicturePoint1_1Y;
@property (nonatomic, retain) NSNumber* pictureWidthInPins;
@property (nonatomic, retain) NSNumber* rulerImageRotationAngle;
@property (nonatomic, retain) NSNumber* rulerImageOffsetX;
@property (nonatomic, retain) NSNumber* rulerImageOffsetY;
@property (nonatomic, retain) NSNumber* rulerImageAnchorPointX;
@property (nonatomic, retain) NSNumber* rulerImageAnchorPointY;

//relations
@property (nonatomic, retain) NSSet*    details;
@end

@interface DetailType (CoreDataGeneratedAccessors)

- (UIImage*)pictureToShow;
- (void)addDetailsObject:(Detail *)value;
- (void)removeDetailsObject:(Detail *)value;
- (void)addDetails:(NSSet *)values;
- (void)removeDetails:(NSSet *)values;

@end
