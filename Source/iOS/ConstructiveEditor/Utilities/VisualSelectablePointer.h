//
//  VisualSelectablePointer.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VisualSelectablePointer : NSObject

- (id)initWithSelectionCenter:(CGPoint)selectionCenter selectionRadius:(float)selectionRadius andTargetPoint:(CGPoint)targetPoint;
- (CGPoint)topLeftImageCornerPointForTargetPoint:(CGPoint)targetPoint;
- (CGPoint)selectionCenterForTargetPoint:(CGPoint)targetPoint;
- (BOOL)shouldSelectPointerPointingTo:(CGPoint)targetPoint byPoint:(CGPoint)point;

@end
