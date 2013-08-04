//
//  ManagedObjectWithPicture.m
//  ConstructiveEditor

#import "ManagedObjectWithPicture.h"
#import "Picture.h"
#import "UIImage+Resize.h"

@implementation ManagedObjectWithPicture

@dynamic isPictureSelected;
@dynamic picture;
@dynamic pictureThumbnail60x60AspectFit;
@dynamic pictureThumbnail120x120AspectFit;
@dynamic picturePrepared;
@dynamic picturePreparedThumbnail60x60AspectFit;
@dynamic picturePreparedThumbnail120x120AspectFit;


- (void)setPictureImage:(UIImage*)image
  {
  if (image == self.picture.image)
    return;
  if (image)
    {
    if (nil == self.picture)
      {
      Picture* picture = (Picture*)[NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:self.managedObjectContext];
      self.picture = picture;
      }
    if (nil == self.pictureThumbnail60x60AspectFit)
      {
      Picture* picture = (Picture*)[NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:self.managedObjectContext];
      self.pictureThumbnail60x60AspectFit = picture;
      }
    if (nil == self.pictureThumbnail120x120AspectFit)
      {
      Picture* picture = (Picture*)[NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:self.managedObjectContext];
      self.pictureThumbnail120x120AspectFit = picture;
      }
    self.isPictureSelected = [NSNumber numberWithBool:YES];
    self.picture.image = image;
    self.pictureThumbnail60x60AspectFit.image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(60, 60) interpolationQuality:kCGInterpolationHigh];
    self.pictureThumbnail120x120AspectFit.image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(120, 120) interpolationQuality:kCGInterpolationHigh];
    }
  else
    {
    self.isPictureSelected = [NSNumber numberWithBool:NO];
    self.picture.image = self.pictureThumbnail60x60AspectFit.image = self.pictureThumbnail120x120AspectFit.image = nil;
    }
  //clear prepared picture which should always depend on the original one
  self.picturePrepared.image = self.picturePreparedThumbnail60x60AspectFit.image = self.picturePreparedThumbnail120x120AspectFit.image = nil;
  }

- (void)setPicturePreparedImage:(UIImage*)image
  {
  if (image == self.picturePrepared.image)
    return;
  if (image)
    {
    self.isPictureSelected = [NSNumber numberWithBool:YES];
    self.picturePrepared.image = image;
    self.picturePreparedThumbnail60x60AspectFit.image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(60, 60) interpolationQuality:kCGInterpolationHigh];
    self.picturePreparedThumbnail120x120AspectFit.image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(120, 120) interpolationQuality:kCGInterpolationHigh];
    }
  else
    {
    self.isPictureSelected = [NSNumber numberWithBool:nil != self.pictureThumbnail60x60AspectFit];//depending on whether the original picture is selected
    self.picturePrepared.image = self.picturePreparedThumbnail60x60AspectFit.image = self.picturePreparedThumbnail120x120AspectFit.image = nil;
    }
  }

- (UIImage*)pictureBestForSize:(CGSize)size;
  {
  const CGFloat maxZoom = 1.2f;//maximum zoom factor we can scale a picture to before the artifacts become noticable for the user
  if (60*maxZoom >= size.width || 60*maxZoom >= size.height)
    {
    UIImage* thumbnail60x60 = [self pictureToShowThumbnail60x60AspectFit];
    CGSize thumbnail60x60RealSize = thumbnail60x60.size;
    if (thumbnail60x60RealSize.width*maxZoom >= size.width || thumbnail60x60RealSize.height*maxZoom >= size.height)
      return thumbnail60x60;
    }
  //no else here
  if (120*maxZoom >= size.width || 120*maxZoom >= size.height)
    {
    UIImage* thumbnail120x120 = [self pictureToShowThumbnail120x120AspectFit];
    CGSize thumbnail120x120RealSize = thumbnail120x120.size;
    if (thumbnail120x120RealSize.width*maxZoom >= size.width || thumbnail120x120RealSize.height*maxZoom >= size.height)
      return thumbnail120x120;
    }
  //no else here
  return [self pictureToShow];
  }

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

- (UIImage*)pictureToShowThumbnail120x120AspectFit
  {
  if (self.picturePreparedThumbnail120x120AspectFit.image)
    return self.picturePreparedThumbnail120x120AspectFit.image;
  return self.pictureThumbnail120x120AspectFit.image;
  }

@end
