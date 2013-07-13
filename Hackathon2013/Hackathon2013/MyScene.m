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
    SKLabelNode *myLabel;
    CGPoint location;
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
- (void)initDemo {
    player = [[Player alloc]init];
    enemy = [[Player alloc]init];
    player.color = [UIColor redColor];
    enemy.color = [UIColor blueColor];
    tileMap = [[TileMap alloc] init];
    world = [[SKNode alloc]init];
    [self addChild:world];
    [world addChild:tileMap];
    for (NSInteger i=0; i<6; i++) {
        
        //[tileMap drainAtX:32 atY:32];
    }
    NSMutableArray *obstacles = [[NSMutableArray alloc]init];
    NSArray * obs = [tileMap getConnectedComponents];
    for(NSArray* ob in obs){
        RVOObstacle *obstacle = [hub createObstacleWithVerticies:ob];
        [obstacles addObject:obstacle];
    }
    
    [self createTempleAtLocation:CGPointMake(250, 250)].owner = player;
    [self createTempleAtLocation:CGPointMake(-250, -250)].owner = enemy;
    [self createTempleAtLocation:CGPointMake(250, -250)];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerTicked) userInfo:nil repeats:YES];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(terrainTick) userInfo:nil repeats:YES];
    aiManager = [[AIManager alloc]init];
    aiManager.temples = temples;
    aiManager.players = @[player,enemy];
    aiManager.obstacles = obstacles;
    self.mode = OP_DRAIN;
}

- (void)terrainTick {
    if (self.pressing) {
        if (self.mode == OP_DRAIN) {
            
            [tileMap drainAtX:location.x atY:location.y];
            for (RVOObstacle *ob in hub.obstacles) {
                [hub removeObstacle:ob];
            }
            
            hub.obstacles = [[NSMutableArray alloc]init];
            NSMutableArray *obstacles = [[NSMutableArray alloc]init];
            NSArray * obs = [tileMap getConnectedComponents];
            for(NSArray* ob in obs){
                RVOObstacle *obstacle = [hub createObstacleWithVerticies:ob];
                [obstacles addObject:obstacle];
            }
            
            aiManager.obstacles = obstacles;
        } else {
            
            [tileMap dropAtX:location.x atY:location.y];
            for (RVOObstacle *ob in hub.obstacles) {
                [hub removeObstacle:ob];
            }
            hub.obstacles = [[NSMutableArray alloc]init];
            NSMutableArray *obstacles = [[NSMutableArray alloc]init];
            NSArray * obs = [tileMap getConnectedComponents];
            for(NSArray* ob in obs){
                RVOObstacle *obstacle = [hub createObstacleWithVerticies:ob];
                [obstacles addObject:obstacle];
            }
            
            aiManager.obstacles = obstacles;
        }
    }
}

- (void)timerTicked {
    for (Temple *temple in temples) {
        Unit *unit = [[Unit alloc]initWithImageNamed:@"fist1.png"];
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [unit.animations setObject:[Unit loadAnimiationFromFileName:@"fist" atlas:@"fist" numberOfFrames:6] forKey:@"fist"];
            [unit.animations setObject:[Unit loadAnimiationFromFileName:@"crane" atlas:@"crane" numberOfFrames:6] forKey:@"crane"];
        });
        unit.agent = [hub createAgentAtPosition:CGPointMake(temple.position.x, temple.position.y+30) withRadius:16.0 withSpeed:48.0];
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
        
        myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Hello, World!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        agents = [[NSMutableArray alloc]init];
        temples = [[NSMutableArray alloc]init];
        markToBeRemoved = [[NSMutableArray alloc]init];
        hub = [[RVOHub alloc]init];
        hub.timeStep = 0.1;
        [self initDemo];
        [self addChild:myLabel];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    for (UITouch *touch in touches) {
        location = [touch locationInNode:world];
        location = (CGPoint){location.x/16 + 32,64-(location.y/16 + 32)};
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

- (void)setMode:(enum OPMODE)mode {
    _mode = mode;
    if (mode == OP_FILL) {
        myLabel.text = @"FILLING";
    } else {
        myLabel.text = @"DRAINING";
    }
}

@end
