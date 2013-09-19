//
//  IPAppDelegate.h
//
//

#import <UIKit/UIKit.h>


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

@end
