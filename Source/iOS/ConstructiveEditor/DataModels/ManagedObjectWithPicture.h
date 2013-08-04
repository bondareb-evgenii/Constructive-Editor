//
//  ManagedObjectWithPicture.h
//  ConstructiveEditor

#import <CoreData/CoreData.h>

@class Picture;

@interface ManagedObjectWithPicture : NSManagedObject

  @property (nonatomic, retain) NSNumber*           isPictureSelected;
  //relations
  @property (nonatomic, retain) Picture*  picture;
  @property (nonatomic, retain) Picture*  pictureThumbnail60x60AspectFit;
  @property (nonatomic, retain) Picture*  pictureThumbnail120x120AspectFit;
  @property (nonatomic, retain) Picture*  picturePrepared;
  @property (nonatomic, retain) Picture*  picturePreparedThumbnail60x60AspectFit;
  @property (nonatomic, retain) Picture*  picturePreparedThumbnail120x120AspectFit;

  - (void)setPictureImage:(UIImage*)image;
  - (void)setPicturePreparedImage:(UIImage*)image;
  - (UIImage*)pictureBestForSize:(CGSize)size;

@end
