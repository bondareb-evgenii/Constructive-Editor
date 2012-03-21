//
//  DetailType.h
//  CoreDataTest1
//
//  Created by Evgenii Bondarev on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DetailType : NSManagedObject

@property (nonatomic, strong) UIImage*  picture;
@property (nonatomic, strong) NSString* identifier;
@property (nonatomic, strong) NSNumber* length;
@property (nonatomic, strong) UIColor*  color;
@property (nonatomic, strong) UIImage*  scalePicture;
@property (nonatomic, strong) NSValue*  scalePictureSize;

@end
