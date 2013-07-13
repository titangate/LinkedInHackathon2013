//
//  ConvexHullUtil.m
//  Hackathon2013
//
//  Created by Angela Wu on 7/13/13.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import "ConvexHullUtil.h"

@implementation ConvexHullUtil
// Copyright 2001 softSurfer, 2012 Dan Sunday
// This code may be freely used and modified for any purpose
// providing that this copyright notice is included with it.
// SoftSurfer makes no warranty for this code, and cannot be held
// liable for any real or imagined damage resulting from its use.
// Users of this code must verify correctness for their application.


// Assume that a class is already given for the object:
//    Point with coordinates {float x, y;}
//===================================================================


// isLeft(): tests if a point is Left|On|Right of an infinite line.
//    Input:  three points P0, P1, and P2
//    Return: >0 for P2 left of the line through P0 and P1
//            =0 for P2 on the line
//            <0 for P2 right of the line
//    See: Algorithm 1 on Area of Triangles
inline float
isLeft( CGPoint P0, CGPoint P1, CGPoint P2 )
{
    return (P1.x - P0.x)*(P2.y - P0.y) - (P2.x - P0.x)*(P1.y - P0.y);
}
//===================================================================


// chainHull_2D(): Andrew's monotone chain 2D convex hull algorithm
//     Input:  P[] = an array of 2D points
//                  presorted by increasing x and y-coordinates
//             n =  the number of points in P[]
//     Output: H[] = an array of the convex hull vertices (max is n)
//     Return: the number of points in H[]
int
chainHull_2D( CGPoint* P, int n, CGPoint* H )
{
    // the output array H[] will be used as the stack
    int    bot=0, top=(-1);   // indices for bottom and top of the stack
    int    i;                 // array scan index
    
    // Get the indices of points with min x-coord and min|max y-coord
    int minmin = 0, minmax;
    float xmin = P[0].x;
    for (i=1; i<n; i++)
        if (P[i].x != xmin) break;
    minmax = i-1;
    if (minmax == n-1) {       // degenerate case: all x-coords == xmin
        H[++top] = P[minmin];
        if (P[minmax].y != P[minmin].y) // a  nontrivial segment
            H[++top] =  P[minmax];
        H[++top] = P[minmin];            // add polygon endpoint
        return top+1;
    }
    
    // Get the indices of points with max x-coord and min|max y-coord
    int maxmin, maxmax = n-1;
    float xmax = P[n-1].x;
    for (i=n-2; i>=0; i--)
        if (P[i].x != xmax) break;
    maxmin = i+1;
    
    // Compute the lower hull on the stack H
    H[++top] = P[minmin];      // push  minmin point onto stack
    i = minmax;
    while (++i <= maxmin)
    {
        // the lower line joins P[minmin]  with P[maxmin]
        if (isLeft( P[minmin], P[maxmin], P[i])  >= 0 && i < maxmin)
            continue;           // ignore P[i] above or on the lower line
        
        while (top > 0)         // there are at least 2 points on the stack
        {
            // test if  P[i] is left of the line at the stack top
            if (isLeft(  H[top-1], H[top], P[i]) > 0)
                break;         // P[i] is a new hull  vertex
            else
                top--;         // pop top point off  stack
        }
        H[++top] = P[i];        // push P[i] onto stack
    }
    
    // Next, compute the upper hull on the stack H above  the bottom hull
    if (maxmax != maxmin)      // if  distinct xmax points
        H[++top] = P[maxmax];  // push maxmax point onto stack
    bot = top;                  // the bottom point of the upper hull stack
    i = maxmin;
    while (--i >= minmax)
    {
        // the upper line joins P[maxmax]  with P[minmax]
        if (isLeft( P[maxmax], P[minmax], P[i])  >= 0 && i > minmax)
            continue;           // ignore P[i] below or on the upper line
        
        while (top > bot)     // at least 2 points on the upper stack
        {
            // test if  P[i] is left of the line at the stack top
            if (isLeft(  H[top-1], H[top], P[i]) > 0)
                break;         // P[i] is a new hull  vertex
            else
                top--;         // pop top point off  stack
        }
        H[++top] = P[i];        // push P[i] onto stack
    }
    if (minmax != minmin)
        H[++top] = P[minmin];  // push  joining endpoint onto stack
    
    return top+1;
}

void quicksortInPlace(NSMutableArray *array, const long first, const long last) {
    if (first >= last) return;
    CGPoint *pivot = (__bridge CGPoint *)(array[(first + last) / 2]);
    long left = first;
    long right = last;
    while (left <= right) {
        CGPoint* leftPoint = (__bridge CGPoint *)(array[left]);
        while (compareTo(*leftPoint, *pivot)==-1){ //isLessThan = compareTo(array[left], pivot)==-1
            left++;
            leftPoint =(__bridge CGPoint *)(array[left]);
        }
        CGPoint* rightPoint = (__bridge CGPoint *)(array[right]);
        while (compareTo(*rightPoint, *pivot)) {//right isGreaterThan pivot= compareTo(array[right], pivot)==1
            right--;
            rightPoint =(__bridge CGPoint *)(array[right]);
        }
        if (left <= right)
            [array exchangeObjectAtIndex:left++ withObjectAtIndex:right--];
    }
    quicksortInPlace(array, first, right);
    quicksortInPlace(array, left, last);
}

NSArray* quicksort(NSArray *unsorted) {
    NSMutableArray *a = [NSMutableArray arrayWithArray:unsorted];
    quicksortInPlace(a, 0, a.count - 1);
    return a;
}

//returns 1 if P0>P1, 0 if equal, -1 if P0<P1
int compareTo (CGPoint P0, CGPoint P1){
    if (P0.x>P1.x){
        return 1;
    }
    else if (P0.x<P1.x){
        return -1;
    }
    else {
        if (P0.y>P1.y){
            return 1;
        }
        else if (P0.y<P1.y){
            return -1;
        }
        else{
            return 0;
        }
    }
}

@end
