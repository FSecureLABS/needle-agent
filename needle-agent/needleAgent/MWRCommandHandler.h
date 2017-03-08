//
//  MWRCommandHandler.h
//  needleAgent
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <sys/socket.h>
#import <sys/un.h>
@import CocoaAsyncSocket;

@class MWRAsyncSocket;

@interface MWRCommandHandler : NSObject 

@property BOOL interrupt;
@property (weak) MWRAsyncSocket* socket;

-(instancetype)initWithSocket:(MWRAsyncSocket *)socket;
-(NSString *)handleCommand:(NSString *)request;
-(NSString *)handleOpCode:(NSString *)opCode withArguments:(NSArray *)arguments;
-(NSArray *)parseRequest:(NSString *)arguments;

@end
