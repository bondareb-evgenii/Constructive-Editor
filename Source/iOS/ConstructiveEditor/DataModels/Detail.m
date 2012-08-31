//
//  Detail.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "Detail.h"
#import "Assembly.h"
#import "DetailType.h"


@implementation Detail

@dynamic connectionPoint;
@dynamic assemblyToInstallTo;
@dynamic type;

- (void)awakeFromInsert
  {
  NSLog(@"[Detail awakeFromInsert]:   0x%x", self);
  [super awakeFromInsert];
  }
  
- (void)didTurnIntoFault
  {
  NSLog(@"[Detail didTurnIntoFault]:   0x%x", self);
  [super didTurnIntoFault];
  }
  
- (void)dealloc
  {
  NSLog(@"[Detail dealloc]:   0x%x", self);
  }
  
@end
