#import <objc/runtime.h>
#import <UIKit/UIKit.h>

typedef void (^SelectionBlock)(UIPickerView *pickerView, NSInteger row, NSInteger component);
static char TitlesKey, SelectBlockKey;

@interface UIPickerView (UIBlockPickerView) <UIPickerViewDataSource, UIPickerViewDelegate>
- (void)setTitles:(NSArray *)titles;
- (void)handleSelectionWithBlock:(SelectionBlock)block;
@end