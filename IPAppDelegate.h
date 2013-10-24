//
//  IPAppDelegate.h
//
//
#import <FacebookSDK/FacebookSDK.h>
#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

<<<<<<< HEAD
//FB
@class FPViewController;  //FriendPicker
@class IPLoginViewController;  //FaceBook Login session

//FB
=======
@class IPMultiLoginViewController;
>>>>>>> iOS-David

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



//FB
@property (strong, nonatomic) FPViewController *rootViewController;  //FriendPicker
@property (strong, nonatomic) FBSession *session; //FaceBook Login session

//FB

@end






