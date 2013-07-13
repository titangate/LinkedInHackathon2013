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
#import "Temple.h"
#import "AIManager.h"

@interface MyScene () <UnitDelegate>

@end

@implementation MyScene {
    RVOHub *hub;
    NSMutableArray *agents;
    TileMap *tileMap;
    NSMutableArray *temples;
    NSMutableArray *markToBeRemoved;
    SKNode *world;
    CFTimeInterval lastFrameTime;
    Player *player;
    Player *enemy;
    NSTimer *timer;
    AIManager *aiManager;
}

- (void)unitKilledInBattle:(Unit *)unit {
    [markToBeRemoved addObject:unit];
}

- (void)unitEngageInBattle:(Unit *)unit withEnemyUnit:(Unit *)enemyUnit {
    
}

- (Temple *)createTempleAtLocation:(CGPoint)location {
    Temple *temple = [[Temple alloc]initWithImageNamed:@"temple"];
    temple.agent = [hub createAgentAtPosition:location withRadius:32 withSpeed:0];
    temple.agent.controller = temple;
    temple.size = CGSizeMake(64, 64);
    [world addChild:temple];
    [temples addObject:temple];
    return temple;
}

- (RVOObstacle *)addObstacle:(CGPoint *)points count:(NSInteger)count {
    NSMutableArray *array = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i<count; i++) {
        NSValue *value = [NSValue valueWithCGPoint:points[i]];
        [array addObject:value];
    }
    RVOObstacle *obstacle = [hub createObstacleWithVerticies:array];
    return obstacle;
}

- (void)initDemo {
    player = [[Player alloc]init];
    enemy = [[Player alloc]init];
    player.color = [UIColor redColor];
    enemy.color = [UIColor blueColor];
    tileMap = [[TileMap alloc] init];
    world = [[SKNode alloc]init];
    [self addChild:world];
    [world addChild:tileMap];
    //for(NSInteger i=0; i<32; i++){
        [tileMap makeDryAtX:0 atY:0];
    //}
    /*[tileMap drainAtX:16 atY:16];
    [tileMap drainAtX:16 atY:16];
    [tileMap drainAtX:16 atY:16];*/
    for (NSInteger i = 0; i<30; i++) {
        Unit *unit = [[Unit alloc]initWithImageNamed:@"Spaceship"];
        unit.agent = [hub createAgentAtPosition:CGPointMake(100+ i *32, 100) withRadius:16.0 withSpeed:48.0];
        unit.agent.controller = unit;
        unit.size = CGSizeMake(32,32);
        unit.owner = player;
        unit.delegate = self;
        [world addChild:unit];
        [agents addObject:unit];
        
        
        unit = [[Unit alloc]initWithImageNamed:@"Spaceship"];
        unit.agent = [hub createAgentAtPosition:CGPointMake(100+ i *32, 400) withRadius:16.0 withSpeed:48.0];
        unit.agent.controller = unit;
        unit.size = CGSizeMake(32,32);
        unit.owner = enemy;
        unit.delegate = self;
        [world addChild:unit];
        [agents addObject:unit];
    }
    CGPoint points[] = {
        {200,200},
        {300,200},
        {300,300},
        {200,300}
    };
    
    RVOObstacle *obstacle = [self addObstacle:points count:4];
    
    RVOObstacle *obstacle2 = [self addObstacle:(CGPoint[]){
        {500,300},
        {400,200},
        {600,300},
    } count:3];
    [world addChild:obstacle];
    [world addChild:obstacle2];
    [self createTempleAtLocation:CGPointMake(100, 100)].owner = player;
    [self createTempleAtLocation:CGPointMake(500, 500)].owner = enemy;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerTicked) userInfo:nil repeats:YES];
    aiManager = [[AIManager alloc]init];
    aiManager.temples = temples;
    aiManager.players = @[player,enemy];
    aiManager.obstacles = @[];
    aiManager.obstacles = @[obstacle,obstacle2];
}

- (void)timerTicked {
    for (Temple *temple in temples) {
        Unit *unit = [[Unit alloc]initWithImageNamed:@"Spaceship"];
        unit.agent = [hub createAgentAtPosition:temple.position withRadius:16.0 withSpeed:48.0];
        unit.agent.controller = unit;
        unit.size = CGSizeMake(32,32);
        unit.owner = temple.owner;
        unit.delegate = self;
        [world addChild:unit];
        [agents addObject:unit];
    }
    [aiManager update];
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
        temples = [[NSMutableArray alloc]init];
        markToBeRemoved = [[NSMutableArray alloc]init];
        hub = [[RVOHub alloc]init];
        hub.timeStep = 0.1;
        [self initDemo];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
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
    CFTimeInterval dt = currentTime - lastFrameTime;
    if (dt > 0.1) {
        dt = 0.1;
    }
    lastFrameTime = currentTime;
    hub.timeStep = dt;
    [hub update];
    for (Unit *unit in agents) {
        [unit updateWithAgentWithDT:dt];
    }
    for (Temple *unit in temples) {
        [unit updateWithAgentWithDT:dt];
    }
    while ([markToBeRemoved count]) {
        Unit *unit = [markToBeRemoved lastObject];
        [unit removeFromParent];
        [hub removeAgent:unit.agent];
        [agents removeObject:unit];
        [markToBeRemoved removeLastObject];
    }
}

@end
