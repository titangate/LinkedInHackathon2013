//
//  Temple.m
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-13.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import "Temple.h"

@implementation Temple {
    float _dominationFactor;
}

- (BOOL)engageInBattle:(Unit *)unit {
    return NO;
}

- (void)updateWithAgentWithDT:(float)delta {
    [self.agent update];
    NSArray *neighbours = self.agent.neighbours;
    for (RVOAgent *agent in neighbours) {
        Unit *unit = agent.controller;
        if ([unit isKindOfClass:[Unit class]]) {
            if ([unit.owner isEnemyOf:self.owner]) {
                self.dominationFactor -= delta * 0.1;
                if (self.dominationFactor < 0) {
                    self.dominationFactor = -self.dominationFactor;
                    self.owner = unit.owner;
                }
            } else {
                self.dominationFactor += delta * 0.1;
            }
        }
    }
    if (self.dominationFactor > 1) {
        self.dominationFactor = 1;
    }
    self.position = self.agent.position;
}

- (void)setDominationFactor:(float)dominationFactor {
    _dominationFactor = dominationFactor;
    if (!self.owner) {
        return;
    }
    CGFloat *oldComponents = (CGFloat *)CGColorGetComponents([self.owner.color CGColor]);
    self.color = [SKColor colorWithRed:oldComponents[0]*dominationFactor green:oldComponents[1]*dominationFactor blue:oldComponents[2]*dominationFactor alpha:1.0];
}

- (float)dominationFactor {
    return _dominationFactor;
}

- (void)setOwner:(Player *)owner {
    if (self.owner != owner) {
        Player *oldOwner = self.owner;
        Player *newOwner = owner;
        [oldOwner loseTemple:self];
        [newOwner captureTemple:self];
    }
    [super setOwner:owner];
}

@end
