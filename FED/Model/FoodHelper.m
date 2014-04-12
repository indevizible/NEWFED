//
//  FoodHelper.m
//  FED
//
//  Created by Nattawut Singhchai on 4/11/14.
//  Copyright (c) 2014 Anupong Boonchued. All rights reserved.
//

#import "FoodHelper.h"

@implementation FoodHelper

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_quantity forKey:@"quantity"];
    [super encodeWithCoder:aCoder];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.quantity = [aDecoder decodeIntegerForKey:@"quantity"];
    }
    return self;
}

-(id)initWithFood:(Food *)food
{
    if (self = [super init]) {
        self.name = food.name;
        self.energy = food.energy;
        self.quantity = 0;
    }
    return self;
}

-(float)summaryCalories
{
    return  _quantity * self.energy;
}

-(void)reset
{
    _quantity = 0;
}

@end
