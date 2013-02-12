//
//  VisualSelectablePointer.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "VisualSelectablePointer.h"

@interface VisualSelectablePointer ()
  {
  CGPoint   _selectionCenter;
  float     _selectionRadius;
  CGPoint   _targetPoint;
  }
@end

@implementation VisualSelectablePointer

- (id)initWithSelectionCenter:(CGPoint)selectionCenter selectionRadius:(float)selectionRadius andTargetPoint:(CGPoint)targetPoint
  {
  self = [super init];
  if (self)
    {
    _selectionCenter = selectionCenter;
    _selectionRadius = selectionRadius;
    _targetPoint = targetPoint;
    }
  return self;
  }

- (CGPoint)topLeftImageCornerPointForTargetPoint:(CGPoint)targetPoint
  {
  return CGPointMake(targetPoint.x - _targetPoint.x, targetPoint.y - _targetPoint.y);
  }

- (CGPoint)selectionCenterForTargetPoint:(CGPoint)targetPoint
  {
  return CGPointMake(targetPoint.x + _selectionCenter.x - _targetPoint.x, targetPoint.y + _selectionCenter.y - _targetPoint.y);
  }

- (BOOL)shouldSelectPointerPointingTo:(CGPoint)targetPoint byPoint:(CGPoint)point
  {
  CGPoint selectionCenter = [self selectionCenterForTargetPoint:targetPoint];
  float distanceX = selectionCenter.x - point.x;
  float distanceY = selectionCenter.y - point.y;
  return _selectionRadius > sqrtf(distanceX*distanceX + distanceY*distanceY);
  }

@end
