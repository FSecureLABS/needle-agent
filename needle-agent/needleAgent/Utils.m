//
//  Utils.m
//  needleAgent
//
#import "Utils.h"

// LIST_APPS
#import "LSApplicationWorkspace.h"
#import "FBApplicationInfo.h"
#import "LSApplicationProxy.h"

// IP ADDRESS
#include <ifaddrs.h>
#include <arpa/inet.h>

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

+ (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}
@end
