//
//  MyScene.m
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-12.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import "MyScene.h"
#import "RVOHub.h"
#import "Unit.h"
#import "TileMap.h"

@implementation MyScene {
    RVOHub *hub;
    NSMutableArray *agents;
    TileMap *tileMap;
    SKNode *world;
}

- (void)initDemo {
    tileMap = [[TileMap alloc] init];
    world = [[SKNode alloc]init];
    [self addChild:world];
    [world addChild:tileMap];
    for(NSInteger i=0; i<32; i++){
        //for(NSInteger j=0; j<32; j++)
        [tileMap makeDryAtX:i atY:31-i];
    }
    for (NSInteger i = 0; i<30; i++) {
        Unit *unit = [[Unit alloc]initWithImageNamed:@"Spaceship"];
        unit.agent = [hub createAgentAtPosition:CGPointMake(100+ i *32, 100) withRadius:16.0 withSpeed:48.0];
        unit.size = CGSizeMake(32,32);
        
        [world addChild:unit];
        [agents addObject:unit];
    }
    CGPoint points[] = {
        {100,100},
        {300,100},
        {150,300}
    };
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i<3; i++) {
        NSValue *value = [NSValue valueWithCGPoint:points[i]];
        [array addObject:value];
    }
    RVOObstacle *obstacle = [hub createObstacleWithVerticies:array];
    [world addChild:obstacle];
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        world = [[SKNode alloc]init];
        [self addChild:world];
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Hello, World!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        [world addChild:myLabel];
        agents = [[NSMutableArray alloc]init];
        hub = [[RVOHub alloc]init];
        hub.timeStep = 0.1;
        [self initDemo];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    for (NSInteger i = 0; i<2; i++) {
        Unit *unit = [agents objectAtIndex:0];
        [unit removeFromParent];
        [hub removeAgent:unit.agent];
        [agents removeObject:unit];
    }
    if ([hub.obstacles count]) {
        RVOObstacle *obstacle = [hub.obstacles objectAtIndex:0];
        [hub removeObstacle:obstacle];
        [obstacle removeFromParent];
    }
    Unit *unit = [[Unit alloc]initWithImageNamed:@"Spaceship"];
    unit.agent = [hub createAgentAtPosition:CGPointMake(100, 100) withRadius:16.0 withSpeed:48.0];
    unit.size = CGSizeMake(32,32);
    
    [world addChild:unit];
    [agents addObject:unit];
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:world];
        
        for (Unit *unit in agents) {
            unit.goal = location;
        }
    }
}

- (CGPoint)offset {
    return world.position;
}

- (void)setOffset:(CGPoint)offset {
    world.position = offset;
}

-(void)update:(CFTimeInterval)currentTime {
    [hub update];
    for (Unit *unit in agents) {
        [unit updateWithAgent];
    }
}

@end
