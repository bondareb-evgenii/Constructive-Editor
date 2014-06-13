//
//  DetailType.m
//  ConstructiveEditor


#import "DetailType.h"
#import "Detail.h"
#import "Constants.h"
#import "Picture.h"
#import "PreferencesKeys.h"

@implementation DetailType

@dynamic color;
@dynamic identifier;
@dynamic classIdentifier;
@dynamic length;
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

@synthesize addedVolumeInCubicPins = _addedVolumeInCubicPins;

- (NSNumber*)addedVolumeInCubicPins
  {
  if (!_addedVolumeInCubicPins)
    _addedVolumeInCubicPins = [NSNumber numberWithFloat:[self calculateAddedVolumeInCubicPins]];
  return _addedVolumeInCubicPins;
  }

- (float)calculateAddedVolumeInCubicPins//Actual volume added to the assembly by this detail type can be bigger or smaller, it will also deviate for the same detail type inside of different assemblies, but we cannot calculate exact value based on pictures only, so let's estimate it by some heuristics
  {
  if (self.classIdentifier)//axes, liftarms and bricks should have lengths set in order to create 1:1 picture for them, so let's use it
    {
    float length = self.length.floatValue;
    if (NSOrderedSame == [self.classIdentifier compare:detailClassTechnicAxle])
      return length >= 4 ? length / 2 : 0;//estimation for long axes (short axes are usually inserted into other datails so they don't add volume to assembly, while long ones are used to make assembly longer and add volume to it
    if ( NSOrderedSame == [self.classIdentifier compare:detailClassTechnicLiftarm] ||
              NSOrderedSame == [self.classIdentifier compare:detailClassTechnicBrick])
      return length*length*length/12;//estimation for liftarms ans bricks: 3D structures are usually created from such details so let's imagine a cube of 12 details like that at edges and take their volume as an arithmetic mean
    return 0;
    }

  if (self.pictureWidthInPins)//user may use the ruller to set actual detail size for details different from average, let's guess it is flat and takes entire picture
    {
    float pictureWidthInPins = self.pictureWidthInPins.floatValue;
    float pictureDensity = pictureWidthInPins/self.pictureSize.width;//pin/mm
    float pictureHeightInPins = self.pictureSize.height*pictureDensity;
    return pictureWidthInPins*pictureHeightInPins;//*1(pin)
    }
  
  //fallback: get value from preferences
  NSNumber* averageAddedVolumeInCubicPins = [[NSUserDefaults standardUserDefaults] objectForKey:averageDetailAddedVolumeInCubicPins];
  return averageAddedVolumeInCubicPins
       ? averageAddedVolumeInCubicPins.floatValue
       : averageDetailAddedVolumeInCubicPinsDefault;
  }

@end
