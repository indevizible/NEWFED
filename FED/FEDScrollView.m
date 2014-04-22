//
//  FEDScrollView.m
//  FED
//
//  Created by Nattawut Singhchai on 4/11/14.
//  Copyright (c) 2014 TrendyBear. All rights reserved.
//

#import "FEDScrollView.h"

@implementation FEDScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setContentSize:(CGSize)contentSize
{
    if (!contentSize.height == 0.0f) {
        [super setContentSize:contentSize];
    }
}



@end
