//
//  AIManager.m
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-13.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import "AIManager.h"
#import "Player.h"
#import "Temple.h"
#import "NavigationMesh.h"

@implementation AIManager {
    NavigationMesh *mesh;
}

- (void)setObstacles:(NSArray *)obstacles {
    _obstacles = obstacles;
    mesh = [[NavigationMesh alloc]initWithPolygons:obstacles];
}

- (NSArray *)availableForceForPlayer:(Player *)player aroundTemple:(Temple *)temple {
    NSInteger incentive = [self incentiveForPlayer:player forTemple:temple];
    NSMutableArray *force = [[NSMutableArray alloc]init];
    for (RVOAgent *agent in temple.agent.neighbours) {
        Unit *unit = agent.controller;
        if (unit.owner == player && !unit.attackingUnit) {
            [force addObject:unit];
        }
    }
    if (incentive >= [force count]) {
        return nil;
    }
    
    return force;
}

- (NSInteger)incentiveForPlayer:(Player *)player forTemple:(Temple *)temple {
    return temple.owner != player ? 10 : 0;
}

- (void)sendForce:(NSArray *)force ToTemple:(Temple *)temple {
    NSArray * path = [mesh findPathBetween:((Unit*)[force objectAtIndex:0]).position and:temple.position];
    for (Unit *unit in force) {
        unit.agent.goals = [path mutableCopy];
        unit.goal = [[path objectAtIndex:0]CGPointValue];
        [unit.agent.goals removeObjectAtIndex:0];
        if ([unit.agent.goals count]==0) {
            unit.agent.goals = nil;
        }
    }
}

- (void)updateForPlayer:(Player *)player {
    for (Temple *temple in player.temples) {
        NSArray *force = [self availableForceForPlayer:player aroundTemple:temple];
        NSInteger incentive = 0;
        if (force) {
            Temple *targetTemple = NULL;
            for (Temple *temple in self.temples) {
                NSInteger newIncentive = [self incentiveForPlayer:player forTemple:temple];
                if (newIncentive > incentive) {
                    newIncentive = incentive;
                    targetTemple = temple;
                }
            }
            if (targetTemple) {
                [self sendForce:force ToTemple:targetTemple];
            }
        }
    }
}

- (void)update {
    for (Player *player in self.players) {
        [self updateForPlayer:player];
    }
}
@end
