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
@dynamic length;
@dynamic picture;
@dynamic picturePrepared;
@dynamic scalePicture;
@dynamic scalePictureSize;
@dynamic details;

- (UIImage*)pictureToShow
  {
  if (self.picturePrepared)
    return self.picturePrepared;
  return self.picture;
  }

@end
