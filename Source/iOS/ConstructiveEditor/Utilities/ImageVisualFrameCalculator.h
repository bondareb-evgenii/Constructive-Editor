//
//  ImageVisualFrameCalculator.h
//  ConstructiveEditor

#import <Foundation/Foundation.h>

@interface ImageVisualFrameCalculator : NSObject

- (id)initWithImageView:(UIImageView*)imageView;

@property (nonatomic, weak) UIImageView*  imageView;
@property (nonatomic) CGRect              imageVisualFrameInViewCoordinates;
@property (nonatomic) CGRect              imageVisualFrameInViewCoordinatesCached;

@end
