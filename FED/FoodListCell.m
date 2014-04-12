//
//  FoodListCell.m
//  FED
//
//  Created by Nattawut Singhchai on 4/11/14.
//  Copyright (c) 2014 TrendyBear. All rights reserved.
//

#import "FoodListCell.h"

@interface FoodListCell()
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodNameLabel;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;

@end

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
    self.food.quantity = (NSUInteger)sender.value;
    [_quantityLabel setText:[NSString stringWithFormat:@"%.0f",sender.value]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FED_SAVE" object:nil];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [_foodNameLabel setText:_food.name];
    _stepper.value = _food.quantity;
    [self changedStepperValue:_stepper];
}

@end
