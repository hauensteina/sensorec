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
    _fusionType = NONE;
    
    // UI Elements
    //==============
    [_btnFU setTitleColor:RGB(0xffffff) forState:UIControlStateNormal];
    [_btnOS setTitleColor:RGB(0xffffff) forState:UIControlStateNormal];
    
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
    
    SCNMaterial *c1Material         = [SCNMaterial material];
    c1Material.diffuse.contents     = c1;
    
    SCNMaterial *c2Material         = [SCNMaterial material];
    c2Material.diffuse.contents     = c2;
    
    SCNMaterial *c3Material         = [SCNMaterial material];
    c3Material.diffuse.contents     = c3;
    
    SCNMaterial *c4Material         = [SCNMaterial material];
    c4Material.diffuse.contents     = c4;
    
    SCNMaterial *frontMaterial      = [SCNMaterial material];
    frontMaterial.diffuse.contents  = iphoneFront;
    
    SCNMaterial *backMaterial       = [SCNMaterial material];
    backMaterial.diffuse.contents   = iphoneBack;
    
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

//------------
// Buttons
//------------
//---------------------------------
- (IBAction)btnBack:(id)sender
//---------------------------------
{
    [g_app.naviVc popViewControllerAnimated:YES];
    SensoPlex *senso = g_app.connectVc.sensoPlex;
    [senso sendString:@"qhoff"];
    [senso sendString:@"qsoff"];
}

//-----------------------------
- (IBAction)btnFU:(id)sender
//-----------------------------
{
    SensoPlex *senso = g_app.connectVc.sensoPlex;
    [senso sendString:@"qhon"];
    _corrAngle = 0;
}

//-----------------------------
- (IBAction)btnOS:(id)sender
//-----------------------------
{
    SensoPlex *senso = g_app.connectVc.sensoPlex;
    [senso sendString:@"qson"];
    _corrAngle = 0;
}

//-----------------------------
- (IBAction)btnCorr:(id)sender
//-----------------------------
{
    float rot = DEG(eulerPhi(_brickNode.rotation)) - _corrAngle;
    _corrAngle = 90.0 - rot;
}

// Set sensor fusion button colors
// These are called from ConnectVC depending on what
// type quaternions come in from the sensor.
//------------------
- (void) fusionOS
//------------------
{
    if (_fusionType != OS) {
        _fusionType = OS;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self btnCorr:nil];
            [_btnFU setTitleColor:RGB(0xffffff) forState:UIControlStateNormal];
            [_btnOS setTitleColor:RGB(0xff0000) forState:UIControlStateNormal];
        });
    }
}
//------------------
- (void) fusionFU
//------------------
{
    if (_fusionType != FU) {
        _fusionType = FU;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self btnCorr:nil];
            [_btnFU setTitleColor:RGB(0xff0000) forState:UIControlStateNormal];
            [_btnOS setTitleColor:RGB(0xffffff) forState:UIControlStateNormal];
        });
    }
}

//-------------
// Animation
//-------------

//------------------------------------------
- (void) animateQuaternion:(NSArray*)p_q
//------------------------------------------
{
    GLKQuaternion glkq;
    glkq.q[0] = [p_q[3] intValue] / (float) (1L<<14); // x
    glkq.q[1] = [p_q[1] intValue] / (float) (1L<<14); // y
    glkq.q[2] = [p_q[2] intValue] / (float) (1L<<14); // z
    glkq.q[3] = [p_q[0] intValue] / (float) (1L<<14); // w

    SCNQuaternion newOri = glk2SCN(glkq);
    _brickNode.rotation = [self correct:newOri];
} // animateQuaternion

//-------------------------------------------------
- (SCNQuaternion) correct:(SCNQuaternion) ori
//-------------------------------------------------
{
    SCNQuaternion corr = SCNVector4Make (0, 1, 0, RAD(_corrAngle));
    return SCNQuaternionMultiply (corr,ori);
} // correct


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


//-----------------------------------------------------------------------
SCNQuaternion SCNQuaternionMultiply (SCNQuaternion q1, SCNQuaternion q2)
//-----------------------------------------------------------------------
// Multiply two quaternions. This applies rotation q2 to rotation q1.
{
    GLKQuaternion q1glk = // turn q1 into a GLKQuaternion
    GLKQuaternionMakeWithAngleAndAxis (q1.w, q1.x, q1.y, q1.z);
    q1glk = GLKQuaternionNormalize (q1glk);
    GLKQuaternion q2glk = // turn q2 into a GLKQuaternion
    GLKQuaternionMakeWithAngleAndAxis (q2.w, q2.x, q2.y, q2.z);
    q2glk = GLKQuaternionNormalize (q2glk);
    GLKQuaternion resglk = GLKQuaternionMultiply (q1glk, q2glk);
    return glk2SCN (resglk);
}

//-----------------------------------
float eulerPhi (SCNQuaternion p_q)
//-----------------------------------
{
    GLKQuaternion q =
    GLKQuaternionMakeWithAngleAndAxis (p_q.w, p_q.x, p_q.y, p_q.z);
    float q0 = q.w;
    float q1 = q.x;
    float q2 = q.y;
    float q3 = q.z;
    float res =
    atan2 (2.0 * (q0*q1+q2*q3), 1.0 - 2.0 * (q1*q1+q2*q2));
    return res;
}


@end
