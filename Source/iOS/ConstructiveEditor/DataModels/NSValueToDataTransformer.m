//
//  CGSizeToDataTransformer.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "NSValueToDataTransformer.h"

@implementation CGSizeToDataTransformer

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
