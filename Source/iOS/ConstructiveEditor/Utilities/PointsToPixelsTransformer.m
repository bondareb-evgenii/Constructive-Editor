//
//  PointsToPixelsTransformer.m
//  ConstructiveEditor

#import "PointsToPixelsTransformer.h"

@implementation PointsToPixelsTransformer

+ (CGSize)sizeInPixelsOnMainScreenForSize:(CGSize)size
  {
  CGFloat screenScale = [[UIScreen mainScreen] scale];
  return CGSizeMake(size.width*screenScale, size.height*screenScale);
  }

@end
