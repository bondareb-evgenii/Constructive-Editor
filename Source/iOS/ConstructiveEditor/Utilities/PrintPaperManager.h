//
//  PrintPaperManager.h
//  ConstructiveEditor

#import <Foundation/Foundation.h>

@interface PrintPaper : NSObject

@property (nonatomic) CGSize paperSize;
@property (nonatomic) CGRect printableRect;

@end

@interface PrintPaperManager : NSObject

//Described in PostScript points (1/72 inch)
//Printable area is taken according to standard drawing sheet frame: 20mm (0.8 inches) from the left margin and 5mm (0.2 inches) to other ones; two-sided printing is not taken into account yet
+ (PrintPaper*)preferedPaper;

@end
