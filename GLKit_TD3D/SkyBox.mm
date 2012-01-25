//
//  SkyBox.m
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

#import "SkyBox.h"
#import "Camera.h"

#pragma mark - Private Interface

@interface SkyBox () {
@private
    GLKSkyboxEffect *skyBoxEffect;
    GLKTextureInfo *skyboxTexture;
}

// Setsup the GLKSkyboxEffect
- (void)initSkyBox;

@end

#pragma mark - Public Implementation

@implementation SkyBox

@synthesize height;
@synthesize width;
@synthesize depth;
@synthesize projectionMatrix;
@synthesize center;

- (id)initWithProjectionMatrix:(GLKMatrix4)aProjectionMatrix width:(GLfloat)aWidth height:(GLfloat)aHeight depth:(GLfloat)aDepth {
    self = [super init];
    if (self) {
        height = aHeight;
        width = aWidth;
        depth = aDepth;
        projectionMatrix = aProjectionMatrix;
        
        [self initSkyBox];
    }
    return self;
}

- (void)initSkyBox {
    
    // Setup the skybox
    NSString *path = [[NSBundle mainBundle] pathForResource:@"skybox_texture" ofType:@"png"];
    NSError *outError;
    
    skyboxTexture = [GLKTextureLoader cubeMapWithContentsOfFile:path options:nil error:&outError];
    NSAssert1(!outError, @"Error occured loading skybox texture: %@", outError.localizedDescription);
    
    skyBoxEffect = [[GLKSkyboxEffect alloc] init];
    skyBoxEffect.textureCubeMap.name = skyboxTexture.name;
    skyBoxEffect.center = GLKVector3Make(0, 0, 0);
    skyBoxEffect.xSize = width;
    skyBoxEffect.ySize = height;
    skyBoxEffect.zSize = depth;
    skyBoxEffect.transform.projectionMatrix = projectionMatrix;
    
}

- (void)renderWithModelMatrix:(GLKMatrix4)aModelMatrix gameScene:(SSGameSceneController *)gameScene {
    
    skyBoxEffect.transform.modelviewMatrix = aModelMatrix;
    [skyBoxEffect prepareToDraw];
    [skyBoxEffect draw];
    
}

- (void)setCenter:(GLKVector3)newCenter {
    center = newCenter;
    skyBoxEffect.center = newCenter;
}

@end
