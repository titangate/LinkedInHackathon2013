//
//  RVOHub.h
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-12.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@class RVOAgent, RVOObstacle;

@interface RVOHub : NSObject
@property (nonatomic,assign) float timeStep;
- (void)update;
- (RVOAgent *)createAgentAtPosition:(CGPoint)position withRadius:(CGFloat)radius withSpeed:(CGFloat)speed;
- (void)removeAgent:(RVOAgent *)agent;
- (RVOObstacle *)createObstacleWithVerticies:(NSArray *)verticies;
- (void)removeObstacle:(RVOObstacle *)obstacle;
@property (nonatomic) NSArray *agents;
@property (nonatomic) NSArray *allAgents;
@property (nonatomic) NSArray *obstacles;
@end

@interface RVOAgent : NSObject
@property (nonatomic) CGPoint position;
@property (nonatomic, readonly) CGFloat angle;
@property (nonatomic) float speed;
@property (nonatomic, readonly) CGPoint currentVelocity;
@property (readonly) CGFloat radius;
@property (nonatomic) CGRect goal;
@property (nonatomic) NSMutableArray *goals;
@property (nonatomic) BOOL isMoving;
@property (nonatomic, readonly) NSArray *neighbours;
@property (nonatomic, assign) id controller;
- (BOOL)reachedGoal;
- (void)update;
@end

@interface RVOObstacle : SKShapeNode
@property (nonatomic, readonly) NSArray *verticies;
@end