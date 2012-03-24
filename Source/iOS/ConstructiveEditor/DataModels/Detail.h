//
//  Detail.h
//  Constructive
//
//  Created by Evgenii Bondarev on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Assembly, DetailType;

@interface Detail : NSManagedObject

@property (nonatomic, retain) NSValue* connectionPoint;
@property (nonatomic, retain) Assembly *assemblyToInstallTo;
@property (nonatomic, retain) DetailType *type;

@end
