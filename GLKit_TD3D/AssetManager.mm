//
//  AssetManager.m
//  TD3D
//
// Copyright (c) 2010 71Squared
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

#import "AssetManager.h"
#import "SSModel.h"

#pragma mark -
#pragma mark Private interface

@interface AssetManager () {
    
    NSMutableDictionary *models;

}

@end

#pragma mark -
#pragma mark Public implementation

@implementation AssetManager

- (id) init
{
    self = [super init];
    if (self != nil) {

        // Set up the mutable arrays that will hold the VBO and Texture names
        models = [[NSMutableDictionary alloc] init];
        
    }
    return self;
}
- (void)loadMeshWithData:(const SSVertexData3D[])aVertexData vertexCount:(GLuint)aVertexCount scale:(GLfloat)aScale modelName:(NSString *)aModelName {
    // Check to see if the name of this model has already been used
    if ([models objectForKey:aModelName]) {
        NSLog(@"WARNING: A model with called '%@' already exists", aModelName);
        return;
    }
    
    // Create a new instance of SSModel and add it to the models dictionary with its name as the key
    SSModel *newModel = [[SSModel alloc] initWithMeshVertexData:aVertexData vertexCount:aVertexCount scale:aScale modelName:aModelName];
    [models setObject:newModel forKey:aModelName];
}

- (void)loadTexturedMeshWithData:(const SSTexturedVertexData3D[])aVertexData vertexCount:(GLuint)aVertexCount textureFileName:(NSString *)aTextureFileName scale:(GLfloat)aScale modelName:(NSString *)aModelName {
    
    // Check to see if the name of this model has already been used
    if ([models objectForKey:aModelName]) {
        NSLog(@"WARNING: A model with called '%@' already exists", aModelName);
        return;
    }
    
    // Create a new instance of SSModel and add it to the models dictionary with its name as the key
    SSModel *newModel = [[SSModel alloc] initWithTexturedMeshVertexData:aVertexData vertexCount:aVertexCount textureFileName:aTextureFileName scale:aScale modelName:aModelName];
    [models setObject:newModel forKey:aModelName];
    
}

- (SSModel *)getModelWithName:(NSString *)aModelName {
    return [models objectForKey:aModelName];
}

@end
