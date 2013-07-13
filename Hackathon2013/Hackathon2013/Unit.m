//
//  Unit.m
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-12.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import "Unit.h"

@implementation Unit

- (void)setGoal:(CGPoint)goal {
    self.agent.goal = goal;
    self.agent.isMoving = YES;
}

- (CGPoint)goal {
    return self.agent.goal;
}

- (void)updateWithAgent {
    SKAction *action = [SKAction rotateToAngle:self.agent.angle duration:0];
    [self runAction:action];
    [self.agent update];
    if ([self.agent reachedGoal]) {
        self.agent.isMoving = NO;
    }
    self.position = self.agent.position;
}
@end
