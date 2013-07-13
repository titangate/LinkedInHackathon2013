//
//  TileMap.h
//  Hackathon2013
//
//  Created by Angela Wu on 7/12/13.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
@interface TileMap : SKNode
#define kWorldTileDivisor 64  // number of tiles
#define kWorldSize 1024       // pixel size of world (square)
#define kWorldTileSize (kWorldSize / kWorldTileDivisor)

#define kWorldCenter 512

+ (BOOL) isObstacle:(int)x atY:(int)y;
+ (BOOL) isSlow:(int)x atY:(int)y;
- (BOOL) makeWetAtX:(int)x atY:(int)y;
- (BOOL) makeDryAtX:(int)x atY:(int)y;
- (int) drainAtX:(int)x atY:(int)y;
@end
