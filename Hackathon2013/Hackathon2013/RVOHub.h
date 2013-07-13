//
//  RVOHub.h
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-12.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@class RVOAgent;

@interface RVOHub : NSObject
@property (nonatomic,assign) float timeStep;
- (void)update;
- (RVOAgent *)createAgentAtPosition:(CGPoint)position withRadius:(CGFloat)radius withSpeed:(CGFloat)speed;
@end

@interface RVOAgent : NSObject
@property (nonatomic) CGPoint position;
@property (nonatomic) CGFloat angle;
@property (nonatomic) float speed;
@property (nonatomic, readonly) CGPoint currentVelocity;
@property (readonly) CGFloat radius;
@property (nonatomic) CGPoint goal;
- (BOOL)reachedGoal;
@end