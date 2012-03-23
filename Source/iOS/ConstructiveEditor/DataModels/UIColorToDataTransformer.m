//
//  UIColorToDataTransformer.m
//  Constructive
//
//  Created by Evgenii Bondarev on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIColorToDataTransformer.h"

@implementation UIColorToDataTransformer

+ (BOOL)allowsReverseTransformation
  {
	return YES;
  }

+ (Class)transformedValueClass
  {
	return [NSData class];
  }

- (id)transformedValue:(id)value
  {
	return [NSKeyedArchiver archivedDataWithRootObject:value];
  }

- (id)reverseTransformedValue:(id)value
  {
	return [NSKeyedUnarchiver unarchiveObjectWithData:value];
  }

@end
