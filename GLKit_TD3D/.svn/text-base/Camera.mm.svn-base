//
//  Camera.m
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

#import "Camera.h"
#import "SSGameSceneController.h"

#pragma mark - Private Interface

@interface Camera () {
@private
    SSGameSceneController *gameSceneController;
    GLKVector3 facingIdentityVector;
}

- (void)initPhysics;

@end

#pragma mark - Public Implementation

@implementation Camera

@synthesize facingVector;
@synthesize fieldOfView;
@synthesize aspectRatio;
@synthesize viewWidth;
@synthesize viewHeight;
@synthesize nearDistance;
@synthesize farDistance;
@synthesize projectionMatrix;
@synthesize frustumCollisionObject;

- (id)initWithGameSceneController:(SSGameSceneController *)aGameSceneController {
    self = [super init];
    if (self) {
        // Grab a reference to the game scene this camera has been created in
        gameSceneController = aGameSceneController;
        
        // Default vector for where the camera is facing e.g. into the screen
        facingIdentityVector = GLKVector3Make(0, 0, -1);
        facingVector = facingIdentityVector;
        
        // The cameras default position is at the origin
        position = GLKVector3Make(0, 0, 0);
        
        // Define the variables that will be used to create the projection matrix
        fieldOfView = GLKMathDegreesToRadians(65.0f);
        viewWidth = gameSceneController.view.bounds.size.width;
        viewHeight = gameSceneController.view.bounds.size.height;
        aspectRatio = viewWidth/viewHeight;
        nearDistance = 0.1f;
        farDistance = 500.0f;
        
        // Create a 4x4 projection matrix. This will be used by all shaders as their projection matrix
        projectionMatrix = GLKMatrix4MakePerspective(fieldOfView, aspectRatio, nearDistance, farDistance);

        // Initialize the physics object for the camera that will be used for collision detection. In this game
        // the camera is treated as the player
        [self initPhysics];
        
    }
    return self;
}

- (void)updateWithModelMatrix:(GLKMatrix4)aModelMatrix {
    
    // Update the facing vector based on the rotation matrix
    aModelMatrix =  GLKMatrix4Invert(aModelMatrix, nil);
    facingVector = GLKVector3Normalize(GLKMatrix4MultiplyVector3(aModelMatrix, facingIdentityVector));
    
}

- (void)initPhysics
{
    // Create a collision object for this model
    [self createCollisionObject];
    
    // The collision group defines the type of object for this model. The collision mask defines the collision groups
    // that this collision group can collide with. This helps filter the collisions between objects to only those we
    // are interested in.    
    collisionGroup = COL_PLAYER;
    collisionMask = COL_PLASMA;
    
    // Build a simple sphere for use as the plasma shot collision object
    btSphereShape *sphereShape = new btSphereShape(0.25f);
    collisionObject->setCollisionShape((btCollisionShape*)sphereShape);
    collisionObject->setCollisionFlags(btCollisionObject::CF_CHARACTER_OBJECT);
    
}


@end

