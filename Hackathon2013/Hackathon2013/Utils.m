//
//  Utils.m
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-12.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import "Utils.h"
#import <math.h>

CGFloat distanceBetweenCGPoint(CGPoint point1,CGPoint point2) {
    float dx = point1.x - point2.x;
    float dy = point1.y - point2.y;
    return sqrtf(dx*dx+dy*dy);
}