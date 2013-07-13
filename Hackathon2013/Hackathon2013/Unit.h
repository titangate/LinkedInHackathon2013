//
//  Unit.h
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-12.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "RVOHub.h"

@interface Unit : SKSpriteNode
@property (nonatomic) RVOAgent *agent;
@property (nonatomic) CGPoint goal;
- (void)updateWithAgent;
@end
