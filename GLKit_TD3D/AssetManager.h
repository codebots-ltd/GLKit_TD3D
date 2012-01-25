//
//  AssetManager.h
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
//  This class is responsible for creating the VBO's and Textures to be used in the game. This is a
//  singleton class that is accessed by other classes that need to request a specific VBO or texture.
//
//  Each VBO and Texture created will be given a text key that can be used to request a specific VBO or
//  texture. This will allow us to create just a single version of a VBO or Texture that can be reused 
//  many times reducing the amount of memory being used.
//

#import "OpenGLCommon.h"

@class SSModel;

@interface AssetManager : NSObject 

- (void)loadTexturedMeshWithData:(const SSTexturedVertexData3D[])aVertexData vertexCount:(GLuint)aVertexCount textureFileName:(NSString *)aTextureFileName scale:(GLfloat)aScale modelName:(NSString *)aModelName;

- (void)loadMeshWithData:(const SSVertexData3D[])aVertexData vertexCount:(GLuint)aVertexCount scale:(GLfloat)aScale modelName:(NSString *)aModelName;

- (SSModel *)getModelWithName:(NSString *)aModelName;

@end
