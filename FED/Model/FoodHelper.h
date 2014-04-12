//
//  FoodHelper.h
//  FED
//
//  Created by Nattawut Singhchai on 4/11/14.
//  Copyright (c) 2014 Anupong Boonchued. All rights reserved.
//

#import "Food.h"

@interface FoodHelper : Food <NSCoding>
@property (nonatomic,assign) NSUInteger quantity;
@property (nonatomic,readonly) float summaryCalories;
- (void)reset;
- (id)initWithFood:(Food *)food;
@end
