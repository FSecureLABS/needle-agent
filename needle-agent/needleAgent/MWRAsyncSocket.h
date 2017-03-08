//
//  MWRAsyncSocket.h
//  needleAgent
//

#import "MWRCommandHandler.h"
@import CocoaAsyncSocket;


@interface MWRAsyncSocket : GCDAsyncSocket

@property MWRCommandHandler *handler;

-(instancetype)initWithDelegate:(id<GCDAsyncSocketDelegate>)aDelegate delegateQueue:(dispatch_queue_t)dq socketQueue:(dispatch_queue_t)sq;
-(void)interruptLog;
-(void) writeString:(NSString *)string withCRLF:(BOOL)crlf;

@end
