//
//  SSViewController.h
//  GLKit_TD3D
//
// Copyright (c) 2011 71Squared
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//

#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>
#import "OpenGLCommon.h"
#import "btBulletCollisionCommon.h"

@class AssetManager;
@class Camera;

@interface SSGameSceneController : GLKViewController {
    
    // Managers
    AssetManager        *assetManager;
    
    // OpenGL
    GLuint              currentBoundTexture;
    GLuint              currentBoundVOA;
    GLKMatrix4          sceneModelMatrix;
    
    // Physics
    btCollisionWorld    *collisionWorld;
    
    // Game Objects
    Camera              *camera;
    
    // HUD Text
    IBOutlet UILabel        *shieldText;
    IBOutlet UILabel        *scoreText;
    IBOutlet UIImageView    *whiteSight;
    IBOutlet UIImageView    *redSight;
    IBOutlet UILabel        *enemyShieldText;
    IBOutlet UIImageView    *touchImage;
    
    GLKBaseEffect       *particleEmitterEffect;

    
}
    
@property (nonatomic) GLKMatrix4 sceneModelMatrix;
@property (nonatomic, strong) AssetManager *assetManager;
@property (nonatomic, assign) GLuint currentBoundTexture;
@property (nonatomic, assign) GLuint currentBoundVOA;
@property (nonatomic, strong) Camera *camera;
@property (nonatomic, strong) GLKBaseEffect *particleEmitterEffect;
@property (nonatomic) btCollisionWorld *collisionWorld;

// Causes a plasma shot object that is idle to be position at the from location so that it will then travel towards the to location
- (void)fireWeaponFrom:(GLKVector3)from to:(GLKVector3)to;

// Called when a ship has exploded passing in the location of the ship. This causes an idle emitter to be position at that
// location and run
- (void)explosionAt:(GLKVector3)aVector;


@end
