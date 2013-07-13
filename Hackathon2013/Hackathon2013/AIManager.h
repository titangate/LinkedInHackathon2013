//
//  AIManager.h
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-13.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIManager : NSObject
@property (nonatomic) NSArray *temples;
@property (nonatomic) NSArray *players;
@property (nonatomic) NSArray *obstacles;
- (void)update;
@end
