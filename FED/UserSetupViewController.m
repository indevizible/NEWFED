//
//  UserSetupViewController.m
//  FED
//
//  Created by Nattawut Singhchai on 4/11/14.
//  Copyright (c) 2014 TrendyBear. All rights reserved.
//

#import "UserSetupViewController.h"
#import <BlocksKit/BlocksKit+UIKit.h>
#import "User.h"

@interface UserSetupViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomScrollViewConstrant;
- (IBAction)didTapDismiss:(id)sender;
@property (weak,nonatomic) User *user;
@property (nonatomic,assign) UserGender gender;

@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *weightTextField;
@property (weak, nonatomic) IBOutlet UITextField *heightTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *excFreqSegmentedController;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;

- (IBAction)tappedGender:(UIButton *)sender;


@end

static NSString *kFEDUserKey = @"FED_USER_KEY";
@implementation UserSetupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSData *data =[[NSUserDefaults standardUserDefaults] objectForKey:kFEDUserKey];
    User *storedUser = nil;
    if (data)
       storedUser =  [NSKeyedUnarchiver unarchiveObjectWithData:data] ;
    self.user = storedUser ? storedUser : [User new];
    self.backgroundView.frame = self.scrollView.frame;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.scrollView setContentSize:self.view.frame.size];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardToggle:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardToggle:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.scrollView bk_whenTapped:^{
        [self.view endEditing:YES];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)keyboardToggle:(NSNotification*)notification
{
    [self keyboardWillShowHide:notification];
}

- (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve
{
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
            
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
            
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
            
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
            
        default:
            return kNilOptions;
    }
}

- (void)keyboardWillShowHide:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
	double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.scrollView.contentSize = self.view.frame.size;
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:[self animationOptionsForCurve:curve]
                     animations:^{
                         CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;

                             self.bottomScrollViewConstrant.constant = self.view.frame.size.height - keyboardY;
                         NSLog(@"%f",_bottomScrollViewConstrant.constant);
                         
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)didTapDismiss:(id)sender
{
 
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[self generateUserData]] forKey:kFEDUserKey];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (User *)generateUserData
{
    User *user = [User new];
    user.gender = self.gender;
    user.age    = [self.ageTextField.text integerValue];
    user.weight = [self.weightTextField.text floatValue];
    user.height = [self.heightTextField.text floatValue];
    user.excerciseFequency = self.excFreqSegmentedController.selectedSegmentIndex;
    return user;
}

-(void)setUser:(User *)user
{
    self.gender = user.gender;
    [_ageTextField setText:user.age == 0 ? @"" : [NSString stringWithFormat:@"%u",user.age]];
    [_weightTextField setText:user.weight == 0.0f ? @"" : [NSString stringWithFormat:@"%.2f",user.weight]];
    [_heightTextField setText:user.height == 0.0f ? @"" : [NSString stringWithFormat:@"%.0f",user.height]];
    _excFreqSegmentedController.selected = YES;
    _excFreqSegmentedController.selectedSegmentIndex = user.excerciseFequency;
    _user = user;
}

- (IBAction)tappedGender:(UIButton *)sender
{
    self.gender = sender.tag;
}

-(void)setGender:(UserGender)gender
{
    [_maleButton setImage:[UIImage imageNamed:gender == UserGenderMale ? @"FED_buttonman01":@"FED_buttonman02"] forState:UIControlStateNormal];
    [_femaleButton setImage:[UIImage imageNamed:gender == UserGenderFemale ? @"FED_buttonwoman":@"FED_buttonwoman_alt"] forState:UIControlStateNormal];
    _gender = gender;
}

@end
