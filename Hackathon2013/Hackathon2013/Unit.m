//
//  Unit.m
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-12.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import "Unit.h"

@implementation Unit {
    Player *_player;
}

- (BOOL)engageInBattle:(Unit *)unit {
    return YES;
}

- (void)setGoal:(CGRect)goal {
    self.agent.goal = goal;
    self.agent.isMoving = YES;
}

- (CGRect)goal {
    return self.agent.goal;
}

- (void)updateWithAgentWithDT:(float)delta {
    if (self.attackingUnit) {
        self.attackingUnit.HP -= delta;
        CGPoint position = self.position;
        CGPoint target = self.attackingUnit.position;
        SKAction *action = [SKAction rotateToAngle:atan2f(target.y - position.y, target.x - position.x) duration:0./30.0];
        [self runAction:action];
        
        if (self.attackingUnit.HP <= 0) {
            self.attackingUnit = nil;
            self.agent.isMoving = YES;
        }
    } else {
        if (!(self.agent.currentVelocity.x == 0 && self.agent.currentVelocity.y == 0)) {
            SKAction *action = [SKAction rotateToAngle:self.agent.angle duration:0./30.0];
            [self runAction:action];
        }
        NSArray *neighbours = self.agent.neighbours;
        for (RVOAgent *agent in neighbours) {
            Unit *unit = agent.controller;
            if ([unit isKindOfClass:[Unit class]]) {
                if ([unit.owner isEnemyOf:self.owner] && [unit engageInBattle:self]) {
                    self.agent.isMoving = NO;
                    [self.delegate unitEngageInBattle:self withEnemyUnit:unit];
                    self.attackingUnit = unit;
                }
            }
        }
    }
    [self.agent update];
    if ([self.agent reachedGoal]) {
        if (self.agent.goals) {
            self.goal = [[self.agent.goals objectAtIndex:0] CGRectValue];
            [self.agent.goals removeObjectAtIndex:0];
            if ([self.agent.goals count]==0) {
                self.agent.goals = nil;
            }
        } else {
            self.agent.isMoving = NO;
        }
    }
    self.position = self.agent.position;
    if (self.HP < 0) {
        [self.delegate unitKilledInBattle:self];
    }
}

- (NSMutableDictionary *)animations {
    static NSMutableDictionary *_animations;
    if (!_animations) {
        _animations = [[NSMutableDictionary alloc]init];
    }
    return _animations;
}

- (void)setOwner:(Player *)owner {
    _player = owner;
    self.colorBlendFactor = 1.0;
    self.color = owner.color;
    self.HP = 1.0;
}

- (Player *)owner {
    return _player;
}

- (void)setAttackingUnit:(Unit *)attackingUnit {
    NSString *actionKey = [@[@"fist",@"crane"] objectAtIndex:rand()%2];
    NSArray *frames = self.animations[actionKey];
    _attackingUnit = attackingUnit;
    SKAction *animAction = [self actionForKey:actionKey];
    if (animAction || [frames count] < 1) {
        return; // we already have a running animation or there aren't any frames to animate
    }
    
    [self runAction:[SKAction sequence:@[
                                         [SKAction animateWithTextures:frames timePerFrame:0.2 resize:NO restore:NO],
                                         [SKAction animateWithTextures:frames timePerFrame:100]
    ]] withKey:actionKey];
}

+ (NSArray *)loadAnimiationFromFileName:(NSString *)baseFileName atlas:(NSString *)atlasName numberOfFrames:(NSInteger)numberOfFrames {
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:numberOfFrames];
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:atlasName];
    for (int i = 0; i <= numberOfFrames; i++) {
        NSString *fileName = [NSString stringWithFormat:@"%@%d.png", baseFileName, i+1];
        SKTexture *texture = [atlas textureNamed:fileName];
        [frames addObject:texture];
    }
    
    return frames;
}
@end
