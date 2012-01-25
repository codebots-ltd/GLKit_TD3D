//
//  SSAbstractObject.h
//  GLKit_TD3D
//
//  Created by Michael Daley on 15/09/2011.
//  Copyright (c) 2011 71Squared. All rights reserved.
//

#import "SSModel.h"
#import "SSGameSceneController.h"

#define BIT(x) (1<<(x))

@class AssetManager;

enum AbstractObjectState {
    AbstractObjectDead = 0,
    AbstractObjectAlive = 1
};

enum collisionTypes {
    COL_NOTHING = 0,
    COL_SHIP = BIT(1)
};

@interface SSAbstractObject : NSObject {
    SSGameSceneController __weak *gameSceneController;      // Reference to the game scene in which this object is being used
    AssetManager __weak *assetManager;                      // Reference to the asset manager which holds the models
    GLKBaseEffect __weak *shader;                           // Reference to the shader we are going to be using

    SSModel __strong *model;                                // Model to be used when rendering
    
    GLKVector3 position;                                    // Position at which we will be rendering the object
    GLKVector3 direction;                                   // Normalised vector representing the direction of the object
    GLfloat speed;                                          // Speed of the object
    GLKMatrix4 modelMatrix;                                 // Objects local model matrix

    uint type;                                              // Type of object
    uint state;                                             // Objects state e.g. alive or dead
    
    btCollisionObject *collisionObject;                     // Bullet collision object
    short collisionMask;                                    // Identifies the other collision groups this object should collide with
    short collisionGroup;                                   // Identifies the collision group to which this object belongs
    BOOL inCollisionWorld;                                  // Is this objects collision object in the collision world
    btMatrix3x3 basis;                                      // Local collision shell matrix

}

@property (nonatomic, weak) SSGameSceneController *gameSceneController;
@property (nonatomic, weak) AssetManager *assetManager;
@property (nonatomic, weak) GLKBaseEffect *shader;
@property (nonatomic) GLKVector3 position;
@property (nonatomic) GLKVector3 direction;
@property (nonatomic) GLfloat speed;
@property (nonatomic) GLKMatrix4 modelMatrix;
@property (nonatomic, strong) SSModel *model;
@property btCollisionObject *collisionObject;

- (id)initWithScene:(SSGameSceneController *)aGameScene;

// Passes in the amount of time since the last update which can then be used
// to update the logic of this object e.g. it's position
- (void)updateWithDelta:(GLfloat)aDelta;

// Render this object based on it's current position
- (void)render;

// Create the collision object
- (void)createCollisionObject;

// Performs actions based on the object passed in with which this object has collided
- (void)collidedWithObject:(SSAbstractObject*)aObject;

// Performs actions based on the collision group passed in. This can be used if you have a collision
// group but no object i.e. when using ray testing
- (void)collidedWithCollisionGroup:(short)aCollisionGroup;

// Add this objects collision object to the collision world provided
- (void)addToCollisionWorld:(btCollisionWorld*)aCollisionWorld;

// Removes this objects collision object from the collision world
- (void)removeFromCollisionWorld:(btCollisionWorld*)aCollisionWorld;

@end
