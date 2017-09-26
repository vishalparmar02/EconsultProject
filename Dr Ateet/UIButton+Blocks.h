#import <objc/runtime.h>
#import <UIKit/UIKit.h>

typedef void (^EmptyBlock)();
static char UIButtonBlockKey;

@interface UIButton (UIBlockButton)
- (void)handleControlEvent:(UIControlEvents)event withBlock:(EmptyBlock)block;
- (void)callBlock:(id)sender;
@end