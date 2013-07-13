//
//  Player.m
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-13.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import "Player.h"

@implementation Player {
    NSMutableArray *_temples;
    NSMutableArray *_units;
}

- (id)init {
    self = [super init];
    if (self) {
        _temples = [[NSMutableArray alloc]init];
        _units = [[NSMutableArray alloc]init];
    }
    return self;
}

- (BOOL)isEnemyOf:(Player *)player {
    return player != self;
}


- (void)captureTemple:(Temple *)temple {
    [_temples addObject:temple];
}

- (void)loseTemple:(Temple *)temple {
    [_temples removeObject:temple];
}
@end
