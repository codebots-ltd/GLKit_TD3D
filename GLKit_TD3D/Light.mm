//
//  Light.m
//  GLKit_TD3D
//
//  Created by Michael Daley on 19/09/2011.
//  Copyright (c) 2011 71Squared. All rights reserved.
//

#import "Light.h"
#import "sphere.h"
#import "AssetManager.h"

@implementation Light

- (id)initWithScene:(SSGameSceneController *)aGameScene {
    
    self = [super init];
    if (self) {
        
        // Hook up to the game controller that is responsible for this model
        gameSceneController = aGameScene;
        assetManager = gameSceneController.assetManager;
        
        // Check to see if an enemy fighter model has already been loaded into the asset manager and
        // if so retrieve it for use in this object. If not found then get the asset manager to load
        // it
        model = [assetManager getModelWithName:@"Light"];
        if (!model) {
            [assetManager loadMeshWithData:SphereVertexData vertexCount:kSphereNumberOfVertices scale:0.75f modelName:@"Light"];
            model = [assetManager getModelWithName:@"Light"];
        }
        
    }
    return self;
}

- (void)updateWithDelta:(GLfloat)aDelta {
    
    modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, position.x, position.y, position.z);
    
    // If the scale of this model is other than 1.0 then apply the scale to the matrix
    if (self.model.scale != 1.0)
        modelMatrix = GLKMatrix4Scale(modelMatrix, self.model.scale, self.model.scale, self.model.scale);

}

- (void)render {
    
    // Mark the OGL commands
    glPushGroupMarkerEXT(0, "Sphere");
    
    // Set the current effect to use this models texture
    self.shader.transform.modelviewMatrix = GLKMatrix4Multiply(gameSceneController.sceneModelMatrix, modelMatrix);
    
    // Prepare the effect
    [self.shader prepareToDraw];
    
    // Bind to the vertex object array for this model
    glBindVertexArrayOES(model.vertexArrayName);
    
    // Draw the model
    glColor4f(1, 1, 1, 1);
    glDrawArrays(GL_TRIANGLES, 0, model.vertexCount);
    
    glBindVertexArrayOES(0);
    
    glPopGroupMarkerEXT();
    
}

@end
