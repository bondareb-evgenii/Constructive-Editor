//
//  ImageFrameCalculator.h
//  ConstructiveEditor
//
//  Created by 007 on 2/7/13.
//
//

#import <Foundation/Foundation.h>

@interface ImageFrameCalculator : NSObject

- (id)initWithImageView:(UIImageView*)imageView;

@property (nonatomic, weak) UIImageView*  imageView;
@property (nonatomic) CGRect              imageVisualFrameInViewCoordinates;

@end
