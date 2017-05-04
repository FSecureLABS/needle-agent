//
//  Utils.h
//  needleAgent
//
#import <Foundation/Foundation.h>


@interface Utils : NSObject

+ (NSData *)listApplications;

+(BOOL)copyFile:(NSString *)infile into:(NSString *)outfile;

@end



