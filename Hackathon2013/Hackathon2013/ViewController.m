//
//  ViewController.m
//  Hackathon2013
//
//  Created by Nanyi Jiang on 2013-07-12.
//  Copyright (c) 2013 Nanyi Jiang. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"

@implementation ViewController {
    UIPanGestureRecognizer *panGestureRecognizer;
    UIPinchGestureRecognizer *pinchGestureRecognizer;
    UILongPressGestureRecognizer *longPressGestureRecognizer;
    MyScene * scene;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView *skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    scene = [MyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
    panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGestureRecognzier:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchGestureRecognizer:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGestureRecognizer:)];
    [self.view addGestureRecognizer:longPressGestureRecognizer];
    
    
}

- (void)handlePanGestureRecognzier:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint offset,gestureOffset;
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            offset = scene.offset;
            gestureOffset = [gestureRecognizer translationInView:self.view];
            scene.offset = CGPointMake(offset.x + gestureOffset.x, offset.y - gestureOffset.y);
            [gestureRecognizer setTranslation:CGPointZero inView:self.view];
            break;
            
        default:
            break;
    }
}

- (void)handlePinchGestureRecognizer:(UIPinchGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateChanged:
            if (gestureRecognizer.scale < 0.6) {
                scene.mode = OP_DRAIN;
            } else if (gestureRecognizer.scale > 1.4) {
                scene.mode = OP_FILL;
            }
            break;
            
        default:
            break;
    }
}

- (void)handleLongPressGestureRecognizer:(UILongPressGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            scene.pressing = YES;
            break;
        case UIGestureRecognizerStateEnded:
            scene.pressing = NO;
        default:
            break;
    }

}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
