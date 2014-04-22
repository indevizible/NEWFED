//
//  FoodListCell.h
//  FED
//
//  Created by Nattawut Singhchai on 4/11/14.
//  Copyright (c) 2014 TrendyBear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodHelper.h"
@class User;
@interface FoodListCell : UITableViewCell

@property (nonatomic,weak) FoodHelper *food;
@property (nonatomic,assign) float currentEnergy;
@end
