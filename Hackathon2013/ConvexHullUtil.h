//
//  ConvexHullUtil.h
//  Hackathon2013
//
//  Created by Angela Wu on 7/13/13.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConvexHullUtil : NSObject
int
chainHull_2D( CGPoint* P, int n, CGPoint* H );
float isLeft( CGPoint P0, CGPoint P1, CGPoint P2 );
@end
