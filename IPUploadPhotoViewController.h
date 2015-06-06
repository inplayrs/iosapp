//
//  IPUploadPhotoViewController.h
//  Inplayrs
//
//  Created by Anil Bhagchandani on 28/03/2013.
//  Copyright (c) 2013 Inplayrs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Game;

@interface IPUploadPhotoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate> {
        UITextField *activeField;
}

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadPhotoButton;
@property (weak, nonatomic) IBOutlet UITextField *captionText;
@property (strong, nonatomic) Game *game;
@property (weak, nonatomic) IBOutlet UILabel *addPhotoLabel;

- (IBAction)addPhoto:(id)sender;
- (IBAction)uploadPhoto:(id)sender;
- (void)dismissKeyboard;



@end
