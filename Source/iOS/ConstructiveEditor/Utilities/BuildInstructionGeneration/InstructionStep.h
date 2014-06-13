//
//  InstructionStep.h
//  ConstructiveEditor

//  This class is a description of the build instruction step: in contains an array of substeps numbered from first to the last, each substep may also contain substeps numbered in the same way, so we have several step numbers levels just like in standard Lego build instructions

#import <Foundation/Foundation.h>

@class AssemblyType;

@interface InstructionStep : NSObject

  - (id)initWithAssemblyType:(AssemblyType*)assemblyType;
  + (id)stepWithAssemblyType:(AssemblyType*)assemblyType;

  @property (nonatomic, strong) AssemblyType* assemblyType;
  @property (nonatomic, readonly, strong) NSMutableArray* substeps;

  //Calculated params
  @property (nonatomic) float                 resultingAssemblyVolumeInCubicPins;//Try to preserve relative scale of details and assemblies pictures by their area.

@end
