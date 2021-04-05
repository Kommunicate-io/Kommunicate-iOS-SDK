#import <Foundation/Foundation.h>

NSBundle* ApplozicCore_SWIFTPM_MODULE_BUNDLE() {
    NSURL *bundleURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"Applozic_ApplozicCore.bundle"];
    return [NSBundle bundleWithURL:bundleURL];
}