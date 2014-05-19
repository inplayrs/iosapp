//
//  IPCreateViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 05/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPCreateViewController.h"
#import "RestKit.h"
#import "Flurry.h"
#import "Error.h"
#import "TSMessage.h"
#import "IPAddFriendsViewController.h"
#import "FriendPool.h"
#import "IPFriendViewController.h"


@interface IPCreateViewController ()

@end

@implementation IPCreateViewController

@synthesize createButton, poolName, addFriendsViewController, submitPoolName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Create Pool";
    addFriendsViewController = nil;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"screen-football.png"]];
    
    /*
    UIImage *backButtonNormal = [UIImage imageNamed:@"back-button.png"];
    UIImage *backButtonHighlighted = [UIImage imageNamed:@"back-button-hit-state.png"];
    CGRect frameimg = CGRectMake(0, 0, backButtonNormal.size.width, backButtonNormal.size.height);
    UIButton *backButton = [[UIButton alloc] initWithFrame:frameimg];
    [backButton setBackgroundImage:backButtonNormal forState:UIControlStateNormal];
    [backButton setBackgroundImage:backButtonHighlighted forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem =[[UIBarButtonItem alloc] initWithCustomView:backButton];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, barButtonItem, nil]];
    } else {
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
    */
    // self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:@selector(backButtonPressed:)];
    
    UIImage *image = [UIImage imageNamed:@"login-button-normal.png"];
    UIImage *image2 = [UIImage imageNamed:@"login-button-hit.png"];
    UIImage *image3 = [UIImage imageNamed:@"login-button-disabled.png"];
    [self.createButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.createButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    [self.createButton setBackgroundImage:image3 forState:UIControlStateDisabled];
    self.createButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
    
    CGRect frame = CGRectMake(0, 20, 320, 44);
    UIToolbar *createToolbar = [[UIToolbar alloc] initWithFrame:frame];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)];
    // [cancelBtn setTintColor:[UIColor colorWithRed:234.0/255.0 green:208.0/255.0 blue:23.0/255.0 alpha:1.0]];
    [cancelBtn setTintColor:[UIColor blackColor]];
    [barItems addObject:cancelBtn];
    [createToolbar setItems:barItems animated:NO];
    
    [self.view addSubview:createToolbar];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] } forState:UIControlStateNormal];
        UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.createButton.titleEdgeInsets = titleInsets;
        createToolbar.barTintColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
    } else {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil];
        [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [cancelBtn setTintColor:[UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0]];
        createToolbar.tintColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
    }
    
}

/*
- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
 */

- (void) cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
            textField.text = @"Enter Pool Name";
    }
    [textField resignFirstResponder];
    activeField = nil;
}


- (IBAction)createPool:(UIButton *)sender {
    if ([self.poolName.text isEqualToString:@""]  || [self.poolName.text isEqualToString:@"Enter Pool Name"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Pool Name" message:@"Please enter a name for your friend pool!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (![self validatePoolname:self.poolName.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Pool Name" message:@"Please enter a Pool Name between 5 and 15 characters composed of letters and numbers only!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self.view endEditing:YES];
    self.submitPoolName = [self.poolName.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    [self postPool];
}

- (BOOL) validatePoolname: (NSString *) candidate {
    NSString *poolnameRegex = @"[\\sA-Z0-9a-z_-]{5,15}";
    NSPredicate *poolnameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", poolnameRegex];
    
    return [poolnameTest evaluateWithObject:candidate];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)dismissKeyboard:(id)sender {
    [activeField resignFirstResponder];
}

- (void)postPool
{
    self.createButton.enabled = NO;
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"pool/create?name=%@", self.submitPoolName];
    [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        FriendPool *friendPool = [result firstObject];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Create",
                                     @"type", @"Success", @"result", nil];
        [Flurry logEvent:@"FRIEND" withParameters:dictionary];
        [TSMessage showNotificationInViewController:self
                                               title:@"Create Successful"
                                            subtitle:@"You have created a new friend pool."
                                               image:nil
                                                type:TSMessageNotificationTypeSuccess
                                            duration:TSMessageNotificationDurationAutomatic
                                            callback:nil
                                         buttonTitle:nil
                                      buttonCallback:nil
                                          atPosition:TSMessageNotificationPositionTop
                                 canBeDismisedByUser:YES];
        self.createButton.enabled = YES;
        self.poolName.text = @"Enter Pool Name";
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:friendPool forKey:@"friendPool"];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"AddFriends" object:nil userInfo:userInfo];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        self.createButton.enabled = YES;
        NSArray *errorMessages = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
        Error *myerror = [errorMessages objectAtIndex:0];
        if (!myerror.message)
            myerror.message = @"Please try again later!";
        NSString *errorString = [NSString stringWithFormat:@"%d", (int)myerror.code];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Create",
                                    @"type", @"Fail", @"result", errorString, @"error", nil];
        [Flurry logEvent:@"FRIEND" withParameters:dictionary];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed" message:myerror.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];

}



@end
