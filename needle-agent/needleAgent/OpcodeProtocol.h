//
//  OpcodeProtocol.h
//  needleAgent
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@protocol OPCODE <NSObject>

+(NSString *)run:(NSArray *)args;

@end
