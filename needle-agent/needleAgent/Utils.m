//
//  Utils.m
//  needleAgent
//
#import "Utils.h"

// LIST_APPS
#import "LSApplicationWorkspace.h"
#import "FBApplicationInfo.h"
#import "LSApplicationProxy.h"

@implementation Utils


+ (NSMutableDictionary *)listApplications
{
    NSMutableDictionary *all_apps = [NSMutableDictionary new];
    NSDictionary *bundleInfo = nil;
    
    LSApplicationWorkspace *applicationWorkspace = [LSApplicationWorkspace defaultWorkspace];
    NSArray *proxies = [applicationWorkspace allApplications];
    
    for (FBApplicationInfo *proxy in proxies)
    {
        NSString *appType = [proxy performSelector:@selector(applicationType)];
        
        if ([appType isEqualToString:@"User"] && proxy.bundleContainerURL && proxy.bundleURL)
        {
            NSString *itemName = ((LSApplicationProxy*)proxy).itemName;
            if (!itemName)
            {
                itemName = ((LSApplicationProxy*)proxy).localizedName;
            }
            
            bundleInfo = @{
                           @"BundleURL": [proxy.bundleURL absoluteString],
                           @"BundleContainer": [proxy.bundleContainerURL absoluteString],
                           @"DataContainer": [proxy.dataContainerURL absoluteString],
                           @"DisplayName": itemName,
                           @"BundleIdentifier": proxy.bundleIdentifier,
                           @"BundleVersion": proxy.bundleVersion,
                           @"BundleURL": [proxy.bundleURL absoluteString],
                           @"Entitlements": proxy.entitlements,
                           @"SDKVersion": proxy.sdkVersion,
                           @"MinimumOS": ((LSApplicationProxy*)proxy).minimumSystemVersion,
                           @"TeamID": ((LSApplicationProxy*)proxy).teamID,
                           };
            all_apps[proxy.bundleIdentifier] = bundleInfo;
        }
    }
    
    return all_apps;
}


+(BOOL)copyFile:(NSString *)infile into:(NSString *)outfile;
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager createDirectoryAtPath:[outfile stringByDeletingLastPathComponent]
                     withIntermediateDirectories:YES attributes:nil error:NULL])
    {
        NSLog(@"Failed to create directory at path: %@", [outfile stringByDeletingLastPathComponent]);
        return NO;
    }
    
    if ([fileManager fileExistsAtPath:outfile])
    {
        [fileManager removeItemAtPath:outfile error:nil];
    }
    
    if(![fileManager copyItemAtPath:infile toPath:outfile error:&error])
    {
        NSLog(@"Failed to copy item: %@ to %@", infile, outfile);
        NSLog(@"Copy file error: %@", error.localizedDescription);
        return NO;
    }
    return YES;
}

@end
