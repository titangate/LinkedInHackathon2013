//
//  NavigationMesh.m
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-13.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import "NavigationMesh.h"
#import "RVOSimulator.h"
#import "RVOHub.h"
#include <queue>
#include <map>
using namespace std;
using namespace RVO;

typedef struct {
    int x1,y1,x2,y2;
}intRect;

@implementation NavigationMesh {
    NSMutableArray *horizontalDivider;
    NSMutableArray *verticalDivider;
    NSMutableArray *mesh;
}

- (CGRect)findAABB:(NSArray *)polygon {
    CGFloat minx, miny, maxx, maxy;
    BOOL uninit=true;
    CGRect rect;
    for (NSValue *value in polygon) {
        [value getValue:&rect];
        if (uninit){
            uninit=false;
            minx=rect.origin.x;
            miny=rect.origin.y;//origin is top left corner right?, and coordinates are 0,0 in top left?
            maxx=rect.origin.x+rect.size.width;
            maxy=rect.origin.y+rect.size.height;
        }
        else{
            if(minx>rect.origin.x){
                minx=rect.origin.x;
            }
            if(miny>rect.origin.y){
                miny=rect.origin.y;
            }
            if(maxx<rect.origin.x+rect.size.width){
                maxx=rect.origin.x+rect.size.width;
            }
            if(maxy<rect.origin.y+rect.size.height){
                maxy=rect.origin.y+rect.size.height;
            }
        }
    }
    return CGRectMake (minx, miny, maxx-minx, maxy-miny);
}

- (NSInteger)findNearestHorizontalIndex:(CGFloat)horz {
    NSInteger index = 0;
    while (index < [horizontalDivider count] && horz > [[horizontalDivider objectAtIndex:index] floatValue]) {
        index ++;
    }
    return index;
}

- (NSInteger)findNearestVerticalIndex:(CGFloat)vert {
    NSInteger index = 0;
    while (index < [verticalDivider count] && vert > [[verticalDivider objectAtIndex:index] floatValue]) {
        index ++;
    }
    return index;
}

- (id)initWithPolygons:(NSArray *)polygons {
    self = [super init];
    NSMutableArray *aabbs = [[NSMutableArray alloc]init];
    if (self) {
        horizontalDivider = [[NSMutableArray alloc]init];
        verticalDivider = [[NSMutableArray alloc]init];
        for (RVOObstacle *polygon in polygons) {
            CGRect aabb = [self findAABB:polygon.verticies];
            NSValue *value = [NSValue valueWithCGRect:aabb];
            [aabbs addObject:value];
            NSArray *horz = @[[NSNumber numberWithInt:aabb.origin.x],[NSNumber numberWithInt:aabb.size.width + aabb.origin.x]];
            for (NSNumber *number in horz) {
                if (![horizontalDivider containsObject:number]) {
                    [horizontalDivider addObject:number];
                }
            }
            NSArray *vert = @[[NSNumber numberWithInt:aabb.origin.y],[NSNumber numberWithInt:aabb.origin.y + aabb.size.height]];
            for (NSNumber *number in vert) {
                if (![verticalDivider containsObject:number]) {
                    [verticalDivider addObject:number];
                }
            }
        }
        mesh = [[NSMutableArray alloc]initWithCapacity:1024];
        for (NSInteger i = 0; i<1024; i++) {
            [mesh addObject:[NSNumber numberWithBool:NO]];
        }
        for (NSValue *value in aabbs) {
            CGRect rect;
            [value getValue:&rect];
            NSInteger xOffset = [horizontalDivider indexOfObject:[NSNumber numberWithInt:rect.origin.x]];
            NSInteger yOffset = [verticalDivider indexOfObject:[NSNumber numberWithInt:rect.origin.y]];
            
            for (NSInteger x = 0; x<[horizontalDivider indexOfObject:[NSNumber numberWithInt:rect.origin.x + rect.size.width]]; x++) {
                for (NSInteger y = 0; y<[verticalDivider indexOfObject:[NSNumber numberWithInt:rect.origin.y + rect.size.height]]; y++) {
                    NSInteger idx = (y+yOffset)*32+x+xOffset;
                    [mesh setObject:[NSNumber numberWithBool:YES] atIndexedSubscript:idx];
                }
            }
        }
    }
    return self;
}

- (NSArray *)findPathBetween:(CGPoint)begin and:(CGPoint)end {
    NSInteger x1 = [self findNearestHorizontalIndex:begin.x];
    NSInteger y1 = [self findNearestVerticalIndex:begin.y];
    NSInteger x2 = [self findNearestHorizontalIndex:end.x];
    NSInteger y2 = [self findNearestVerticalIndex:end.y];
    NSMutableArray *path = [[NSMutableArray alloc]init];
    map<Vector2, Vector2> from;
    map<Vector2, BOOL> visited;
    deque<Vector2> openset;
    openset.push_back((Vector2){x1,y1});
    while (!openset.empty()) {
        Vector2 point = openset.front();
        openset.pop_front();
        if (visited.find(point)!=visited.end()) {
            continue;
        }
        visited[point] = YES;
        if (point.x() == x2 && point.y() == y2) {
            [horizontalDivider insertObject:[NSNumber numberWithFloat:0] atIndex:0];
            [verticalDivider insertObject:[NSNumber numberWithFloat:0] atIndex:0];
            while (from.find(point) != from.end()) {
                int x = point.x();
                int y = point.y();
                CGSize size;
                if (x == [horizontalDivider count]-1) {
                    size.width = 100;
                } else {
                    size.width = [[horizontalDivider objectAtIndex:x+1]floatValue] - [[horizontalDivider objectAtIndex:x]floatValue];
                }
                if (y == [verticalDivider count]-1) {
                    size.height = 100;
                } else {
                    size.height = [[verticalDivider objectAtIndex:y+1]floatValue] - [[verticalDivider objectAtIndex:y]floatValue];
                }
                [path addObject:[NSValue valueWithCGRect:(CGRect){.origin = CGPointMake([[horizontalDivider objectAtIndex:x]floatValue],[[verticalDivider objectAtIndex:y]floatValue]),.size = size}]];
                point = from[point];
            }
            //[path setObject:[NSValue valueWithCGPoint:begin] atIndexedSubscript:0];
            //[path setObject:[NSValue valueWithCGPoint:end] atIndexedSubscript:[path count]-1];
            return path;
        }
        if (point.x() > 0) {
            Vector2 point2(point.x()-1,point.y());
            if (visited.find(point2)==visited.end()) {
                from[point2] = point;
                openset.push_back(point2);
            }
        }
        if (point.y() > 0) {
            Vector2 point2(point.x(),point.y()-1);
            if (visited.find(point2)==visited.end()) {
                from[point2] = point;
                openset.push_back(point2);
            }
        }
        if (point.x() < [horizontalDivider count]+1) {
            Vector2 point2(point.x()+1,point.y());
            if (visited.find(point2)==visited.end()) {
                from[point2] = point;
                openset.push_back(point2);
            }
        }
        if (point.y() < [verticalDivider count]+1) {
            Vector2 point2(point.x(),point.y()+1);
            if (visited.find(point2)==visited.end()) {
                from[point2] = point;
                openset.push_back(point2);
            }
        }
    }
    return nil;
}


@end
