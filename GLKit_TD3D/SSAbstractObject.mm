//
//  SSAbstractObject.m
//  GLKit_TD3D
//
//  Created by Michael Daley on 15/09/2011.
//  Copyright (c) 2011 71Squared. All rights reserved.
//

#import "SSAbstractObject.h"
#import "AssetManager.h"
#import "btBulletCollisionCommon.h"

#pragma mark - Private Interface

@interface SSAbstractObject () 

@end

#pragma mark - Public Implementation

@implementation SSAbstractObject

@synthesize gameSceneController;
@synthesize assetManager;
@synthesize shader;
@synthesize position;
@synthesize direction;
@synthesize speed;
@synthesize modelMatrix;
@synthesize model;
@synthesize collisionObject;

- (id)initWithScene:(SSGameSceneController *)aGameScene {
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)updateWithDelta:(GLfloat)aDelta {
    // Implemented in inheriting class
}

- (void)render {
    // Implemented in inheriting class
}

- (void)collidedWithObject:(SSAbstractObject*)aObject
{
    // Implement in inheriting class
}

- (void)collidedWithCollisionGroup:(short)aCollisionGroup
{
    // Implement in inheriting class    
}

- (void)setPosition:(GLKVector3)aPosition
{
	position = aPosition;
	if (collisionObject) {
		collisionObject->getWorldTransform().setOrigin(btVector3(position.x, position.y, position.z));
	}
}

- (void)createCollisionObject
{
    // Collision shapes are made using the vertices from blender. As the model needs to be rotated along the X
    // axis to orient it correct in our 3D world, as Y and Z are reversed in blender, we also need to rotate
    // the collision shape around the same axis by the same amount.
	basis.setRotation(btQuaternion(GLKMathDegreesToRadians(0), GLKMathDegreesToRadians(-90), GLKMathDegreesToRadians(0)));
    
    // Havind created a basis that contains the rotation we need, we then create the collision object and
    // update its world transform using this basis
    collisionObject = new btCollisionObject();
    collisionObject->getWorldTransform().setBasis(basis);
    
    // In case it's important to get information from the objects instance, assigning a reference to self
    // allows the instance involved within a collision to be queried
//    collisionObject->setUserPointer(self);
}

- (void)addToCollisionWorld:(btCollisionWorld*)aCollisionWorld
{
    if (collisionObject && !inCollisionWorld)
    {
        aCollisionWorld->addCollisionObject(collisionObject, collisionGroup, collisionMask);
        inCollisionWorld = YES;
    }
}

- (void)removeFromCollisionWorld:(btCollisionWorld*)aCollisionWorld
{
    if (collisionObject && inCollisionWorld)
    {
        aCollisionWorld->removeCollisionObject(collisionObject);
        inCollisionWorld = NO;
    }
}

@end
