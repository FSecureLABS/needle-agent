//
//  MWRServerViewController.h
//  needleAgent
//

#import <UIKit/UIKit.h>
#import "MWRCommandHandler.h"
#import "MWRAsyncSocket.h"
@import CocoaAsyncSocket;


@interface MWRServerViewController : UIViewController <GCDAsyncSocketDelegate>{}

@property (strong, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *responsesLabel;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property NSMutableString *responsesString;
@property NSMutableArray *connectedSockets;
@property dispatch_queue_t socketQueue;
@property (nonatomic) MWRAsyncSocket *listenerSocket;

-(void)dismissKeyboard;
-(IBAction)startStop:(id)sender;
-(void)listen:(UISwitch *)s;
-(void)disconnect;

@end
