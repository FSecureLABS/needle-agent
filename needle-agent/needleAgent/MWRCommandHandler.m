//
//  MWRCommandHandler.m
//  needleAgent
//

#import "MWRCommandHandler.h"
#import "MWRAsyncSocket.h"
#import "Constants.h"


@implementation MWRCommandHandler

-(instancetype)initWithSocket:(MWRAsyncSocket *)socket
{
    self = [super init];
    self.socket = socket;
    self.interrupt = NO;
    return self;
}

-(NSString *)handleCommand:(NSString *)request
{
    if(request){
        NSArray *formattedRequest = [self parseRequest:request];
        NSString *opCode = [formattedRequest[0] uppercaseString];
        NSArray *arguments = [formattedRequest subarrayWithRange:NSMakeRange(1, [formattedRequest count]-1)];
        NSLog(@"Handle Command: %@, %@", opCode, arguments);
        return [self handleOpCode:opCode withArguments:arguments];
    } else {
        return @"Invalid command";
    }
}

-(NSString *)handleOpCode:(NSString *)opCode withArguments:(NSArray *)arguments
{
    SEL method = NSSelectorFromString(@"run:");
    NSString *classname = [NSString stringWithFormat:@"Opcode%@", opCode];
    Class class = NSClassFromString(classname);
    
    if([class respondsToSelector:method]){
        IMP imp = [class methodForSelector:method];
        NSString * (*func)(id, SEL, NSArray *) = (void *)imp;
        return func(class, method, arguments);
    }
    
    return @"Invalid Opcode";
}

-(NSArray *)parseRequest:(NSString *)request
{
    NSError *err = nil;
    
    // Matches 1 or more whitespace characters
    NSString *excessWhiteSpace = @"\\s+";
    NSRegularExpression *excessRegex = [NSRegularExpression
                                        regularExpressionWithPattern:excessWhiteSpace
                                        options:0
                                        error:&err];
    // Matches space character at end of string
    NSString *trailingWhiteSpace = @" $";
    NSRegularExpression *trailingRegex = [NSRegularExpression
                                          regularExpressionWithPattern:trailingWhiteSpace
                                          options:0
                                          error:&err];
    // Replaces any groups of whitespace characters with a single space character
    NSString *normailzed = [excessRegex
                            stringByReplacingMatchesInString:request
                            options:0
                            range:NSMakeRange(0, [request length])
                            withTemplate:@" "];
    // Removes space character at end of string if there is one
    NSString *final = [trailingRegex
                       stringByReplacingMatchesInString:normailzed
                       options:0
                       range:NSMakeRange(0, [normailzed length])
                       withTemplate:@""];
    
    return [final componentsSeparatedByString:@" "];
}

@end
