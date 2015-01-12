#import <UIKit/UIKit.h>

#import "Headers.h"

%hook UsageDetailController

- (NSArray *)specifiers
{
	if (!self->_specifiers) {
		%orig();
		NSMutableArray *_specifiers = self->_specifiers;
		if ([self isAppController]) {
			PSSpecifier *specifier = [PSSpecifier deleteButtonSpecifierWithName:@"Reset App" target:self action:@selector(resetDiskContent)];
			[specifier setConfirmationAction:@selector(clearCaches)];
			[_specifiers addObject:specifier];
			specifier = [PSSpecifier deleteButtonSpecifierWithName:@"Clear App's Cache" target:self action:@selector(clearCaches)];
			[specifier setConfirmationAction:@selector(clearCaches)];
			[_specifiers addObject:specifier];
		}
		return _specifiers;
	}
	return %orig();
}

static void ClearDirectoryURLContents(NSURL *url)
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSDirectoryEnumerator *enumerator = [fm enumeratorAtURL:url includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];
	NSURL *child;
	while ((child = [enumerator nextObject])) {
		[fm removeItemAtURL:child error:NULL];
	}
}

static void ShowMessage(NSString *message)
{
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"CacheClearer" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[av show];
	[av release];
}

%new
- (void)resetDiskContent
{
	NSString *identifier = self->_specifier.identifier;
	LSApplicationProxy *app = [LSApplicationProxy applicationProxyForIdentifier:identifier];
	NSString *title = app.localizedShortName;
	NSNumber *originalDynamicSize = [[app.dynamicDiskUsage retain] autorelease];
	NSURL *dataContainer = app.dataContainerURL;
	SBSApplicationTerminationAssertionRef assertion = SBSApplicationTerminationAssertionCreateWithError(NULL, identifier, 1, NULL);
	ClearDirectoryURLContents([dataContainer URLByAppendingPathComponent:@"tmp" isDirectory:YES]);
	NSURL *libraryURL = [dataContainer URLByAppendingPathComponent:@"Library" isDirectory:YES];
	ClearDirectoryURLContents(libraryURL);
	[[NSFileManager defaultManager] createDirectoryAtURL:[libraryURL URLByAppendingPathComponent:@"Preferences" isDirectory:YES] withIntermediateDirectories:YES attributes:nil error:NULL];
	ClearDirectoryURLContents([dataContainer URLByAppendingPathComponent:@"Documents" isDirectory:YES]);
	if (assertion) {
		SBSApplicationTerminationAssertionInvalidate(assertion);
	}
	NSNumber *newDynamicSize = [LSApplicationProxy applicationProxyForIdentifier:identifier].dynamicDiskUsage;
	if ([newDynamicSize isEqualToNumber:originalDynamicSize]) {
		ShowMessage([NSString stringWithFormat:@"%@ was already reset, no disk space was reclaimed.", title]);
	} else {
		ShowMessage([NSString stringWithFormat:@"%@ is now restored to a fresh state. Reclaimed %@ bytes!", title, [NSNumber numberWithDouble:[originalDynamicSize doubleValue] - [newDynamicSize doubleValue]]]);
	}
}

%new
- (void)clearCaches
{
	NSString *identifier = self->_specifier.identifier;
	LSApplicationProxy *app = [LSApplicationProxy applicationProxyForIdentifier:identifier];
	NSString *title = app.localizedShortName;
	NSNumber *originalDynamicSize = [[app.dynamicDiskUsage retain] autorelease];
	NSURL *dataContainer = app.dataContainerURL;
	SBSApplicationTerminationAssertionRef assertion = SBSApplicationTerminationAssertionCreateWithError(NULL, identifier, 1, NULL);
	ClearDirectoryURLContents([dataContainer URLByAppendingPathComponent:@"tmp" isDirectory:YES]);
	ClearDirectoryURLContents([[dataContainer URLByAppendingPathComponent:@"Library" isDirectory:YES] URLByAppendingPathComponent:@"Caches" isDirectory:YES]);
	ClearDirectoryURLContents([[[dataContainer URLByAppendingPathComponent:@"Library" isDirectory:YES] URLByAppendingPathComponent:@"Application Support" isDirectory:YES] URLByAppendingPathComponent:@"Dropbox" isDirectory:YES]);
	if (assertion) {
		SBSApplicationTerminationAssertionInvalidate(assertion);
	}
	NSNumber *newDynamicSize = [LSApplicationProxy applicationProxyForIdentifier:identifier].dynamicDiskUsage;
	if ([newDynamicSize isEqualToNumber:originalDynamicSize]) {
		ShowMessage([NSString stringWithFormat:@"Cache for %@ was already empty, no disk space was reclaimed.", title]);
	} else {
		ShowMessage([NSString stringWithFormat:@"Reclaimed %@ bytes!\n%@ may use more data or run slower on next launch to repopulate the cache.", [NSNumber numberWithDouble:[originalDynamicSize doubleValue] - [newDynamicSize doubleValue]], title]);
	}
}

%end

static void BundleLoadedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	static BOOL loaded;
	if (!loaded && [[(NSDictionary *)userInfo objectForKey:NSLoadedClasses] containsObject:@"UsageDetailController"]) {
		loaded = YES;
		%init();
	}
}

%ctor
{
	CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, BundleLoadedCallback, (CFStringRef)NSBundleDidLoadNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
