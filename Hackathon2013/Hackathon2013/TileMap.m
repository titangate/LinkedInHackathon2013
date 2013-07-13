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

+ (int)tileNumAtX:(int)x atY:(int)y{
    return (y * kWorldTileDivisor) + x;
}

+ (void)loadWorldTiles {
    NSLog(@"Loading world tiles");
    NSDate *startDate = [NSDate date];
    NSNumber *defaultTile = [NSNumber numberWithInt:2];
    SKTextureAtlas *tileAtlas = [SKTextureAtlas atlasNamed:@"Tiles"];
    sBackgroundTilesNums = [[NSMutableArray alloc] initWithCapacity:kWorldTileDivisor*kWorldTileDivisor];
    for (int y = 0; y < kWorldTileDivisor; y++) {
        for (int x = 0; x < kWorldTileDivisor; x++) {
            [(NSMutableArray *)sBackgroundTilesNums addObject:defaultTile];
        }
    }
    sBackgroundTiles = [[NSMutableArray alloc] initWithCapacity:1024];
    for (int y = 0; y < kWorldTileDivisor; y++) {
        for (int x = 0; x < kWorldTileDivisor; x++) {
            NSNumber *tileType = [sBackgroundTilesNums objectAtIndex:[self tileNumAtX:x atY:y]];
            SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithTexture:[tileAtlas textureNamed:[NSString stringWithFormat:@"tile%d.png", [tileType integerValue]]]];
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

static NSMutableArray *sBackgroundTiles = nil;
- (NSArray *)backgroundTiles {
    return sBackgroundTiles;
}

static NSMutableArray *sBackgroundTilesNums = nil;
- (NSArray *)backgroundTilesNums {
    return sBackgroundTilesNums;
}



+ (BOOL) isObstacle:(int)x atY:(int)y {
    NSNumber *tileType = [sBackgroundTilesNums objectAtIndex:[self tileNumAtX:x atY:y]];
    return [tileType integerValue]==0 || [tileType integerValue]==4;
}

+ (BOOL) isSlow:(int)x atY:(int)y {
    NSNumber *tileType = [sBackgroundTilesNums objectAtIndex:[self tileNumAtX:x atY:y]];
    return [tileType integerValue]==1 || [tileType integerValue]==3;
}

- (BOOL) makeWetAtX:(int)x atY:(int)y {
    int tileInd =[TileMap tileNumAtX:x atY:y];
    int tileType = [[sBackgroundTilesNums objectAtIndex:tileInd] integerValue];
    if(tileType<=0){
        return false;
    }
    else{
        SKTextureAtlas *tileAtlas = [SKTextureAtlas atlasNamed:@"Tiles"];
        SKSpriteNode *newNode = [sBackgroundTiles objectAtIndex:tileInd];
        newNode.texture = [tileAtlas textureNamed:[NSString stringWithFormat:@"tile%d.png", (tileType+1)]];
        [sBackgroundTilesNums replaceObjectAtIndex:tileInd withObject: [NSNumber numberWithInt:(tileType+1)]];
        return true;
    }
}

- (BOOL) makeDryAtX:(int)x atY:(int)y {
    int tileInd =[TileMap tileNumAtX:x atY:y];
    int tileType = [[sBackgroundTilesNums objectAtIndex:tileInd] integerValue];
    if(tileType>=4){
        return false;
    }
    else{
        SKTextureAtlas *tileAtlas = [SKTextureAtlas atlasNamed:@"Tiles"];
        SKSpriteNode *newNode = [sBackgroundTiles objectAtIndex:tileInd];
        newNode.texture = [tileAtlas textureNamed:[NSString stringWithFormat:@"tile%d.png", (tileType-1)]];
        [sBackgroundTilesNums replaceObjectAtIndex:tileInd withObject: [NSNumber numberWithInt:(tileType-1)]];
        return true;
    }
}

@end
