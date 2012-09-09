//
//  AssemblyType.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "AssemblyType.h"
#import "Assembly.h"
#import "Detail.h"


@implementation AssemblyType

@dynamic picture;
@dynamic picturePrepared;
@dynamic assemblies;
@dynamic assembliesInstalled;
@dynamic detailsInstalled;
@dynamic assemblyBase;
@dynamic assemblyBeforeTransformation;
@dynamic assemblyBeforeRotation;

- (UIImage*)pictureToShow
  {
  if (self.picturePrepared)
    return self.picturePrepared;
  return self.picture;
  }
  
- (void)awakeFromInsert
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
  NSLog(@"[AssemblyType didTurnIntoFault]:   0x%x", self);
  }

@end
