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
}

- (void)handlePanGestureRecognzier:(UIPanGestureRecognizer *)gestureRecognzier {
    CGPoint offset,gestureOffset;
    switch (gestureRecognzier.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            offset = scene.offset;
            gestureOffset = [gestureRecognzier translationInView:self.view];
            scene.offset = CGPointMake(offset.x + gestureOffset.x, offset.y - gestureOffset.y);
            [gestureRecognzier setTranslation:CGPointZero inView:self.view];
            break;
            
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
