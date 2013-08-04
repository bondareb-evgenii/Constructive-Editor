//
//  PrintPaperManager.m
//  ConstructiveEditor

#import "PrintPaperManager.h"
#import "PreferencesKeys.h"

@implementation PrintPaper
@end

@implementation PrintPaperManager

+ (PrintPaper*)preferedPaper
  {
  PrintPaper* paper = [[PrintPaper alloc] init];
  NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
  NSString* preferredPaperSizeStringValue = [preferences stringForKey:preferredPaperSize];
  NSString* preferredPaperOrientationStringValue = [preferences stringForKey:preferredPaperOrientation];
  if (preferredPaperSizeStringValue == nil ||
      preferredPaperSizeStringValue == preferredPaperSize_A4)
    {
    if (preferredPaperOrientationStringValue == nil ||
        preferredPaperOrientationStringValue == preferredPaperOrientation_Portrait)
      {
      paper.paperSize = CGSizeMake(595, 842);
      paper.printableRect = CGRectMake(0.8, 0.2, 594, 841.6);
      }
    else
      {
      paper.paperSize = CGSizeMake(842, 595);
      paper.printableRect = CGRectMake(0.8, 0.2, 841, 594.6);
      }
    }
  else
    {
    if (preferredPaperOrientationStringValue == nil ||
        preferredPaperOrientationStringValue == preferredPaperOrientation_Portrait)
      {
      paper.paperSize = CGSizeMake(842, 1190);
      paper.printableRect = CGRectMake(0.8, 0.2, 841, 1189.6);
      }
    else
      {
      paper.paperSize = CGSizeMake(1190, 842);
      paper.printableRect = CGRectMake(0.8, 0.2, 1189, 841.6);
      }
    }
  return paper;
  }

@end

/*
Letter		 612x792
LetterSmall	 612x792
Tabloid		 792x1224
Ledger		1224x792
Legal		 612x1008
Statement	 396x612
Executive	 540x720
A0               2384x3371
A1              1685x2384
A2		1190x1684
A3		 842x1190
A4		 595x842
A4Small		 595x842
A5		 420x595
B4		 729x1032
B5		 516x729
Folio		 612x936
Quarto		 610x780
10x14		 720x1008
*/
