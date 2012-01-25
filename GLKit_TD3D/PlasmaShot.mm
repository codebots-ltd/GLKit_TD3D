//
//  PlasmaShot.m
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

#import "PlasmaShot.h"
#import "ParticleEmitter.h"
#import "Camera.h"

@interface PlasmaShot () {
@private
    float timer;
    ParticleEmitter __strong *particleEmitter;
    btSphereShape *collisionSSphere;
}

- (void)initPhysics;

@end

@implementation PlasmaShot

- (id)initWithScene:(SSGameSceneController *)aGameScene usingShader:(GLKBaseEffect*)aShader {
    
    self = [super init];
    if (self) {
        
        // Hook up to the game controller that is responsible for this model
        gameSceneController = aGameScene;
        assetManager = gameSceneController.assetManager;
        
        // Set the objects initial state
        state = AbstractObjectDead;
        
        // Create the particle emitter
        particleEmitter = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"plasmaEmitter.pex" scene:gameSceneController effectShader:aShader];
        particleEmitter.active = NO;
        
        // Set up the collision physics for the plasma shot. This is a simple sphere
        [self initPhysics];
        
    }
    return self;
}

- (void)updateWithDelta:(GLfloat)aDelta {
    
    // If there is no delta value then don't bother updating
    if (aDelta == 0) return;
    
    if (state == AbstractObjectAlive) {

        // Increment a timer. If the particle is alive for more than 5 seconds then destroy it
        timer += aDelta;
        if (timer == 5000) {
            timer = 0;
            particleEmitter.active = NO;
            [self removeFromCollisionWorld:gameSceneController.collisionWorld];
        }
        
        // Update the position of the plasma shot
        self.position = GLKVector3Add(position, GLKVector3MultiplyScalar(direction, aDelta * 18));
        particleEmitter.sourcePosition = position;

    }

    // Continue to update the particle emitter as long as it's active or has particles that are still alive. This means that even after
    // the plasma shot has hit its target and is dead, particles generated during for this object will be updated until they die.
    if (particleEmitter.active || particleEmitter.particleCount > 0)
        [particleEmitter updateWithDelta:aDelta cameraFacingVector:gameSceneController.camera.facingVector];

    // When the particle emitter is not active and all particles have died then mark this object as dead so that it can be reused
    if (!particleEmitter.active && particleEmitter.particleCount == 0) {
        state = AbstractObjectDead;
    }
    
}

- (void)collidedWithObject:(SSAbstractObject*)aObject
{
    [self removeFromCollisionWorld:gameSceneController.collisionWorld];
    particleEmitter.active = NO;
}

- (void)collidedWithCollisionGroup:(short)aCollisionGroup {
    [self removeFromCollisionWorld:gameSceneController.collisionWorld];
    particleEmitter.active = NO;
}


- (void)render {
    
    // Mark the OGL commands
    glPushGroupMarkerEXT(0, "PlasmaShot");
    {
        // Only render the particles if the emitter is active or the particle count in the emitter is not 0
        if (particleEmitter.active || particleEmitter.particleCount > 0)
            [particleEmitter render];
    }
    glPopGroupMarkerEXT();
    
}

- (void)setState:(uint)newState {
    state = newState;
    
    // If the state of this object is set to alive, then also activate the particle emitter so that it starts to generate particles
    if (state == AbstractObjectAlive) {
        particleEmitter.active = YES;
        timer = 0;
    }
}

- (void)initPhysics
{
    // Create a collision object for this model
    [self createCollisionObject];
    
    // The collision group defines the type of object for this model. The collision mask defines the collision groups
    // that this collision group can collide with. This helps filter the collisions between objects to only those we
    // are interested in.    
    collisionGroup = COL_PLASMA;
    collisionMask = COL_PLAYER | COL_LAZER;
    
    // Build a simple sphere for use as the plasma shot collision object
    btSphereShape *sphereShape = new btSphereShape(0.25f);
    collisionObject->setCollisionShape((btCollisionShape*)sphereShape);
    collisionObject->setCollisionFlags(btCollisionObject::CF_CHARACTER_OBJECT);
    
}


@end
