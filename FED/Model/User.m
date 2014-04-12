//
//  User.m
//  FED
//
//  Created by Nattawut Singhchai on 4/11/14.
//  Copyright (c) 2014 Anupong Boonchued. All rights reserved.
//

#import "User.h"

@implementation User

-(id)init
{
    if (self = [super init]) {
        [self setGender:UserGenderMale];
        [self setAge:0];
        [self setWeight:0.0];
        [self setHeight:0.0];
    }
    return self;
}

-(id)initWithGender:(UserGender)gender
                age:(NSUInteger)age
             weight:(float)weight
             height:(float)height
 excerciseFrequency:(UserExerciseFrequency)frequency
{
    if (self = [super init]) {
        [self setGender:gender];
        [self setAge:age];
        [self setWeight:weight];
        [self setHeight:height];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_gender forKey:@"gender"];
    [aCoder encodeInteger:_age forKey:@"age"];
    [aCoder encodeFloat:_weight forKey:@"weight"];
    [aCoder encodeFloat:_height forKey:@"height"];
    [aCoder encodeInteger:_excerciseFequency forKey:@"freq"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.gender = [aDecoder decodeIntegerForKey:@"gender"];
        self.age     = [aDecoder decodeIntegerForKey:@"age"];
        self.weight  = [aDecoder decodeFloatForKey:@"weight"];
        self.height  = [aDecoder decodeFloatForKey:@"height"];
        self.excerciseFequency = [aDecoder decodeIntegerForKey:@"freq"];
    }
    return self;
}

-(float)MBR
{
    float exc = [@[@1.2,@1.55,@1.9][_excerciseFequency] floatValue];
    return _gender == UserGenderMale ?
    (66 + (13.7 * _weight)+ (5 * _height) - (6.8 * _age)) * exc :
    (665 + (9.6 * _weight)+ (1.8 * _height) - (4.7 * _age)) * exc ;
}

@end
