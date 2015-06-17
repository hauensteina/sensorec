//
//  BrickVC.m
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-06-16.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import "BrickVC.h"
#import "common.h"

#import <SceneKit/SceneKit.h>
#import <GLKit/GLKit.h>

#define DEG(x) ((x)*(180.0/M_PI))
#define RAD(x) ((x)*(M_PI/180.0))

//----------------------
@interface BrickVC ()
//----------------------
@property SCNNode *brickNode;
@end

//----------------------
@implementation BrickVC
//----------------------

//---------------------
- (void)viewDidLoad
//---------------------
{
    [super viewDidLoad];
    // Use SceneKit to show a 3D brick
    //======================================
    SCNView *sceneView = (SCNView *) self.view;
    sceneView.backgroundColor = [UIColor grayColor];
    //sceneView.allowsCameraControl = true;
    
    // Create the scene and get the root
    sceneView.scene = [SCNScene scene];
    SCNNode *root = sceneView.scene.rootNode;
    
    // Create the brick geometry and node
    SCNBox *brickGeom = [SCNBox
                         boxWithWidth:2.2
                         height:0.1
                         length:1.0
                         chamferRadius:0.05];
    _brickNode = [SCNNode nodeWithGeometry:brickGeom];
    
    UIColor *c1 = RGB (0x6a7dc1);
    UIColor *c2 = RGB (0x6d6f76);
    UIColor *c3 = RGB (0xae7b7b);
    UIColor *c4 = RGB (0x8ba782);
    
    UIImage *iphoneFront = [UIImage imageNamed:@"iphone_front.png"];
    UIImage *iphoneBack = [UIImage imageNamed:@"iphone_back.png"];
    
    SCNMaterial *c1Material              = [SCNMaterial material];
    c1Material.diffuse.contents          = c1;
    
    SCNMaterial *c2Material                = [SCNMaterial material];
    c2Material.diffuse.contents          = c2;
    
    SCNMaterial *c3Material               = [SCNMaterial material];
    c3Material.diffuse.contents          = c3;
    
    SCNMaterial *c4Material             = [SCNMaterial material];
    c4Material.diffuse.contents          = c4;
    
    SCNMaterial *frontMaterial             = [SCNMaterial material];
    frontMaterial.diffuse.contents          = iphoneFront;
    
    SCNMaterial *backMaterial            = [SCNMaterial material];
    backMaterial.diffuse.contents          = iphoneBack;
    
    _brickNode.geometry.materials =
    @[c1Material,  c2Material, c3Material,
      c4Material, frontMaterial, backMaterial];
    [root addChildNode:_brickNode];
} // viewDidLoad()

//-------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------
{
    SensoPlex *senso = g_app.connectVc.sensoPlex;
    //[senso sendString:@"qhon"];
    [senso sendString:@"qson"];
} // viewDidAppear

//---------------------------------
- (IBAction)btnBack:(id)sender
//---------------------------------
{
    [g_app.naviVc popViewControllerAnimated:YES];
    SensoPlex *senso = g_app.connectVc.sensoPlex;
    [senso sendString:@"qhoff"];
    [senso sendString:@"qsoff"];
}

//------------------------------------------
- (void) animateQuaternion:(NSArray*)p_q
//------------------------------------------
{
    GLKQuaternion glkq;
    glkq.q[0] = [p_q[2] intValue] / (float) (1L<<14); // x
    glkq.q[1] = [p_q[3] intValue] / (float) (1L<<14); // y
    glkq.q[2] = [p_q[1] intValue] / (float) (1L<<14); // z
    glkq.q[3] = [p_q[0] intValue] / (float) (1L<<14); // w

    SCNQuaternion newOri = glk2SCN(glkq);
    _brickNode.rotation = newOri;
} // animateQuaternion

//-----------------------------------------------------------------------
SCNQuaternion glk2SCN (GLKQuaternion qglk)
//-----------------------------------------------------------------------
// Make a SCNQuaternion from a GLKQuaternion
{
    GLKVector3 axis = GLKQuaternionAxis (qglk);
    float angle = GLKQuaternionAngle (qglk);
    SCNQuaternion res = SCNVector4Make (axis.x, axis.y, axis.z, angle);
    return res;
}


@end
