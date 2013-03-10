//
//  DetailType.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "DetailType.h"
#import "Detail.h"
#import "Picture.h"


@implementation DetailType

@dynamic color;
@dynamic identifier;
@dynamic classIdentifier;
@dynamic length;
@dynamic picture;
@dynamic pictureThumbnail60x60AspectFit;
@dynamic picturePrepared;
@dynamic picturePreparedThumbnail60x60AspectFit;
@dynamic preparedPicturePoint0_0X;
@dynamic preparedPicturePoint0_0Y;
@dynamic preparedPicturePoint1_1X;
@dynamic preparedPicturePoint1_1Y;
@dynamic pictureWidthInPins;
@dynamic rulerImageRotationAngle;
@dynamic rulerImageOffsetX;
@dynamic rulerImageOffsetY;
@dynamic rulerImageAnchorPointX;
@dynamic rulerImageAnchorPointY;
@dynamic details;

- (UIImage*)pictureToShow
  {
  if (self.picturePrepared.image)
    return self.picturePrepared.image;
  return self.picture.image;
  }

- (UIImage*)pictureToShowThumbnail60x60AspectFit
  {
  if (self.picturePreparedThumbnail60x60AspectFit.image)
    return self.picturePreparedThumbnail60x60AspectFit.image;
  return self.pictureThumbnail60x60AspectFit.image;
  }

@end
