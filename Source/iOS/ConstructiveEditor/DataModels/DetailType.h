//
//  DetailType.h
//  ConstructiveEditor
//
//  Created by Evgenii Bondarev on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Detail;

@interface DetailType : NSManagedObject

@property (nonatomic, retain) UIColor* color;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) UIImage* picture;
@property (nonatomic, retain) UIImage* scalePicture;
@property (nonatomic, retain) NSValue* scalePictureSize;
@property (nonatomic, retain) NSSet *details;
@end

@interface DetailType (CoreDataGeneratedAccessors)

- (void)addDetailsObject:(Detail *)value;
- (void)removeDetailsObject:(Detail *)value;
- (void)addDetails:(NSSet *)values;
- (void)removeDetails:(NSSet *)values;

@end
