//
//  SkyBox.h
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

#import <GLKit/GLKit.h>
#import "SSGameSceneController.h"

@interface SkyBox : NSObject {
    GLfloat height;
    GLfloat width;
    GLfloat depth;
    GLKMatrix4 projectionMatrix;
    GLKVector3 center;
}

#pragma mark - Properties

@property (nonatomic, assign) GLfloat height;
@property (nonatomic, assign) GLfloat width;
@property (nonatomic, assign) GLfloat depth;
@property (nonatomic, assign) GLKMatrix4 projectionMatrix;
@property (nonatomic, assign) GLKVector3 center;

// Initializes the skybox effect with the specified height, width and depth along with the projection matrix to be
// used
- (id)initWithProjectionMatrix:(GLKMatrix4)aProjectionMatrix width:(GLfloat)aWidth height:(GLfloat)aHeight depth:(GLfloat)aDepth;

// Renders the skybox
- (void)renderWithModelMatrix:(GLKMatrix4)aModelMatrix gameScene:(SSGameSceneController*)gameScene;

@end
