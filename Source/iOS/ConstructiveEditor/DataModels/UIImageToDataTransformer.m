//
//  UIImageToDataTransformer.m
//  ConstructiveEditor


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
	return UIImageJPEGRepresentation(value, 1);//best quality, least compression
  }

- (id)reverseTransformedValue:(id)value
  {
	return [UIImage imageWithData:(NSData *)value];
  }

@end
