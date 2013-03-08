//
//  DetailType.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "DetailType.h"
#import "Detail.h"


@implementation DetailType

@dynamic color;
@dynamic identifier;
@dynamic classIdentifier;
@dynamic length;
@dynamic picture;
@dynamic picturePrepared;
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
  if (self.picturePrepared)
    return self.picturePrepared;
  return self.picture;
  }

@end
