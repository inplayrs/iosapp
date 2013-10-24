//
//  IPAppDelegate.h
//
//
#import <FacebookSDK/FacebookSDK.h>
#import <UIKit/UIKit.h>

@class IPMultiLoginViewController;

@interface IPAppDelegate : UIResponder <UIApplicationDelegate> {
    NSString *username;
    NSString *user;
    BOOL loggedin;
    BOOL refreshLobby;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *user;
@property (nonatomic) BOOL loggedin;
@property (nonatomic) BOOL refreshLobby;
@property (strong, nonatomic) IPMultiLoginViewController *rootViewController;



@end






