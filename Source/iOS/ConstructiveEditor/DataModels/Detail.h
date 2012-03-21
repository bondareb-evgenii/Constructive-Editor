//
//  Detail.h
//  CoreDataTest1
//
//  Created by Evgenii Bondarev on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DetailType;

@interface Detail : NSManagedObject

@property (nonatomic, strong) DetailType *type;

@end
