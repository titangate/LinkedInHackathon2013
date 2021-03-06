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
    NSArray *cachedNeighbours;
}
@property (nonatomic) RVOSimulator *simulator;
@property (nonatomic) NSInteger tag;
@property (nonatomic) RVOHub *hub;
@end

@interface RVOObstacle ()
@property (nonatomic) RVOSimulator *simulator;
@property (nonatomic) NSInteger tag;
- (id)initWithVerticies:(NSArray *)verticies;
@end

@interface RVOHub () {
    NSMutableArray *_agents;
    NSMutableArray *_allAgents;
    NSMutableArray *_agentReUsePool;
    NSMutableArray *_obstacles;
}
@end

@implementation RVOHub

- (id)init {
    self = [super init];
    if (self) {
        _agents = [[NSMutableArray alloc]init];
        _agentReUsePool = [[NSMutableArray alloc]init];
        _allAgents = [[NSMutableArray alloc]init];
        _obstacles = [[NSMutableArray alloc]init];
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
    RVOAgent *agent;
    if ([_agentReUsePool count] > 0) {
        agent = [_agentReUsePool lastObject];
        [_agentReUsePool removeLastObject];
        simulator->setAgentPosition(agent.tag, CGPointToVector2(position));
        simulator->setAgentRadius(agent.tag, radius);
        simulator->setAgentMaxSpeed(agent.tag, speed);
    } else {
        agent= [[RVOAgent alloc]init];
        agent.tag = agentCount;
        agent.simulator = simulator;
        simulator->addAgent(CGPointToVector2(position), radius*3, radius*2, 10.0f, 1.5f, radius, speed);
        [_agents addObject:agent];
        [_allAgents addObject:agent];
        agent.hub = self;
        agentCount++;
    }
    return agent;
}

- (void)removeAgent:(RVOAgent *)agent {
    static Vector2 middleOfNoWhere = Vector2(-10000,-10000);
    simulator->setAgentPosition(agent.tag, middleOfNoWhere);
    simulator->setAgentPrefVelocity(agent.tag, Vector2(0,0));
    [_agents removeObject:agent];
    [_agentReUsePool addObject:agent];
}

- (RVOObstacle *)createObstacleWithVerticies:(NSArray *)verticies {
    RVOObstacle *obstacle = [[RVOObstacle alloc]initWithVerticies:verticies];
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
    obstacle.tag = simulator->addObstacle(stdVerticies);
    simulator->processObstacles();
    [_obstacles addObject:obstacle];
    return obstacle;
}

- (void)removeObstacle:(RVOObstacle *)obstacle {
    //[_obstacles removeObject:obstacle];
    simulator->removeObstacle(obstacle.tag, [obstacle.verticies count]);
    simulator->processObstacles();
}

@end

@implementation RVOAgent {
    CGRect _goal;
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

- (void)setGoal:(CGRect)goal {
    _goal = goal;
}

- (CGRect)goal {
    return _goal;
}

- (CGFloat)angle {
    CGPoint velocity = self.currentVelocity;
    return atan2(velocity.y, velocity.x);
}

- (void)update {
    cachedNeighbours = nil;
    if (self.isMoving) {
        CGPoint target = CGPointMake(CGRectGetMidX(self.goal),CGRectGetMidY(self.goal));
        _simulator->setAgentPrefVelocity(self.tag, CGPointToVector2(CGPointMake(target.x - self.position.x, target.y - self.position.y)));
        // nudge
        float angle = std::rand() * 2.0f * M_PI / RAND_MAX;
		float dist = std::rand() * 0.0001f / RAND_MAX;
        
		_simulator->setAgentPrefVelocity(self.tag, _simulator->getAgentPrefVelocity(self.tag) +
		                          dist * RVO::Vector2(std::cos(angle), std::sin(angle)));
    } else {
        _simulator->setAgentPrefVelocity(self.tag, Vector2(0,0));
    }
    
}

- (BOOL)reachedGoal {
    return (CGRectContainsPoint(self.goal, self.position));
}

- (NSArray *)neighbours {
    if (!cachedNeighbours) {
        const size_t maxNumOfNeighbours = _simulator->getAgentNumAgentNeighbors(self.tag);
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for (NSInteger i = 0;i<maxNumOfNeighbours;i++) {
            const size_t neighbourTag = _simulator->getAgentAgentNeighbor(self.tag, i);
            [array addObject:[self.hub.allAgents objectAtIndex:neighbourTag]];
        }
        cachedNeighbours = array;
    }
    return cachedNeighbours;
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