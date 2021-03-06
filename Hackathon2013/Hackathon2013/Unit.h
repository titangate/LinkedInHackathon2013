//
//  Unit.h
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-12.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "RVOHub.h"
#import "Player.h"

@class Unit;

@protocol UnitDelegate <NSObject>

- (void)unitEngageInBattle:(Unit *)unit withEnemyUnit:(Unit*)enemyUnit;
- (void)unitKilledInBattle:(Unit *)unit;

@end

@interface Unit : SKSpriteNode
@property (nonatomic) RVOAgent *agent;
@property (nonatomic) CGRect goal;
@property (nonatomic) Player *owner;
@property (nonatomic, weak) Unit *attackingUnit;
@property (nonatomic) float HP;
@property (nonatomic, weak) id <UnitDelegate> delegate;
@property (readonly) NSMutableDictionary *animations;
- (void)updateWithAgentWithDT:(float)delta;
- (BOOL)engageInBattle:(Unit *)unit;
+ (NSArray *)loadAnimiationFromFileName:(NSString *)baseFileName atlas:(NSString *)atlasName numberOfFrames:(NSInteger)numberOfFrames;
@end
