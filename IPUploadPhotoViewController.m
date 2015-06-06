//
//  IPUploadPhotoViewController.m
//  Inplayrs
//
//  Created by Anil Bhagchandani on 28/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import "IPUploadPhotoViewController.h"
#import "Flurry.h"
#import "Error.h"
#import "TSMessage.h"
#import "RestKit.h"
#import "Game.h"
#import "PhotoUpload.h"
#import "S3.h"


@interface IPUploadPhotoViewController ()

@end

@implementation IPUploadPhotoViewController

@synthesize photoImageView, addPhotoButton, uploadPhotoButton, captionText, game, addPhotoLabel;

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
    self.title = @"Upload Photo";
    UIImage *image = [UIImage imageNamed:@"submit-button.png"];
    UIImage *image2 = [UIImage imageNamed:@"submit-button-hit-state.png"];
    UIImage *image3 = [UIImage imageNamed:@"submit-button-disabled.png"];
    [self.uploadPhotoButton setBackgroundImage:image forState:UIControlStateNormal];
    [self.uploadPhotoButton setBackgroundImage:image2 forState:UIControlStateHighlighted];
    [self.uploadPhotoButton setBackgroundImage:image3 forState:UIControlStateDisabled];
    self.uploadPhotoButton.titleLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:18.0];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        UIEdgeInsets titleInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        self.uploadPhotoButton.titleEdgeInsets = titleInsets;
    }
    self.uploadPhotoButton.enabled = NO;
    self.addPhotoLabel.font = [UIFont fontWithName:@"Avalon-Bold" size:14.0];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated
{
    /*
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.navigationController.navigationBar.translucent = NO;
    }
     */
    [super viewDidAppear:animated];
}


- (void) backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)addPhoto:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.photoImageView.image = chosenImage;
    [self.addPhotoButton setEnabled:NO];
    [self.addPhotoButton setHidden:YES];
    [self.addPhotoLabel setHidden:YES];
    self.uploadPhotoButton.enabled = YES;
    if (!self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Change" style:UIBarButtonItemStylePlain target:self action:@selector(addPhoto:)];
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:255.0/255.0 green:242.0/255.0 blue:41.0/255.0 alpha:1.0];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0],UITextAttributeFont,nil];
        [self.navigationItem.rightBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (IBAction)uploadPhoto:(id)sender {
    
    self.uploadPhotoButton.enabled = NO;
    [self.view endEditing:YES];
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSString *path;
    if ([self.captionText.text isEqualToString:@""]  || [self.captionText.text isEqualToString:@"Write a caption..."]) {
        path = [NSString stringWithFormat:@"game/photo?game_id=%ld", (long)self.game.gameID];
    } else {
        path = [NSString stringWithFormat:@"game/photo?game_id=%ld&caption=%@", (long)self.game.gameID, [self.captionText.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
    }
    [objectManager postObject:nil path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        PhotoUpload *photoUpload = [result firstObject];
        
        AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"photo.png"]];
        [UIImagePNGRepresentation(self.photoImageView.image) writeToFile:filePath atomically:YES];
        
        NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
        NSString* photoKey = [photoUpload.photoKey substringFromIndex:21];
        uploadRequest.bucket = @"storage.inplayrs.com";
        uploadRequest.key = photoKey;
        uploadRequest.contentType = @"image/png";
        NSLog(@"%@", photoKey);
        uploadRequest.body = fileUrl;
        
        [[transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor]
            withBlock:^id(BFTask *task) {
                if (task.error) {
                    NSLog(@"Error: %@", task.error);
                    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Upload",
                                                @"type", @"Fail", @"result", @"AWS", @"error", nil];
                    [Flurry logEvent:@"PHOTO" withParameters:dictionary];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed" message:@"Failed to upload, try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    self.uploadPhotoButton.enabled = YES;
                    [self.view endEditing:NO];
                }
                if (task.result) {
                    NSString *path2 = [NSString stringWithFormat:@"game/photo/setActive?photo_id=%ld&active=true", (long)photoUpload.photoID];
                    [objectManager postObject:nil path:path2 parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
                    } failure:nil];
                    // AWSS3TransferManagerUploadOutput *uploadOutput = task.result;
                    // The file uploaded successfully.
                    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Upload",
                                                @"type", @"Success", @"result", nil];
                    [Flurry logEvent:@"PHOTO" withParameters:dictionary];
                    [TSMessage showNotificationInViewController:self
                                                          title:@"Photo Uploaded"
                                                       subtitle:@"You have entered a photo into this game. It will now be shown to other users."
                                                          image:nil
                                                           type:TSMessageNotificationTypeSuccess
                                                       duration:TSMessageNotificationDurationAutomatic
                                                       callback:nil
                                                    buttonTitle:nil
                                                 buttonCallback:nil
                                                     atPosition:TSMessageNotificationPositionTop
                                            canBeDismisedByUser:YES];
                    self.captionText.placeholder = @"Write a caption...";
                    self.captionText.text = @"";
                    [self.captionText reloadInputViews];
                    [self.addPhotoButton setEnabled:YES];
                    [self.addPhotoButton setHidden:NO];
                    [self.addPhotoLabel setHidden:NO];
                    self.navigationItem.rightBarButtonItem = nil;
                    self.photoImageView.image = nil;
                }
                return nil;
        }];

        
    } failure:^(RKObjectRequestOperation *operation, NSError *error){
        self.uploadPhotoButton.enabled = YES;
        NSArray *errorMessages = [[error userInfo] objectForKey:RKObjectMapperErrorObjectsKey];
        Error *myerror = [errorMessages objectAtIndex:0];
        if (!myerror.message)
            myerror.message = @"Please try again later!";
        NSString *errorString = [NSString stringWithFormat:@"%d", (int)myerror.code];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Upload",
                                    @"type", @"Fail", @"result", errorString, @"error", nil];
        [Flurry logEvent:@"PHOTO" withParameters:dictionary];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed" message:myerror.message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        self.uploadPhotoButton.enabled = YES;
        [self.view endEditing:NO];
    }];

}



- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        textField.placeholder = @"Write a caption...";
    }
    [textField resignFirstResponder];
    activeField = nil;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (void)dismissKeyboard {
    [activeField resignFirstResponder];
}



@end
