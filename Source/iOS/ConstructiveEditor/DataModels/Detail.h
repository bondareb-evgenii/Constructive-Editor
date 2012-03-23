//
//  Detail.h
//  Constructive
//
//  Created by Evgenii Bondarev on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Assembly, DetailType;

@interface Detail : NSManagedObject

@property (nonatomic, retain) NSValue* connectionPoint;
@property (nonatomic, retain) DetailType* type;
@property (nonatomic, retain) Assembly* parent;

@end
