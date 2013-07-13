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
    int obstacleCount;
}

@end

@interface RVOAgent () {
}
@property (nonatomic) RVOSimulator *simulator;
@property (nonatomic) NSInteger tag;
@end

@interface RVOObstacle ()
@property (nonatomic) RVOSimulator *simulator;
@property (nonatomic) NSInteger tag;
- (id)initWithVerticies:(NSArray *)verticies;
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
    agent.simulator = simulator;
    simulator->addAgent(CGPointToVector2(position), radius*2, 10.0f, 10.0f, 1.5f, radius, speed);
    agentCount++;
    return agent;
}

- (RVOObstacle *)createObstacleWithVerticies:(NSArray *)verticies {
    RVOObstacle *obstacle = [[RVOObstacle alloc]initWithVerticies:verticies];
    obstacle.tag = obstacleCount;
    obstacle.simulator = simulator;
    obstacle.lineWidth = 1.0;
    obstacle.glowWidth = 2.0;
    obstacle.strokeColor = [SKColor colorWithWhite:1 alpha:1];
    std::vector<Vector2> stdVerticies;
    for (NSValue *value in verticies) {
        CGPoint point;
        [value getValue:&point];
        stdVerticies.push_back(CGPointToVector2(point));
    }
    simulator->addObstacle(stdVerticies);
    obstacleCount++;
    simulator->processObstacles();
    return obstacle;
}

@end

@implementation RVOAgent {
    CGPoint _goal;
}

- (void)setPosition:(CGPoint)position {
    _simulator->setAgentPosition(self.tag, CGPointToVector2(position));
}

- (CGPoint)position {
    return Vector2ToCGPoint(_simulator->getAgentPosition(self.tag));
}

- (void)setSpeed:(float)speed {
    _simulator->setAgentMaxSpeed(self.tag, speed);
}

- (float)speed {
    return _simulator->getAgentMaxSpeed(self.tag);
}

- (CGPoint)currentVelocity {
    return Vector2ToCGPoint(_simulator->getAgentVelocity(self.tag));
}

- (CGFloat)radius {
    return _simulator->getAgentRadius(self.tag);
}

- (void)setGoal:(CGPoint)goal {
    _goal = goal;
}

- (CGPoint)goal {
    return _goal;
}

- (CGFloat)angle {
    CGPoint velocity = self.currentVelocity;
    return atan2(velocity.y, velocity.x);
}

- (void)update {
    if (self.isMoving) {
        _simulator->setAgentPrefVelocity(self.tag, CGPointToVector2(CGPointMake(self.goal.x - self.position.x, self.goal.y - self.position.y)));
    } else {
        _simulator->setAgentPrefVelocity(self.tag, Vector2(0,0));
    }
    
}

- (BOOL)reachedGoal {
    CGFloat distance = distanceBetweenCGPoint(self.position, self.goal);
    return distance < self.radius * 4;
}

@end

@implementation RVOObstacle

- (id)initWithVerticies:(NSArray *)verticies {
    self = [super init];
    if (self) {
        _verticies = verticies;
        CGPath *path = CGPathCreateMutable();
        CGPoint point, startpoint;
        [(NSValue *)[verticies objectAtIndex:0] getValue:&startpoint];
        CGPathMoveToPoint (path, NULL, startpoint.x, startpoint.y);
        for (NSInteger k = 1; k < [verticies count]; k++) {
            [(NSValue *)[verticies objectAtIndex:k] getValue:&point];
            CGPathAddLineToPoint (path, NULL, point.x, point.y);
        }
        CGPathAddLineToPoint (path, NULL, startpoint.x, startpoint.y);
        self.path = path;
    }
    return self;
}

@end