//
//  UIImageToDataTransformer.m
//  Constructive
//
//  Created by Evgenii Bondarev on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImageToDataTransformer.h"

@implementation UIImageToDataTransformer

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
	return UIImagePNGRepresentation(value);
  }

- (id)reverseTransformedValue:(id)value
  {
	return [[UIImage alloc] initWithData:value];
  }

@end
