//
//  TileMap.m
//  Hackathon2013
//
//  Created by Angela Wu on 7/12/13.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import "TileMap.h"

@implementation TileMap {
}
- (id)init {
    self = [super init];
    sTileColors =[[NSMutableArray alloc] initWithCapacity:5];
    [(NSMutableArray *)sTileColors addObject:[UIColor redColor]];
    [(NSMutableArray *)sTileColors addObject:[UIColor orangeColor]];
    [(NSMutableArray *)sTileColors addObject:[UIColor yellowColor]];
    [(NSMutableArray *)sTileColors addObject:[UIColor greenColor]];
    [(NSMutableArray *)sTileColors addObject:[UIColor blueColor]];
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
    //SKTextureAtlas *tileAtlas = [SKTextureAtlas atlasNamed:@"Tiles"];
    sBackgroundTilesNums = [[NSMutableArray alloc] initWithCapacity:kWorldTileDivisor*kWorldTileDivisor];
    for (int y = 0; y < kWorldTileDivisor; y++) {
        for (int x = 0; x < kWorldTileDivisor; x++) {
            [(NSMutableArray *)sBackgroundTilesNums addObject:defaultTile];
        }
    }
    sBackgroundTiles = [[NSMutableArray alloc] initWithCapacity:kWorldTileDivisor*kWorldTileDivisor];
    for (int y = 0; y < kWorldTileDivisor; y++) {
        for (int x = 0; x < kWorldTileDivisor; x++) {
            NSNumber *tileType = [sBackgroundTilesNums objectAtIndex:[self tileNumAtX:x atY:y]];
            SKSpriteNode *tileNode = [[SKSpriteNode alloc]initWithColor: [sTileColors objectAtIndex: [tileType integerValue]] size: CGSizeMake(kWorldTileSize, kWorldTileSize)];
            //[SKSpriteNode spriteNodeWithTexture:[tileAtlas textureNamed:[NSString stringWithFormat:@"tile%d.png", [tileType integerValue]]]];
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

static NSArray *sTileColors = nil;
- (NSArray *)tileColors {
    return sTileColors;
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
    if(tileType>=0){
        return false;
    }
    else{
        //SKTextureAtlas *tileAtlas = [SKTextureAtlas atlasNamed:@"Tiles"];
        SKSpriteNode *newNode = [sBackgroundTiles objectAtIndex:tileInd];
        newNode.color=[sTileColors objectAtIndex: tileType+1];
        //newNode.texture = [tileAtlas textureNamed:[NSString stringWithFormat:@"tile%d.png", (tileType+1)]];
        [sBackgroundTilesNums replaceObjectAtIndex:tileInd withObject: [NSNumber numberWithInt:(tileType+1)]];
        return true;
    }
}

- (BOOL) makeDryAtX:(int)x atY:(int)y {
    int tileInd =[TileMap tileNumAtX:x atY:y];
    int tileType = [[sBackgroundTilesNums objectAtIndex:tileInd] integerValue];
    if(tileType<=0){
        return false;
    }
    else{
        //SKTextureAtlas *tileAtlas = [SKTextureAtlas atlasNamed:@"Tiles"];
        SKSpriteNode *newNode = [sBackgroundTiles objectAtIndex:tileInd];
        newNode.color=[sTileColors objectAtIndex: tileType-1];
        //newNode.texture = [tileAtlas textureNamed:[NSString stringWithFormat:@"tile%d.png", (tileType-1)]];
        [sBackgroundTilesNums replaceObjectAtIndex:tileInd withObject: [NSNumber numberWithInt:(tileType-1)]];
        return true;
    }
}

- (BOOL) isWettestAtX:(int)x atY:(int)y {
    int tileInd = [TileMap tileNumAtX:x atY:y];
    int cellWetness = [[sBackgroundTilesNums objectAtIndex:tileInd] integerValue];
    for(int i=x-1; i<=x+1; i++){
        for(int j=y-1; j<=y+1; j++){
            if(i>=0 && i<=kWorldTileDivisor && j>=0 && j<=kWorldTileDivisor){
                int tileInd = [TileMap tileNumAtX:i atY:j];
                int neighborWetness = [[sBackgroundTilesNums objectAtIndex:tileInd] integerValue];
                if(neighborWetness>cellWetness){
                    return false;
                }
            }
        }
    }
    return true;
}

- (BOOL) isDryestAtX:(int)x atY:(int)y {
    int tileInd = [TileMap tileNumAtX:x atY:y];
    int cellWetness = [[sBackgroundTilesNums objectAtIndex:tileInd] integerValue];
    for(int i=x-1; i<=x+1; i++){
        for(int j=y-1; j<=y+1; j++){
            if(i>=0 && i<=kWorldTileDivisor && j>=0 && j<=kWorldTileDivisor){
                int tileInd = [TileMap tileNumAtX:i atY:j];
                int neighborWetness = [[sBackgroundTilesNums objectAtIndex:tileInd] integerValue];
                if(neighborWetness<cellWetness){
                    return false;
                }
            }
        }
    }
    return true;
}

- (int) drainAtX:(int)x atY:(int)y {
    if ([self isWettestAtX:x atY:y]){
        if([self makeDryAtX:x atY:y]){
            return 1;
        }
        else{
            return 0;
        }
    }
    else{
        int sum=0;
        int tileInd = [TileMap tileNumAtX:x atY:y];
        int cellWetness = [[sBackgroundTilesNums objectAtIndex:tileInd] integerValue];
        for(int i=x-1; i<=x+1; i++){
            for(int j=y-1; j<=y+1; j++){
                if(i>=0 && i<=kWorldTileDivisor && j>=0 && j<=kWorldTileDivisor){
                    int tileInd = [TileMap tileNumAtX:i atY:j];
                    int neighborWetness = [[sBackgroundTilesNums objectAtIndex:tileInd] integerValue];
                    if(neighborWetness>cellWetness){
                        sum += [self drainAtX:i atY:j];
                    }
                }
            }
        }
        return sum;
    }
}

//not tested
- (int) dropAtX:(int)x atY:(int)y {
    if ([self isDryestAtX:x atY:y]){
        if([self makeWetAtX:x atY:y]){
            return 1;
        }
        else{
            return 0;
        }
    }
    else{
        int sum=0;
        int tileInd = [TileMap tileNumAtX:x atY:y];
        int cellWetness = [[sBackgroundTilesNums objectAtIndex:tileInd] integerValue];
        for(int i=x-1; i<=x+1; i++){
            for(int j=y-1; j<=y+1; j++){
                if(i>=0 && i<=kWorldTileDivisor && j>=0 && j<=kWorldTileDivisor){
                    int tileInd = [TileMap tileNumAtX:i atY:j];
                    int neighborWetness = [[sBackgroundTilesNums objectAtIndex:tileInd] integerValue];
                    if(neighborWetness<cellWetness){
                        sum += [self dropAtX:i atY:j];
                    }
                }
            }
        }
        return sum;
    }
}

//returns array of arrays of connected points that are obstacles
- (NSArray *) getConnectedComponents{
    NSMutableArray *unexplored = [[NSMutableArray alloc] initWithCapacity:kWorldTileDivisor*kWorldTileDivisor];
    NSMutableArray *res = [[NSMutableArray alloc] initWithCapacity:4];
    for(int i=0; i<kWorldTileDivisor; i++){
        for(int j=0; j<kWorldTileDivisor; j++){
            CGPoint p = CGPointMake(i, j);
            NSValue* v = [NSValue valueWithCGPoint:p];
            [(NSMutableArray *)unexplored addObject: v];
        }
    }
    while([(NSMutableArray*)unexplored count]>0){
        CGPoint p;
        [[unexplored objectAtIndex:0] getValue: &p];
        [unexplored removeObjectAtIndex:0];
        if([TileMap isObstacle: p.x atY:p.y]){
            [res addObject: [TileMap calcConnCompAtX:p.x atY: p.y withUnEx: unexplored]];
        }
    }
    NSMutableArray *finalRes = [[NSMutableArray alloc] initWithCapacity:4];
    for(NSArray* a in res){
        NSMutableArray* newA = [[NSMutableArray alloc] initWithCapacity:4];
        for(NSValue* v in a){
            CGPoint p;
            [v getValue: &p];
            CGPoint position = CGPointMake((p.x * kWorldTileSize) - kWorldCenter,
                                           (kWorldSize - (p.y * kWorldTileSize)) - kWorldCenter);
            [newA addObject:[NSValue valueWithCGPoint:position]];
        }
        [finalRes addObject:newA];
    }
    return finalRes;
}

+ (NSArray*) calcConnCompAtX:(int)x atY:(int)y withUnEx: (NSMutableArray*)unexplored{
    NSMutableArray *res =[[NSMutableArray alloc] initWithCapacity:10];
    NSValue* v =[NSValue valueWithCGPoint:CGPointMake(x, y)];
    [res addObject:v]; //add starting point
    for(int i=x-1; i<=x+1; i++){
        for(int j=y-1; j<=y+1; j++){
            if(i>=0 && i<=kWorldTileDivisor && j>=0 && j<=kWorldTileDivisor){
                NSValue* neigh = [NSValue valueWithCGPoint:CGPointMake(i, j)];
                int index = [unexplored indexOfObject:neigh];
                if(index !=NSNotFound){
                    [unexplored removeObjectAtIndex:index];
                    if([TileMap isObstacle:i atY:j]){
                        [res addObjectsFromArray: [TileMap calcConnCompAtX:i atY:j withUnEx:unexplored]];
                    }
                }
                    
            }
        }
    }
    return res;
}
@end
