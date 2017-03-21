//
//  OpcodeOS_VERSION.m
//  needleAgent
//
#import "OpcodeProtocol.h"

@interface OpcodeOS_VERSION : NSObject <OPCODE>
@end


@implementation OpcodeOS_VERSION

+(NSString *)run:(NSArray *)args
{
    NSString *res = [self getOSVersion];
    NSLog(@"RES: %@", res);
    NSString * responseString = [NSString stringWithFormat:@"%@%@", res, COMMAND_OUTPUT_END];
    return responseString;
}

+ (NSString *)getOSVersion
{
    NSOperatingSystemVersion ver = [[NSProcessInfo processInfo] operatingSystemVersion];
    return [NSString stringWithFormat:@"%ld", ver.majorVersion];
}

@end

