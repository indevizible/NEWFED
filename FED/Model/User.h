//
//  User.h
//  FED
//
//  Created by Nattawut Singhchai on 4/11/14.
//  Copyright (c) 2014 Anupong Boonchued. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum:NSUInteger {
    UserGenderMale,
    UserGenderFemale
}UserGender;

typedef enum:NSUInteger {
    UserExerciseFrequencyLess,
    UserExerciseFrequencyMedium,
    UserExerciseFrequencyFrequent
}UserExerciseFrequency;

@interface User : NSObject <NSCoding>
@property (nonatomic,assign) UserGender gender;
@property (nonatomic,assign) NSUInteger age;
@property (nonatomic,assign) float      weight;
@property (nonatomic,assign) float      height;
@property (nonatomic,assign) UserExerciseFrequency excerciseFequency;

-(id)initWithGender:(UserGender )gender
                age:(NSUInteger)age
             weight:(float)weight
             height:(float)height
 excerciseFrequency:(UserExerciseFrequency)frequency;

-(float)MBR;

@end
