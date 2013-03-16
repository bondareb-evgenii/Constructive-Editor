//
//  AssemblyType.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "AssemblyType.h"
#import "Assembly.h"
#import "AssemblyTypesShelf.h"
#import "Detail.h"
#import "Picture.h"


@implementation AssemblyType

@dynamic picture;
@dynamic pictureThumbnail60x60AspectFit;
@dynamic picturePrepared;
@dynamic picturePreparedThumbnail60x60AspectFit;
@dynamic preparedPicturePoint0_0X;
@dynamic preparedPicturePoint0_0Y;
@dynamic preparedPicturePoint1_1X;
@dynamic preparedPicturePoint1_1Y;
@dynamic assemblies;
@dynamic assembliesInstalled;
@dynamic detailsInstalled;
@dynamic assemblyBase;
@dynamic assemblyBeforeTransformation;
@dynamic assemblyBeforeRotation;
@dynamic shelf;

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
  
/*- (void)awakeFromInsert
  {
  NSLog(@"[AssemblyType awakeFromInsert]:   0x%x", self);
  [super awakeFromInsert];
  }
  
- (void)didTurnIntoFault
  {
  NSLog(@"[AssemblyType didTurnIntoFault]:   0x%x", self);
  [super didTurnIntoFault];
  }
  
- (void)dealloc
  {
  NSLog(@"[AssemblyType dealloc]:   0x%x", self);
  }*/

@end
