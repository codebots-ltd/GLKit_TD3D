//
//  EmenyFighter.m
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

#import "EnemyBomber.h"
#import "AssetManager.h"
#import "EnemyBomberModel.h"
#import "SSGameSceneController.h"
#import "Camera.h"

@interface EnemyBomber () {
@private
    GLKVector3 steeringForce;       // Steering force to be applied during an update
    GLfloat maxSteeringForce;       // Max amount the ship can turn
    GLfloat maxVelocity;            // Max speed of the ship
    GLKVector3 waypoint;            // The location the ship is trying to reach
    GLint waypointDistance;         // How close can the ship get to a waypoint before it moves to the next one
}

- (void)initPhysics;

@end

@implementation EnemyBomber

- (id)initWithScene:(SSGameSceneController *)aGameScene {
    
    self = [super init];
    if (self) {
        
        // Hook up to the game controller that is responsible for this model
        gameSceneController = aGameScene;
        assetManager = gameSceneController.assetManager;

        // Set the objects initial state
        state = AbstractObjectAlive;

        // Check to see if an enemy fighter model has already been loaded into the asset manager and
        // if so retrieve it for use in this object. If not found then get the asset manager to load
        // it
        model = [assetManager getModelWithName:@"EnemyBomber"];
        if (!model) {
            [assetManager loadTexturedMeshWithData:EnemyBomberVertexData vertexCount:kEnemyBomberNumberOfVertices textureFileName:@"EnemyBomberTexture.png" scale:1.0f modelName:@"EnemyBomber"];
            model = [assetManager getModelWithName:@"EnemyBomber"];
        }
        
        // Create a collision hull for this object
        [self initPhysics];
        
        // Configure the static values used for steering the ship
        maxVelocity = 0.4;
        maxSteeringForce = 0.005f;
        waypointDistance = 40;
        shield = 100;

        // Calculate an initial position and target for the ship to travel towards
        waypoint = GLKVector3Make(150 * RANDOM_MINUS_1_TO_1(), 150 * RANDOM_MINUS_1_TO_1(), 150 * RANDOM_MINUS_1_TO_1());
        self.position = GLKVector3Make(RANDOM_MINUS_1_TO_1() * 150, RANDOM_MINUS_1_TO_1() * 150, RANDOM_MINUS_1_TO_1() * 150);
        
    }
    return self;
}

