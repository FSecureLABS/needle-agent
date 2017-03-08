//
//  OpcodeSTOP.m
//  needleAgent
//

#import "OpcodeProtocol.h"
#import "MWRCommandHandler.h"

@interface OpcodeSTOP : NSObject <OPCODE>
@end


@implementation OpcodeSTOP

+(NSString *)run:(NSArray *)args
{
    [[MWRCommandHandler alloc] init].interrupt = YES;
    return COMMAND_DISCONNECT;
}
@end
