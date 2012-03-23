//
//  DetailType.h
//  Constructive
//
//  Created by Evgenii Bondarev on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DetailType : NSManagedObject

@property (nonatomic, retain) UIColor* color;
@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSNumber* length;
@property (nonatomic, retain) UIImage* picture;
@property (nonatomic, retain) UIImage* scalePicture;
@property (nonatomic, retain) NSValue* scalePictureSize;

@end
