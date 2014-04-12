//
//  FoodeEditorViewController.m
//  FED
//
//  Created by Nattawut Singhchai on 4/12/14.
//  Copyright (c) 2014 TrendyBear. All rights reserved.
//

#import "FoodeEditorViewController.h"
#import <BlocksKit/BlocksKit+UIKit.h>

@interface FoodeEditorViewController ()

- (IBAction)goBack:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UITextField *foodNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *energyTextField;
@end

@implementation FoodeEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _deleteButton.enabled = (self.food) ? YES :NO;
    [_foodNameTextField setText:_food.name];
    if (self.food) {
        [_energyTextField setText:[NSString stringWithFormat:@"%.2f",_food.energy]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)save:(id)sender
{
    if (self.food) {
        self.food.energy = [self.energyTextField.text floatValue];
        self.food.name = self.foodNameTextField.text;
    }else{
        Food *food = [[Food alloc] init];
        food.name = [self.foodNameTextField.text copy];
        food.energy = [self.energyTextField.text floatValue];
        
        FoodHelper *fh = [[FoodHelper alloc] initWithFood:food];
        
        if (self.addedNewFood) {
            self.addedNewFood(fh);
        }
    }
    [self goBack:sender];
}

- (IBAction)deleteFood:(id)sender
{
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"ลบ" message:@"คุณต้องการจะลบข้อมูลอาหารนี้หรือไม่"];
    [alertView bk_addButtonWithTitle:@"ลบ" handler:^{
        if (self.removeFood) {
            self.removeFood(self.food);
        }
        [self goBack:sender];
    }];
    [alertView bk_addButtonWithTitle:@"ยกเลิก" handler:nil];
    [alertView show];
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
