//
//  ParticleEmitter.h
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

@class SSGameSceneController;
@class AssetManager;
@class SSModel;

// Structure used to hold particle specific information
typedef struct {
	GLKVector3 position;
	GLKVector3 direction;
    GLKVector3 startPos;
	GLfloat angle;
	GLfloat particleSize;
	GLfloat particleSizeDelta;
    GLfloat particleColorAlphaDelta;
	GLfloat timeToLive;
    GLKVector4 color;
    GLKVector4 deltaColor;
    GLfloat rotation;
    GLfloat rotationDelta;
    GLfloat distanceToCamera;
} Particle;

// Stores information for a single vertex within a particle sprite.
typedef struct {
    GLKVector3 vertex;
    GLKVector2 texture;
    GLKVector4 color;
} TexturedColoredQuad;

// Holds all the data needed to construct particle quad
typedef struct {
    TexturedColoredQuad bl;
    TexturedColoredQuad br;
    TexturedColoredQuad tl;
    TexturedColoredQuad tr;
} ParticleQuad;

// The particleEmitter allows you to define parameters that are used when generating particles.
// These particles are flat 2D quads that are rotated to face the camera and have 
// their own characteristics such as speed, lifespan, start and end size etc.
//
@interface ParticleEmitter : NSObject {

	//////////////////// Particle iVars
	GLKVector3      sourcePosition, sourcePositionVariance;			
	GLKVector3      angle, angleVariance;								
	GLfloat         speed, speedVariance;	
	GLKVector3      gravity;	
	GLfloat         particleLifespan, particleLifespanVariance;			
	GLfloat         startParticleSize, startParticleSizeVariance;
	GLfloat         finishParticleSize, finishParticleSizeVariance;
    GLKVector4      startColor, startColorVariance;
    GLKVector4      finishColor, finishColorVariance;
    GLfloat         rotationStart, rotationStartVariance;
    GLfloat         rotationEnd, rotationEndVariance;
	GLuint          maxParticles;
	GLint           particleCount;
	GLfloat         emissionRate;
	GLfloat         emitCounter;	
	GLfloat         elapsedTime;
	GLfloat         duration;

	///////////////////// Particle Emitter iVars
	BOOL            active;             // Identifies if the emitter is active or not
    GLfloat         rate;               // Defines the rate at which particles are emitted
	GLint           particleIndex;      // Stores the number of particles that are going to be rendered
    GLfloat         rotateAngle;        // Amount to rotate each particle by
    GLKVector3      cameraFacingVector; //
	
	///////////////////// Render
    GLKBaseEffect   *shader;
	Particle        *particles;         // Array of particles that hold the particle emitters particle details
    ParticleQuad    *particleQuads;     // Array to hold the vertex, texture and color info needed during render
    GLushort        *indices;           // Array to hold the indices defining triangles for each quad during render
    GLuint          vertexArrayName;    // 
    GLuint          vertexBufferName;   // The name of the vertex buffer that holds the vertex, texture and color info
    GLuint          textureName;        // Holds the name of the texture to be used for this particle emitter
    GLKVector3      up;                 // Used to define the up vector when rotating particles to face the camera
    GLKVector3      bl, br, tl, tr;     // Default quad vertex positions
    
    ///////////////////// Model information
    GLKMatrix4      emitterMatrix;      // Emitters local matrix
    NSString        *textureFileName;   // Holds the texture name from the particle config file
    
    ///////////////////// Game scene, asset manager and shader references references
    SSGameSceneController __strong  *gameSceneController;
    AssetManager __strong           *assetManager;
	
}

@property (nonatomic, assign) GLKVector3 sourcePosition;
@property (nonatomic, assign) GLint particleCount;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) GLfloat duration;
@property (nonatomic, assign) GLKVector3 facing;
@property (nonatomic, strong) SSGameSceneController *gameSceneController;
@property (nonatomic, strong) GLKBaseEffect *shader;

// Initialises a particle emitter using configuration read from a file
- (id)initParticleEmitterWithFile:(NSString*)aFileName scene:(SSGameSceneController*)aScene effectShader:(GLKBaseEffect*)aShaderEffect;

// Renders the particles for this emitter to the screen
- (void)render;

// Updates all particles in the particle emitter
- (void)updateWithDelta:(GLfloat)aDelta cameraFacingVector:(GLKVector3)aCameraFacingVector;

// Stops the particle emitter
- (void)stopParticleEmitter;

@end
