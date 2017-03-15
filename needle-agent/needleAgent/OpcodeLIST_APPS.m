//
//  OpcodeLIST_APPS.m
//  needleAgent
//

#import "OpcodeProtocol.h"
#import "LSApplicationWorkspace.h"
#import "FBApplicationInfo.h"
#import "LSApplicationProxy.h"

@interface OpcodeLIST_APPS : NSObject <OPCODE>
@end


@implementation OpcodeLIST_APPS

+(NSString *)run:(NSArray *)args
{
    NSString *res = [self listApplications];
    NSString * responseString = [NSString stringWithFormat:@"%@%@%@", COMMAND_OUTPUT_START, res, COMMAND_OUTPUT_END];
    return responseString;
}

+ (NSString *)listApplications
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
    
    // Convert it to JSON
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:all_apps options:0 error:&err];
    
    NSLog(@">>>>");
    NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    NSLog(@">>>>");
    
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end

