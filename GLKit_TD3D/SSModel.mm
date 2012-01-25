//
//  SSModel.m
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

#import "SSModel.h"
#import "btShapeHull.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#pragma mark - Private Implementation

@interface SSModel () {
@private

}

// Generates a collision hull from the model data provided. This is used when checking for collisions using bullet.
// The collision hull is added to the physics world and then moved around in relation to the object it represents.
// We can then query bullet to see if any of these shapes have collided and where etc.
- (void)generateCollisionShapeWithTexturedVertexData:(const SSTexturedVertexData3D[])aVertexData vertexCount:(GLuint)aVertexCount;
- (void)generateCollisionShapeWithVertexData:(const SSVertexData3D[])aVertexData vertexCount:(GLuint)aVertexCount;

@end

#pragma mark - Implementation

@implementation SSModel

@synthesize modelName;
@synthesize texture;
@synthesize vertexArrayName;
@synthesize vertexBufferName;
@synthesize vertexCount;
@synthesize scale;
@synthesize collisionHull;

- (void)dealloc {

    // Delete the VAO, VBO when this object is deallocated
    glDeleteVertexArraysOES(1, &vertexArrayName);
    glDeleteBuffers(1, &vertexBufferName);

}

- (id)initWithMeshVertexData:(const SSVertexData3D[])aVertexData vertexCount:(GLuint)aVertexCount scale:(GLfloat)aScale modelName:(NSString *)aName {

    self = [super init];
    if (self) {
        
        modelName = aName;
        scale = aScale;
        vertexCount = aVertexCount;

        // Create the vertex array that is going to store the details of this models VBO and it's bindings
        glGenVertexArraysOES(1, &vertexArrayName);
        glBindVertexArrayOES(vertexArrayName);
        
        // Generate the buffer array and bind the necessary 
        glGenBuffers(1, &vertexBufferName);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBufferName);
        glBufferData(GL_ARRAY_BUFFER, sizeof(SSVertexData3D) * aVertexCount, aVertexData, GL_STATIC_DRAW);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SSVertexData3D), BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(SSVertexData3D), BUFFER_OFFSET(12));
        glBindVertexArrayOES(0);
     
        // Generate a btConvexHullShape for the collision hull to be used. This is being done using bullet which is only
        // suitable for small simple models, otherwise a collision hull shape should be defined externally in something like
        // blender and then loaded here
        [self generateCollisionShapeWithVertexData:aVertexData vertexCount:aVertexCount];

        NSLog(@"Created model called: %@ with vertex count: %i", modelName, vertexCount);
    }
    return self;
}

- (id)initWithTexturedMeshVertexData:(const SSTexturedVertexData3D[])aVertexData vertexCount:(GLuint)aVertexCount textureFileName:(NSString *)aTextureFileName scale:(GLfloat)aScale modelName:(NSString *)aName {
    
    self = [super init];
    if (self) {
        
        modelName = aName;
        scale = aScale;
        vertexCount = aVertexCount;
        
        // Create the vertex array that is going to store the details of this models VBO and it's bindings
        glGenVertexArraysOES(1, &vertexArrayName);
        glBindVertexArrayOES(vertexArrayName);

        // Generate the buffer array and bind the necessary 
        glGenBuffers(1, &vertexBufferName);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBufferName);
        glBufferData(GL_ARRAY_BUFFER, sizeof(SSTexturedVertexData3D) * aVertexCount, aVertexData, GL_STATIC_DRAW);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SSTexturedVertexData3D), BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(SSTexturedVertexData3D), BUFFER_OFFSET(12));
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 3, GL_FLOAT, GL_FALSE, sizeof(SSTexturedVertexData3D), BUFFER_OFFSET(24));
        glBindVertexArrayOES(0);

        // Sort out the filename for the texture and get it's path
        NSString *textureFileName = [aTextureFileName stringByDeletingPathExtension];
        NSString *textureFileNameExtension = [aTextureFileName pathExtension];
        NSString *path = [[NSBundle mainBundle] pathForResource:textureFileName ofType:textureFileNameExtension];
        
        // If no path is passed back then something is wrong
        NSAssert1(path, @"Unable to find texture: %@", aTextureFileName);

        // Build a dictionary that holds options for the texture. This is currently setting up the texture to use an origi that is in
        // the bottom left hand corner. This stops the texture being rendered upside down.
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], GLKTextureLoaderOriginBottomLeft, nil];

        // Load the texture
        NSError *outError;
        texture = [GLKTextureLoader textureWithContentsOfFile:path options:dict error:&outError];
        
        // Go bang if the texture loaded came across an error
        NSAssert1(!outError, @"Error loading texture: %@", [outError localizedDescription]);
        
        // Generate a btConvexHullShape for the collision hull to be used. This is being done using bullet which is only
        // suitable for small simple models, otherwise a collision hull shape should be defined externally in something like
        // blender and then loaded here
        [self generateCollisionShapeWithTexturedVertexData:aVertexData vertexCount:aVertexCount];
        
        NSLog(@"Created model called: %@ with texture name: %i and vertex count: %i", modelName, texture.name, vertexCount);
    }
    return self;
}

- (void)generateCollisionShapeWithTexturedVertexData:(const SSTexturedVertexData3D[])aVertexData vertexCount:(GLuint)aVertexCount {
    
    NSLog(@"Generating collision hull for %@", modelName);
    
    btConvexHullShape *hull = new btConvexHullShape();
    for (int i=0; i < aVertexCount; i ++)
    {
        btVector3 v = btVector3(aVertexData[i].vertex.x, aVertexData[i].vertex.y, aVertexData[i].vertex.z);
        hull->addPoint(v);
    }
    
    // Create a hull approximation which simplifies complex collision hulls
    btShapeHull *approxHull = new btShapeHull(hull);
    btScalar margin = hull->getMargin();
    approxHull->buildHull(margin);
    collisionHull = new btConvexHullShape((float*)approxHull->getVertexPointer(), approxHull->numVertices());
    collisionHull->setLocalScaling(btVector3(scale, scale, scale));
    
    // Delete the temporaty collision hulls
    delete hull;
    delete approxHull;
    
}

- (void)generateCollisionShapeWithVertexData:(const SSVertexData3D[])aVertexData vertexCount:(GLuint)aVertexCount {
    
    NSLog(@"Generating collision hull for %@", modelName);
    
    btConvexHullShape *hull = new btConvexHullShape();
    for (int i=0; i < aVertexCount; i ++)
    {
        btVector3 v = btVector3(aVertexData[i].vertex.x, aVertexData[i].vertex.y, aVertexData[i].vertex.z);
        hull->addPoint(v);
    }
    
    // Create a hull approximation which simplifies complex collision hulls
    btShapeHull *approxHull = new btShapeHull(hull);
    btScalar margin = hull->getMargin();
    approxHull->buildHull(margin);
    collisionHull = new btConvexHullShape((float*)approxHull->getVertexPointer(), approxHull->numVertices());
    collisionHull->setLocalScaling(btVector3(scale, scale, scale));
    
    // Delete the temporaty collision hulls
    delete hull;
    delete approxHull;
}

@end
