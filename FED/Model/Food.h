//
//  Food.h
//  FED
//
//  Created by Nattawut Singhchai on 4/11/14.
//  Copyright (c) 2014 Anupong Boonchued. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Food : NSObject<NSCoding>
@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) float energy;
-(id)initWithDictionary:(NSDictionary *)dictionary;
-(id)initWithCoder:(NSCoder *)aDecoder;
@end
