//
//  FoodeEditorViewController.h
//  FED
//
//  Created by Nattawut Singhchai on 4/12/14.
//  Copyright (c) 2014 TrendyBear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodHelper.h"
@interface FoodeEditorViewController : UIViewController
@property (nonatomic,weak) FoodHelper *food;
@property (nonatomic,copy) void(^addedNewFood)(FoodHelper *food);
@property (nonatomic,copy) void(^removeFood)(FoodHelper *food);
@end
