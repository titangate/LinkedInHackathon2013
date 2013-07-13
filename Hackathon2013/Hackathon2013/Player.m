//
//  Player.m
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-13.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import "Player.h"

@implementation Player
- (BOOL)isEnemyOf:(Player *)player {
    return player != self;
}
@end
