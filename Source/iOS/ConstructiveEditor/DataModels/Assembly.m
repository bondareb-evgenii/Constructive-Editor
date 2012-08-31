//
//  Assembly.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "Assembly.h"
#import "Detail.h"


@implementation Assembly

@dynamic connectionPoint;
@dynamic picture;
@dynamic picturePrepared;
@dynamic assembliesInstalled;
@dynamic detailsInstalled;
@dynamic assemblyBase;
@dynamic assemblyExtended;
@dynamic assemblyToInstallTo;
@dynamic assemblyTransformed;
@dynamic assemblyBeforeTransformation;
@dynamic assemblyRotated;
@dynamic assemblyBeforeRotation;

- (UIImage*)pictureToShow
  {
  if (self.picturePrepared)
    return self.picturePrepared;
  return self.picture;
  }
  
- (void)awakeFromInsert
  {
  NSLog(@"[Asembly awakeFromInsert]:   0x%x", self);
  [super awakeFromInsert];
  }
  
- (void)didTurnIntoFault
  {
  NSLog(@"[Assembly didTurnIntoFault]:   0x%x", self);
  [super didTurnIntoFault];
  }
  
- (void)dealloc
  {
  NSLog(@"[Assembly didTurnIntoFault]:   0x%x", self);
  }

@end
