//
//  Assembly.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "Assembly.h"
#import "AssemblyType.h"
#import "Detail.h"


@implementation Assembly

@dynamic type;
@dynamic connectionPoint;
@dynamic assemblyExtended;
@dynamic assemblyToInstallTo;
@dynamic assemblyTransformed;
@dynamic assemblyRotated;
  
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
