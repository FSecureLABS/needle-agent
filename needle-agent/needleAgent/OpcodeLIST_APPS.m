//
//  OpcodeLIST_APPS.m
//  needleAgent
//

#import "OpcodeProtocol.h"

@interface OpcodeLIST_APPS : NSObject <OPCODE>
@end


@implementation OpcodeLIST_APPS

+(NSString *)run:(NSArray *)args
{
    // Get list of apps
    NSMutableDictionary *allApps = [Utils listApplications];
    
    // Convert it to JSON
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:allApps options:0 error:&err];
    NSString *res = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"RES: %@", res);
    
    // Return output
    NSString * responseString = [NSString stringWithFormat:@"%@%@", res, COMMAND_OUTPUT_END];
    return responseString;
}

@end

