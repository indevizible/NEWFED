//
//  FoodListCell.m
//  FED
//
//  Created by Nattawut Singhchai on 4/11/14.
//  Copyright (c) 2014 TrendyBear. All rights reserved.
//

#import "FoodListCell.h"
#import "User.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>

@interface FoodListCell()
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodNameLabel;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;

@end
static NSString *kCurrentEnergy = @"FED_ENGY_KEY";
@implementation FoodListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)changedStepperValue:(UIStepper *)sender
{
    BOOL isInCreaseing = self.food.quantity < (NSInteger)self.stepper.value;
    self.food.quantity = (NSUInteger)self.stepper.value;
    [_quantityLabel setText:[NSString stringWithFormat:@"%.0f",self.stepper.value]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FED_SAVE" object:nil];
    if (self.food.nearFull && sender && isInCreaseing)
    {
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"Alert!" message:@"ถ้าทานอาหารนี้ พลังงานจะเกิน"];
        [alertView bk_addButtonWithTitle:@"กินต่อ" handler:^{
        
        }];
        
        [alertView bk_addButtonWithTitle:@"ไม่กินละ" handler:^{
            _stepper.value -= 1;
            [self changedStepperValue:nil];
        }];
        
        [alertView show];
    }
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [_foodNameLabel setText:_food.name];
    _stepper.value = _food.quantity;
    [self changedStepperValue:nil];
}

@end
