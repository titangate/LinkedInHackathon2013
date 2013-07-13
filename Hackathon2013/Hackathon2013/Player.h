//
//  Player.h
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-13.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface Player : NSObject
@property (nonatomic) SKColor *color;
- (BOOL)isEnemyOf:(Player *)player;
@end
