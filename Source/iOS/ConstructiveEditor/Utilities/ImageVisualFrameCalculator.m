//
//  ImageVisualFrameCalculator.m
//  ConstructiveEditor
//
//  Created by 007 on 2/7/13.
//
//

#import "ImageVisualFrameCalculator.h"

@implementation ImageVisualFrameCalculator

- (id)initWithImageView:(UIImageView*)imageView
  {
  self = [super init];
  if (self)
    {
    _imageView = imageView;
    }
  return self;
  }

- (CGRect)imageVisualFrameInViewCoordinates
  {
  NSParameterAssert(UIViewContentModeScaleAspectFit == self.imageView.contentMode);
  
  /*
  typedef enum {
   UIViewContentModeScaleToFill,
   UIViewContentModeScaleAspectFit,
   UIViewContentModeScaleAspectFill,
   UIViewContentModeRedraw,
   UIViewContentModeCenter,
   UIViewContentModeTop,
   UIViewContentModeBottom,
   UIViewContentModeLeft,
   UIViewContentModeRight,
   UIViewContentModeTopLeft,
   UIViewContentModeTopRight,
   UIViewContentModeBottomLeft,
   UIViewContentModeBottomRight,
} UIViewContentMode;

*/
  CGSize viewSize = self.imageView.frame.size;
  CGSize imageSize = self.imageView.image.size;
  switch (self.imageView.contentMode)
    {
//    case UIViewContentModeScaleAspectFit:
//      break;

    default:
      {
      float viewRelationW2H = viewSize.width /viewSize.height;
      float imageRelationW2H = imageSize.width/imageSize.height;
      if (imageRelationW2H > viewRelationW2H)//image takes entire view width
        {
        float visibleImageHeight = imageSize.height*viewSize.width/imageSize.width;
        return CGRectMake(0, (viewSize.height - visibleImageHeight)/2, viewSize.width, visibleImageHeight);
        }
      else
        {
        float visibleImageWidth = imageSize.width*viewSize.height/imageSize.height;
        return CGRectMake((viewSize.width - visibleImageWidth)/2, 0, visibleImageWidth, viewSize.height);
        }
      }
      break;
    }//switch
  }

@end
