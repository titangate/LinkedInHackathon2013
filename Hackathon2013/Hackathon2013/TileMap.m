//
//  TileMap.m
//  Hackathon2013
//
//  Created by Angela Wu on 7/12/13.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import "TileMap.h"

@implementation TileMap {
    int i;
}
- (id)init {
    self = [super init];
    if (self) {
        [TileMap loadWorldTiles];
        [self addBackgroundTiles];
    }
    return self;
}

- (void)addBackgroundTiles {
    // Tiles should already have been pre-loaded in +loadSceneAssets.
    for (SKNode *tileNode in [self backgroundTiles]) {
        [self addChild:tileNode];
    }
}


+ (void)loadWorldTiles {
    NSLog(@"Loading world tiles");
    NSDate *startDate = [NSDate date];
    
    SKTextureAtlas *tileAtlas = [SKTextureAtlas atlasNamed:@"Tiles"];
    
    sBackgroundTiles = [[NSMutableArray alloc] initWithCapacity:1024];
    for (int y = 0; y < kWorldTileDivisor; y++) {
        for (int x = 0; x < kWorldTileDivisor; x++) {
            int tileNumber = (y * kWorldTileDivisor) + x;
            SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithTexture:[tileAtlas textureNamed:@"tile2.png"]];
            CGPoint position = CGPointMake((x * kWorldTileSize) - kWorldCenter,
                                           (kWorldSize - (y * kWorldTileSize)) - kWorldCenter);
            tileNode.position = position;
            tileNode.zPosition = 1.0f;
            tileNode.blendMode = SKBlendModeReplace;
            [(NSMutableArray *)sBackgroundTiles addObject:tileNode];
        }
    }
    NSLog(@"Loaded all world tiles in %f seconds", [[NSDate date] timeIntervalSinceDate:startDate]);
}

static NSArray *sBackgroundTiles = nil;
- (NSArray *)backgroundTiles {
    return sBackgroundTiles;
}

- (BOOL) isObstacle:(CGPoint)point1 point2:(CGPoint)point2 {
    return false;
}
@end
