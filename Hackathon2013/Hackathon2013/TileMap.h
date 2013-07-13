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
#define kWorldTileDivisor 32  // number of tiles
#define kWorldSize 4096       // pixel size of world (square)
#define kWorldTileSize (kWorldSize / kWorldTileDivisor)

#define kWorldCenter 2048

- (BOOL) isObstacle:(CGPoint)point1 point2:(CGPoint)point2;
@end
