#import <UIKit/UIKit.h>

@interface PSSpecifier : NSObject
+ (instancetype)deleteButtonSpecifierWithName:(NSString *)name target:(id)target action:(SEL)action;
- (void)setProperty:(id)value forKey:(NSString *)key;
- (id)propertyForKey:(NSString *)key;
- (void)setConfirmationAction:(SEL)action;
@property (nonatomic, readonly) NSString *identifier;
@end

@interface PSViewController : UIViewController {
@public
	PSSpecifier *_specifier;
}
@end

@interface PSListController : PSViewController {
@public
	NSMutableArray *_specifiers;
}
- (NSArray *)specifiers;
- (void)showConfirmationViewForSpecifier:(PSSpecifier *)specifier;
@end

@interface UsageDetailController : PSListController
- (BOOL)isAppController;
@end

@interface LSBundleProxy : NSObject
@property (nonatomic, readonly) NSURL *dataContainerURL;
@end

@interface LSApplicationProxy : LSBundleProxy
+ (instancetype)applicationProxyForIdentifier:(NSString *)identifier;
@property (nonatomic, readonly) NSString *localizedShortName;
@property (nonatomic, readonly) NSString *itemName;
@property (nonatomic, readonly) NSNumber *dynamicDiskUsage;
@end

typedef const struct __SBSApplicationTerminationAssertion *SBSApplicationTerminationAssertionRef;

extern SBSApplicationTerminationAssertionRef SBSApplicationTerminationAssertionCreateWithError(void *unknown, NSString *bundleIdentifier, int reason, int *outError);
extern void SBSApplicationTerminationAssertionInvalidate(SBSApplicationTerminationAssertionRef assertion);
extern NSString *SBSApplicationTerminationAssertionErrorString(int error);
