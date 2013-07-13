//
//  RVOHub.m
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-12.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import "RVOHub.h"
#import "RVO.h"
#import "Utils.h"
#import <coregraphics/CoreGraphics.h>

using namespace std;
using namespace RVO;

const float timestep = 0.25;

Vector2 CGPointToVector2(CGPoint point) {
    return Vector2(point.x,point.y);
}

CGPoint Vector2ToCGPoint(Vector2 point) {
    return CGPointMake(point.x(), point.y());
}

@interface RVOHub () {
    RVOSimulator *simulator;
    int agentCount;
}

@end

@interface RVOAgent () {
    RVOSimulator *simulator;
}
@property (nonatomic) NSInteger tag;
@end

@implementation RVOHub

- (id)init {
    self = [super init];
    if (self) {
        
        simulator = new RVOSimulator();
        simulator->setTimeStep(0.25);
        // default parameter of the agents
        simulator->setAgentDefaults(15.0, 10, 10.0f, 10.0f, 1.5f, 2.0f);
    }
    return self;
}

- (float)timeStep {
    return simulator->getTimeStep();
}

- (void)setTimeStep:(float)timeStep {
    simulator->setTimeStep(timeStep);
}

- (void)update {
    simulator->doStep();
}

- (RVOAgent *)createAgentAtPosition:(CGPoint)position withRadius:(CGFloat)radius withSpeed:(CGFloat)speed{
    RVOAgent *agent= [[RVOAgent alloc]init];
    agent.tag = agentCount;
    simulator->addAgent(CGPointToVector2(position), 10, 10.0f, 10.0f, 1.5f, radius, speed);
    agentCount++;
    return agent;
}

@end

@implementation RVOAgent {
    CGPoint _goal;
}

- (void)setPosition:(CGPoint)position {
    simulator->setAgentPosition(self.tag, CGPointToVector2(position));
}

- (CGPoint)position {
    return Vector2ToCGPoint(simulator->getAgentPosition(self.tag));
}

- (void)setSpeed:(float)speed {
    simulator->setAgentMaxSpeed(self.tag, speed);
}

- (float)speed {
    return simulator->getAgentMaxSpeed(self.tag);
}

- (CGPoint)currentVelocity {
    return Vector2ToCGPoint(simulator->getAgentVelocity(self.tag));
}

- (CGFloat)radius {
    return simulator->getAgentRadius(self.tag);
}

- (void)setGoal:(CGPoint)goal {
    _goal = goal;
    simulator->setAgentPrefVelocity(self.tag, CGPointToVector2(goal));
}

- (CGPoint)goal {
    return _goal;
}

- (BOOL)reachedGoal {
    CGFloat distance = distanceBetweenCGPoint(self.position, self.goal);
    return distance < self.radius * 4;
}

@end