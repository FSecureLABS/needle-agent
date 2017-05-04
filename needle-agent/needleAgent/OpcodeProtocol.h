//
//  OpcodeProtocol.h
//  needleAgent
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Utils.h"

@protocol OPCODE <NSObject>

@required
+(NSString *)run:(NSArray *)args;

@end
