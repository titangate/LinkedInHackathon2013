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

- (void)setGoal:(CGPoint)goal {
    self.agent.goal = goal;
    self.agent.isMoving = YES;
}

- (CGPoint)goal {
    return self.agent.goal;
}

- (void)updateWithAgentWithDT:(float)delta {
    if (self.attackingUnit) {
        self.attackingUnit.HP -= delta;
        CGPoint position = self.position;
        CGPoint target = self.attackingUnit.position;
        SKAction *action = [SKAction rotateToAngle:atan2f(target.y - position.y, target.x - position.x) duration:0./30.0];
        [self runAction:action];
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
        self.agent.isMoving = NO;
    }
    self.position = self.agent.position;
    if (self.HP < 0) {
        [self.delegate unitKilledInBattle:self];
    }
}

- (void)setOwner:(Player *)owner {
    _player = owner;
    self.colorBlendFactor = 1.0;
    self.color = owner.color;
}

- (Player *)owner {
    return _player;
}
@end
