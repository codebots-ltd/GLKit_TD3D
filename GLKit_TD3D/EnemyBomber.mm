//
//  EmenyFighter.m
//  GLKit_TD3D
//
//  Created by Michael Daley on 15/09/2011.
//  Copyright (c) 2011 71Squared. All rights reserved.
//

#import "EnemyBomber.h"
#import "AssetManager.h"
#import "EnemyBomberModel.h"

@interface EnemyBomber () {
@private
    GLfloat rotation;
    GLfloat step;
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
        
        // Check to see if an enemy fighter model has already been loaded into the asset manager and
        // if so retrieve it for use in this object. If not found then get the asset manager to load
        // it
        model = [assetManager getModelWithName:@"EnemyBomber"];
        if (!model) {
            [assetManager loadTexturedMeshWithData:EnemyBomberVertexData vertexCount:kEnemyBomberNumberOfVertices textureFileName:@"EnemyBomberTexture.png" scale:0.5f modelName:@"EnemyBomber"];
            model = [assetManager getModelWithName:@"EnemyBomber"];
        }
        
        step = RANDOM_MINUS_1_TO_1() * 45;
        
        // Create a collision hull for this object
        [self createCollisionObject];
        [self initPhysics];
        
        self.position = GLKVector3Make(RANDOM_MINUS_1_TO_1() * 30, RANDOM_MINUS_1_TO_1() * 30, RANDOM_MINUS_1_TO_1() * 30);
        if (collisionObject) {
            collisionObject->getWorldTransform().setOrigin(btVector3(position.x, position.y, position.z));
        }
        
    }
    return self;
}

- (void)updateWithDelta:(GLfloat)aDelta {
    
    // Calculate the matrix for this model based on it's position, rotation and scale
    modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, position.x, position.y, position.z);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, GLKMathDegreesToRadians(rotation), 1, 0, 0);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, GLKMathDegreesToRadians(rotation), 0, 0, 1);
    
    // If the scale of this model is other than 1.0 then apply the scale to the matrix
    if (self.model.scale != 1.0)
        modelMatrix = GLKMatrix4Scale(modelMatrix, self.model.scale, self.model.scale, self.model.scale);
    
    // Update the objects collision hull orientation
    basis.setFromOpenGLSubMatrix(modelMatrix.m);
    collisionObject->getWorldTransform().setBasis(basis);
    
    // Update the amount of rotation
    rotation += step * aDelta;
    
}

- (void)render {
    
    // Mark the OGL commands
    glPushGroupMarkerEXT(0, "EnemyFighter");
    
    // Set the current effect to use this models texture
    self.shader.texture2d0.name = model.texture.name;
    self.shader.transform.modelviewMatrix = GLKMatrix4Multiply(gameSceneController.sceneModelMatrix, modelMatrix);
    
    // Prepare the effect
    [self.shader prepareToDraw];
    
    // Bind to the vertex object array for this model
    glBindVertexArrayOES(model.vertexArrayName);
    
    // Draw the model
    glDrawArrays(GL_TRIANGLES, 0, model.vertexCount);
    
    glBindVertexArrayOES(0);
    
    glPopGroupMarkerEXT();
    
}

- (void)initPhysics
{
    // The collision group defines the type of object for this model. The collision mask defines the collision groups
    // that this collision group can collide with. This helps filter the collisions between objects to only those we
    // are interested in.    
    collisionGroup = COL_SHIP;
    collisionMask = COL_SHIP;
    collisionObject->setCollisionShape((btConvexHullShape*)self.model.collisionHull);
    collisionObject->setCollisionFlags(btCollisionObject::CF_CHARACTER_OBJECT);
}

@end
