//
//  MWRAsyncSocket.m
//  needleAgent
//

#import "MWRAsyncSocket.h"

@implementation MWRAsyncSocket

-(instancetype)initWithDelegate:(id<GCDAsyncSocketDelegate>)aDelegate
                  delegateQueue:(dispatch_queue_t)dq
                    socketQueue:(dispatch_queue_t)sq
{
    self = [super initWithDelegate:aDelegate delegateQueue: dq socketQueue:sq];
    self.handler = [[MWRCommandHandler alloc] initWithSocket:self];
    return self;
}

-(void) interruptLog
{
    self.handler.interrupt = YES;
}

-(void) writeString:(NSString *)string withCRLF:(BOOL)crlf
{
    NSString *response;
    if(crlf)
        response = [NSString stringWithFormat:@"%@\r\n",string];
    else
        response = string;
    
    NSData *writeData = [response dataUsingEncoding:NSUTF8StringEncoding];
    [self writeData:writeData withTimeout:-1 tag:0];
}

@end
