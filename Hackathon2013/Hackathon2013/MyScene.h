//
//  MyScene.h
//  Hackathon2013
//

//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

NS_ENUM(NSInteger, OPMODE) {
    OP_DRAIN,
    OP_FILL
};

@interface MyScene : SKScene
@property (nonatomic) CGPoint offset;
@property (nonatomic) enum OPMODE mode;
@end
