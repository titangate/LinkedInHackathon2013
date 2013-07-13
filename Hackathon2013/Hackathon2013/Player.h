//
//  Player.h
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-13.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@class Temple;

@interface Player : NSObject
@property (nonatomic) NSArray *temples;
@property (nonatomic) NSArray *units;
@property (nonatomic) SKColor *color;
- (BOOL)isEnemyOf:(Player *)player;
- (void)captureTemple:(Temple *)temple;
- (void)loseTemple:(Temple *)temple;
@end
