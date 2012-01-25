//
//  Camera.h
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

#import "SSAbstractObject.h"
#import "btBulletCollisionCommon.h"
#import "btShapeHull.h"

@class SSGameSceneController;

@interface Camera : SSAbstractObject {
    
    GLKVector3 facingVector;
    GLfloat fieldOfView;
    GLfloat aspectRatio;
    GLfloat viewWidth;
    GLfloat viewHeight;
    GLfloat nearDistance;
    GLfloat farDistance;
    GLKMatrix4 projectionMatrix;
    
}

#pragma mark - Properties

@property (nonatomic, assign) GLKVector3 facingVector;
@property (nonatomic, assign) GLfloat fieldOfView;
@property (nonatomic, readonly) GLfloat aspectRatio;
@property (nonatomic, assign) GLfloat viewWidth;
@property (nonatomic, assign) GLfloat viewHeight;
@property (nonatomic, assign) GLfloat nearDistance;
@property (nonatomic, assign) GLfloat farDistance;
@property (nonatomic, assign) GLKMatrix4 projectionMatrix;
@property (nonatomic) btCollisionObject *frustumCollisionObject;

#pragma mark - Methods

- (id)initWithGameSceneController:(SSGameSceneController *)aGameSceneController;

// Updates the facing vector using the matrix supplied. This means we can always get a vector from the camera
// object that tells us which way the camera is facing
- (void)updateWithModelMatrix:(GLKMatrix4)aModelMatrix;

@end
