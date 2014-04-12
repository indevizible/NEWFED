//
//  Food.m
//  FED
//
//  Created by Nattawut Singhchai on 4/11/14.
//  Copyright (c) 2014 Anupong Boonchued. All rights reserved.
//

#import "Food.h"

@implementation Food

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeFloat:_energy forKey:@"energy"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.energy = [aDecoder decodeFloatForKey:@"energy"];
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.name = dictionary[@"name"];
        self.energy = [dictionary[@"energy"] floatValue];
    }
    return self;
}

@end