- (void)updateWithDelta:(GLfloat)aDelta {
    
    // If there is no delta value then don't bother updating
    if (aDelta == 0) return;
    
    // Perform update actions based on the state of the object
    switch (state) {
        case AbstractObjectAlive: {

            // Decide if you want to fire the weapon at the player
            if ((int)(10 * RANDOM_0_TO_1()) == 1) {
                [gameSceneController fireWeaponFrom:position to:gameSceneController.camera.position];
            }
            
            // Steer the model to the next waypoint
            steeringForce = GLKVector3Subtract(waypoint, position);
            steeringForce = GLKVector3Subtract(steeringForce, direction);
            steeringForce = GLKVector3MultiplyScalar(steeringForce, aDelta);
            
            // Limit the amout of steering force allowed
            float vectorLength = GLKVector3Length(steeringForce);
            if (vectorLength > maxSteeringForce) {
                steeringForce = GLKVector3MultiplyScalar(steeringForce, maxSteeringForce/vectorLength);
            }
            
            // Add the steering force to the direction
            direction = GLKVector3Add(direction, steeringForce);    
            
            // Limit the speed allowed
            vectorLength = GLKVector3Length(direction);
            if (vectorLength > maxVelocity) {
                direction = GLKVector3MultiplyScalar(direction, maxVelocity/vectorLength);
            }
            
            // Update the position of the ship based on the calculated direction vector
            self.position = GLKVector3Add(position, direction);
            
            // Check to see if the ship is now close to the current waypoint. If it is then
            // move to the next waypoint in the list
            if((position.x - waypoint.x) > -waypointDistance && 
               (position.x - waypoint.x) < waypointDistance && 
               (position.y - waypoint.y) > -waypointDistance && 
               (position.y - waypoint.y) < waypointDistance &&
               (position.z - waypoint.z) > -waypointDistance &&
               (position.z - waypoint.z) < waypointDistance)
            {
                // Calculate the next random target to fly towards
                waypoint = GLKVector3Make(150 * RANDOM_MINUS_1_TO_1(), 150 * RANDOM_MINUS_1_TO_1(), 150 * RANDOM_MINUS_1_TO_1());
            }
            
            // Initialize the models local matrix
            modelMatrix = GLKMatrix4Identity;

            // Translate to the location of the model.The order of operations on the matrix is important, so the translation
            // should be done first
            modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, self.position.z);
            
            // Calculate a matrix that will cause the ships model to face the direction it is
            // travelling in
            GLKMatrix4 facing = GLKMatrix4Identity;
            SSMatrixFaceVector(facing.m, direction, GLKVector3Make(0, 1, 0));
            modelMatrix = GLKMatrix4Multiply(modelMatrix, facing);

            // If the scale of this model is other than 1.0 then apply the scale to the matrix
            if (model.scale != 1.0) {
                modelMatrix = GLKMatrix4Scale(modelMatrix, model.scale, model.scale, model.scale);
            }
            
            // Update the objects collision hull orientation with the same matrix used for the model
            basis.setFromOpenGLSubMatrix(modelMatrix.m);
            collisionObject->getWorldTransform().setBasis(basis);
            break;
        }
        
        case AbstractObjectDead: {
            state = AbstractObjectAlive;
            waypoint = GLKVector3Make(150 * RANDOM_MINUS_1_TO_1(), 150 * RANDOM_MINUS_1_TO_1(), 150 * RANDOM_MINUS_1_TO_1());
            self.position = GLKVector3Make(RANDOM_MINUS_1_TO_1() * 150, RANDOM_MINUS_1_TO_1() * 150, RANDOM_MINUS_1_TO_1() * 150);
            shield = 100;
            break;
        }
            
    }

}

- (void)render {
    
    // Mark the OGL commands
    glPushGroupMarkerEXT(0, "EnemyFighter");
    {
        // Check to see if the texture for this model is already set. If not then set it up
        if (gameSceneController.currentBoundTexture != model.texture.name) {
            gameSceneController.currentBoundTexture = model.texture.name;
            shader.texture2d0.name = model.texture.name;
        }

        // Update the shaders model matrix with the matrix for this model making sure to multiply the scenes model
        // matrix so that the model is position correctly with the world based on the gyro info from the device
        shader.transform.modelviewMatrix = GLKMatrix4Multiply(gameSceneController.sceneModelMatrix, modelMatrix);
        
        // Prepare the effect
        [shader prepareToDraw];
        
        // Bind to the vertex object array for this model
        glBindVertexArrayOES(model.vertexArrayName);
        
        // Draw the model
        glDrawArrays(GL_TRIANGLES, 0, model.vertexCount);
        
        // Important to unbind
        glBindVertexArrayOES(0);
    }
    glPopGroupMarkerEXT();

}

- (void)collidedWithCollisionGroup:(short)aCollisionGroup
{
    shield -= 2;
    if (shield <= 0) {
        state = AbstractObjectDead;
        [gameSceneController explosionAt:position];
    }
}


- (void)initPhysics
{
    // Create a collision object for this model
    [self createCollisionObject];

    // The collision group defines the type of object for this model. The collision mask defines the collision groups
    // that this collision group can collide with. This helps filter the collisions between objects to only those we
    // are interested in.    
    collisionGroup = COL_SHIP;
    collisionMask = COL_LAZER;
    collisionObject->setCollisionShape((btConvexHullShape*)model.collisionHull);
    collisionObject->setCollisionFlags(btCollisionObject::CF_CHARACTER_OBJECT);

}

@end
