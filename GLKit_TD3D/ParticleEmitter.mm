//
//  ParticleEmitter.m
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

#import "ParticleEmitter.h"
#import "TBXML.h"
#import "TBXMLParticleAdditions.h"
#import "SSGameSceneController.h"
#import "AssetManager.h"
#import "PlasmaModel.h"
#import "Camera.h"
#include <stdio.h>
#include <stdlib.h>

#pragma mark -
#pragma mark Private interface

@interface ParticleEmitter (Private)

// Adds a particle from the particle pool to the emitter
- (BOOL)addParticle;

// Initialises a particle ready for use
- (void)initParticle:(Particle*)particle;

// Parses the supplied XML particle configuration file
- (void)parseParticleConfig:(TBXML*)aConfig;

// Set up the arrays that are going to store our particles
- (void)setupArrays;

// Simple function used to compare two numbers provided by the qsort function. This is used to sort the distance
// value of particles from the camera
int compare (const void *a, const void *b);

@end

#pragma mark -
#pragma mark Public implementation

@implementation ParticleEmitter

@synthesize sourcePosition;
@synthesize active;
@synthesize particleCount;
@synthesize duration;
@synthesize facing;
@synthesize gameSceneController;
@synthesize shader;

- (void)dealloc {
	
	// Release the memory we are using for our vertex and particle arrays etc
	if (particles)
		free(particles);
    
    if (particleQuads)
        free(particleQuads);
    
}

- (id)initParticleEmitterWithFile:(NSString*)aFileName scene:(SSGameSceneController*)aScene effectShader:(GLKBaseEffect*)aShaderEffect {

    self = [super init];
    if (self != nil) {
        
        gameSceneController = aScene;
        assetManager = gameSceneController.assetManager;
        shader = aShaderEffect;
        
        // Create a TBXML instance that we can use to parse the config file
        TBXML *particleXML = [[TBXML alloc] initWithXMLFile:aFileName];
        
        // Parse the config file
        [self parseParticleConfig:particleXML];
        [self setupArrays];

        // Define which way is up. For this game that is going to be the +y axis
        up = GLKVector3Make(0, 1, 0);
        bl = GLKVector3Make(-0.5, -0.5, 0);
        br = GLKVector3Make(0.5, -0.5, 0);
        tl = GLKVector3Make(-0.5, 0.5, 0);
        tr = GLKVector3Make(0.5, 0.5, 0);

        // Set up a texture using the texture name in the config file. This will reuse a texture that has already been created with the same
        // file name to reduce the resources needed when muptiple particle emitter exists using the same texture
        textureName = [[assetManager createTextureWithFileName:textureFileName] name];
    }
    return self;
}

- (void)stopParticleEmitter {
    active = NO;
    elapsedTime = 0;
    emitCounter = 0;
}

- (void)updateWithDelta:(GLfloat)aDelta cameraFacingVector:(GLKVector3)aCameraFacingVector {

    // If this emitter is not active and there are no active particles then don't both trying to update
    // anything
    if (!active && particleCount == 0)
        return;
	
    // If the emitter is active and the emission rate is greater than zero then emit
	// particles
	if(active && emissionRate) {
		emitCounter += aDelta;
		while(particleCount < maxParticles && emitCounter > rate) {
			[self addParticle];
			emitCounter -= rate;
		}

		elapsedTime += aDelta;
		if(duration != -1 && duration < elapsedTime) {         
            [self stopParticleEmitter];   
        }
	}
	
	// Reset the particle index before updating the particles in this emitter
	particleIndex = 0;
    
    // Set the facing vector for the particles. This will also be used when rendering as well
    cameraFacingVector = aCameraFacingVector;
	
    // Loop through all the particles updating their location and color
	while(particleIndex < particleCount) {

		// Get the particle for the current particle index
		Particle *currentParticle = &particles[particleIndex];
        
        // Reduce the life span of the particle
        currentParticle->timeToLive -= aDelta;
		
		// If the current particle is alive then update it
		if(currentParticle->timeToLive > 0) {

			// Calculate the new position of the particle
            GLKVector3 tmp = GLKVector3MultiplyScalar(gravity, aDelta);
            currentParticle->direction = GLKVector3Add(currentParticle->direction, tmp);
            tmp = GLKVector3MultiplyScalar(currentParticle->direction, aDelta);
            currentParticle->position = GLKVector3Add(currentParticle->position, tmp);
            
			// Place the size of the current particle in the size array
			currentParticle->particleSize += currentParticle->particleSizeDelta;
            
			// Update the particles color
			currentParticle->color.r += currentParticle->deltaColor.r;
			currentParticle->color.g += currentParticle->deltaColor.g;
			currentParticle->color.b += currentParticle->deltaColor.b;
			currentParticle->color.a += currentParticle->deltaColor.a;
            
            // Update the rotation of the particle
            currentParticle->rotation += (currentParticle->rotationDelta * aDelta);

            // Calculate the distance from the cameras facing vector to the particle so that the particles can be sorted
            // and rendered back to front.
            currentParticle->distanceToCamera = GLKVector3Distance(currentParticle->position, cameraFacingVector);
            
			// Update the particle counter
			particleIndex++;
		} else {

			// As the particle is not alive anymore replace it with the last active particle 
			// in the array and reduce the count of particles by one.  This causes all active particles
			// to be packed together at the start of the array so that a particle which has run out of
			// life will only drop into this clause once
			if(particleIndex != particleCount - 1)
				particles[particleIndex] = particles[particleCount - 1];
			particleCount--;
		}
	}

    // Sort the particles based on their distance from the camera. This causes the particles to be rendered from back to front.
    // Not doing this causes the particles to be rendered in any order causing particles that are further away from the camera
    // possibly being rendered on top of those particles that are closer to the camera, which doesn't look very nice. This is not
    // the fastest sort in the world, but it's not a bottle neck for this implementation
    qsort(particles, particleIndex, sizeof(Particle), compare);
}

- (void)render {

    // We should only render anything if there are particles or the emitter is active
	if (particleCount > 0 || active) {
		
        // Check to see if the texture for this model is already set. If not then set it up
        if (gameSceneController.currentBoundTexture != textureName) {
            gameSceneController.currentBoundTexture = textureName;
            self.shader.texture2d0.name = textureName;
        }
        
        // Reset the particle index before rendering the particles in this emitter
        particleIndex = 0;
        
        // Create the matrix that will hold the rotation info needed for the particle to be facing the camera
        GLKMatrix4 faceCamera;
        
        // Switch on blending as the particles have transparency
        glEnable(GL_BLEND);
        
        // Switch of depth buffer writing so that artifacts are not generated when rendering transparent particles ontop of each other
        glDepthMask(GL_FALSE);
        
        // Switch the blend function so it's additive for better looking explosions and sparks
        glBlendFunc(GL_SRC_ALPHA, GL_ONE);

        // Mark the OGL commands
        glPushGroupMarkerEXT(0, "Particle");
        
        // Create a matrix that will cause the quad to face the camera
        faceCamera = GLKMatrix4Identity;
        SSMatrixFaceVector(faceCamera.m, GLKVector3Negate(cameraFacingVector), up);

        // Loop through all the particles updating their position, size, colour and rotation
        while(particleIndex < particleCount) {
            
            // Get the particle for the current particle index
            Particle *currentParticle = &particles[particleIndex];
            
            // Reset the local matrix with an identity matrix
            emitterMatrix = GLKMatrix4Identity;

            // Move the model to its position within the world and scale it
            emitterMatrix = GLKMatrix4Translate(emitterMatrix, currentParticle->position.x, currentParticle->position.y, currentParticle->position.z);
            emitterMatrix = GLKMatrix4Scale(emitterMatrix, currentParticle->particleSize, currentParticle->particleSize, currentParticle->particleSize);
            
            // Multiply the emitter matrix with the faceCamera matrix so that the quad will be rotated to face the camera
            emitterMatrix = GLKMatrix4Multiply(emitterMatrix, faceCamera);
            
            // Now rotate the sprite in the z axis so that we can spin it if necessary. Only need to do this if the rotation is not 0
            if (currentParticle->rotation != 0) 
                emitterMatrix = GLKMatrix4Rotate(emitterMatrix, GLKMathDegreesToRadians(currentParticle->rotation), 0, 0, 1);
            
            // Calculate the quads new vertex values by multiplying each vertex by the emitter matrix that has been calculated and also set the colour
            particleQuads[particleIndex].bl.vertex = GLKMatrix4MultiplyVector3WithTranslation(emitterMatrix, bl);
            particleQuads[particleIndex].bl.color = GLKVector4Make(currentParticle->color.r, currentParticle->color.g, currentParticle->color.b, currentParticle->color.a);
            particleQuads[particleIndex].br.vertex = GLKMatrix4MultiplyVector3WithTranslation(emitterMatrix, br);
            particleQuads[particleIndex].br.color = GLKVector4Make(currentParticle->color.r, currentParticle->color.g, currentParticle->color.b, currentParticle->color.a);
            particleQuads[particleIndex].tl.vertex = GLKMatrix4MultiplyVector3WithTranslation(emitterMatrix, tl);
            particleQuads[particleIndex].tl.color = GLKVector4Make(currentParticle->color.r, currentParticle->color.g, currentParticle->color.b, currentParticle->color.a);
            particleQuads[particleIndex].tr.vertex = GLKMatrix4MultiplyVector3WithTranslation(emitterMatrix, tr);
            particleQuads[particleIndex].tr.color = GLKVector4Make(currentParticle->color.r, currentParticle->color.g, currentParticle->color.b, currentParticle->color.a);
                        
            // Move to the next particle
            particleIndex++;
        }
        
        // Update the shaders model matrix with the matrix for this model making sure to multiply the scenes model
        // matrix so that the model is position correctly with the world based on the gyro info from the device
        self.shader.transform.modelviewMatrix = gameSceneController.sceneModelMatrix;
        
        // Bind to the buffer for this emitter, load the particle data for all active particles and point the shader parameters to the correct locations
        // within the buffer
        glBindBuffer(GL_ARRAY_BUFFER, vertexBufferName);
        glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(ParticleQuad) * particleIndex, particleQuads);
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(TexturedColoredQuad), (GLvoid*) offsetof(TexturedColoredQuad, vertex));
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedColoredQuad), (GLvoid*) offsetof(TexturedColoredQuad, texture));
        glEnableVertexAttribArray(GLKVertexAttribColor);
        glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(TexturedColoredQuad), (GLvoid*) offsetof(TexturedColoredQuad, color));

        // Everything is ready to render so prep the shader
        [self.shader prepareToDraw];
        
        // Render all the particles that are in the buffer using a single call
        glDrawElements(GL_TRIANGLES, particleIndex * 6, GL_UNSIGNED_SHORT, indices);

        glPopGroupMarkerEXT();

        // Switch off blending
        glDisable(GL_BLEND);
        
        // Switch depth buffer writing back on
        glDepthMask(GL_TRUE);
        
        // Switch the blend function backto it's original setting
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        // Important to unbind the vertex array object or odd things can happen during rendering
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
    }
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation ParticleEmitter (Private)

- (BOOL)addParticle {
	
	// If we have already reached the maximum number of particles then do nothing
	if(particleCount == maxParticles)
		return NO;
	
	// Take the next particle out of the particle pool we have created and initialize it
	Particle *particle = &particles[particleCount];
	[self initParticle:particle];
	
	// Increment the particle count
	particleCount++;
	
	// Return YES to show that a particle has been created
	return YES;
}


- (void)initParticle:(Particle*)particle {
	
	// Init the position of the particle.  This is based on the source position of the particle emitter
	// plus a configured variance.  The RANDOM_MINUS_1_TO_1 macro allows the number to be both positive
	// and negative
	particle->position.x = sourcePosition.x + sourcePositionVariance.x * RANDOM_MINUS_1_TO_1();
	particle->position.y = sourcePosition.y + sourcePositionVariance.y * RANDOM_MINUS_1_TO_1();
	particle->position.z = sourcePosition.z + sourcePositionVariance.z * RANDOM_MINUS_1_TO_1();
    particle->startPos.x = sourcePosition.x;
    particle->startPos.y = sourcePosition.y;
    particle->startPos.z = sourcePosition.z;
	
	// Init the direction of the particle.  The newAngle is calculated using the angle passed in and the
	// angle variance.
	GLKVector3 vector;
    GLKVector3 newAngle;   // holds the angles to be used when emitting particles
    newAngle.x = (GLfloat)GLKMathDegreesToRadians(angle.x + angleVariance.x * RANDOM_MINUS_1_TO_1());
    newAngle.y = (GLfloat)GLKMathDegreesToRadians(angle.y + angleVariance.y * RANDOM_MINUS_1_TO_1());

    // Calculate the vector for this particle from the angle information
    vector.x = -sinf(newAngle.y) * cosf(newAngle.x);
    vector.y = sinf(newAngle.x);
    vector.z = cosf(newAngle.y) * cosf(newAngle.x);
	
	// Calculate the vectorSpeed using the speed and speedVariance which has been passed in
	float vectorSpeed = speed + speedVariance * RANDOM_MINUS_1_TO_1();
	
	// The particles direction vector is calculated by taking the vector calculated above and
	// multiplying that by the speed
	particle->direction = GLKVector3MultiplyScalar(vector, vectorSpeed);
	
	// Calculate the particles life span using the life span and variance passed in
	particle->timeToLive = MAX(0, particleLifespan + particleLifespanVariance * RANDOM_MINUS_1_TO_1());
	
	// Calculate the particle size using the start and finish particle sizes
	GLfloat particleStartSize = startParticleSize + startParticleSizeVariance * RANDOM_MINUS_1_TO_1();
	GLfloat particleFinishSize = finishParticleSize + finishParticleSizeVariance * RANDOM_MINUS_1_TO_1();
	particle->particleSizeDelta = ((particleFinishSize - particleStartSize) / particle->timeToLive) * (1.0 / 60);
	particle->particleSize = MAX(0, particleStartSize);
    
    // Calculate the color the particle should have when it starts its life.  All the elements
	// of the start color passed in along with the variance are used to calculate the star color
	GLKVector4 start = GLKVector4Make(0, 0, 0, 0);
	start.r = startColor.r + startColorVariance.r * RANDOM_MINUS_1_TO_1();
	start.g = startColor.g + startColorVariance.g * RANDOM_MINUS_1_TO_1();
	start.b = startColor.b + startColorVariance.b * RANDOM_MINUS_1_TO_1();
	start.a = startColor.a + startColorVariance.a * RANDOM_MINUS_1_TO_1();
	
	// Calculate the color the particle should be when its life is over.  This is done the same
	// way as the start color above
    GLKVector4 end = GLKVector4Make(0, 0, 0, 0);
	end.r = finishColor.r + finishColorVariance.r * RANDOM_MINUS_1_TO_1();
	end.g = finishColor.g + finishColorVariance.g * RANDOM_MINUS_1_TO_1();
	end.b = finishColor.b + finishColorVariance.b * RANDOM_MINUS_1_TO_1();
	end.a = finishColor.a + finishColorVariance.a * RANDOM_MINUS_1_TO_1();
	
	// Calculate the delta which is to be applied to the particles color during each cycle of its
	// life.  The delta calculation uses the life span of the particle to make sure that the 
	// particles color will transition from the start to end color during its life time.
	particle->color = start;
	particle->deltaColor.r = ((end.r - start.r) / particle->timeToLive) * (1.0 / 60);
	particle->deltaColor.g = ((end.g - start.g) / particle->timeToLive)  * (1.0 / 60);
	particle->deltaColor.b = ((end.b - start.b) / particle->timeToLive)  * (1.0 / 60);
	particle->deltaColor.a = ((end.a - start.a) / particle->timeToLive)  * (1.0 / 60);
    
    // Calculate the rotation and it's delta to be applied each cycle
    GLfloat startA = rotationStart + rotationStartVariance * RANDOM_MINUS_1_TO_1();
    GLfloat endA = rotationEnd + rotationEndVariance * RANDOM_MINUS_1_TO_1();
    particle->rotation = startA;
    particle->rotationDelta = (endA - startA) / particle->timeToLive;

}

- (void)parseParticleConfig:(TBXML*)aConfig {

	TBXMLElement *rootXMLElement = aConfig.rootXMLElement;
	
	// Make sure we have a root element or we cant process this file
	if (!rootXMLElement) {
		NSLog(@"ERROR - ParticleEmitter: Could not find root element in particle config file.");
	}
	
	TBXMLElement *textureElement = [TBXML childElementNamed:@"texture" parentElement:rootXMLElement];
	if (textureElement) {
        textureFileName = [TBXML textForElement:textureElement];
	}
    
    // We must have a texture otherwise we should stop
    NSAssert([textureFileName length] > 0, @"textureName is missing from the pex file");
	
	// Load all of the values from the XML file into the particle emitter.  The functions below are using the
	// TBXMLAdditions category.  This adds convenience methods to TBXML to help cut down on the code in this method.
    rate = [aConfig floatValueFromChildElementNamed:@"emissionRate" parentElement:rootXMLElement];
	sourcePosition = [aConfig SSVertex3DFromChildElementNamed:@"sourcePosition" parentElement:rootXMLElement];
	sourcePositionVariance = [aConfig SSVertex3DFromChildElementNamed:@"sourcePositionVariance" parentElement:rootXMLElement];
	speed = [aConfig floatValueFromChildElementNamed:@"speed" parentElement:rootXMLElement];
	speedVariance = [aConfig floatValueFromChildElementNamed:@"speedVariance" parentElement:rootXMLElement];
	particleLifespan = [aConfig floatValueFromChildElementNamed:@"particleLifeSpan" parentElement:rootXMLElement];
	particleLifespanVariance = [aConfig floatValueFromChildElementNamed:@"particleLifespanVariance" parentElement:rootXMLElement];
	angle = [aConfig SSVertex3DFromChildElementNamed:@"angle" parentElement:rootXMLElement];
	angleVariance = [aConfig SSVertex3DFromChildElementNamed:@"angleVariance" parentElement:rootXMLElement];
	gravity = [aConfig SSVertex3DFromChildElementNamed:@"gravity" parentElement:rootXMLElement];
	maxParticles = [aConfig floatValueFromChildElementNamed:@"maxParticles" parentElement:rootXMLElement];
	startParticleSize = [aConfig floatValueFromChildElementNamed:@"startParticleSize" parentElement:rootXMLElement];
	startParticleSizeVariance = [aConfig floatValueFromChildElementNamed:@"startParticleSizeVariance" parentElement:rootXMLElement];	
	finishParticleSize = [aConfig floatValueFromChildElementNamed:@"finishParticleSize" parentElement:rootXMLElement];
	finishParticleSizeVariance = [aConfig floatValueFromChildElementNamed:@"finishParticleSizeVariance" parentElement:rootXMLElement];
    startColor = [aConfig GLKVector4FromChildElementNamed:@"startColor" parentElement:rootXMLElement];
	startColorVariance = [aConfig GLKVector4FromChildElementNamed:@"startColorVariance" parentElement:rootXMLElement];
	finishColor = [aConfig GLKVector4FromChildElementNamed:@"finishColor" parentElement:rootXMLElement];
	finishColorVariance = [aConfig GLKVector4FromChildElementNamed:@"finishColorVariance" parentElement:rootXMLElement];
	duration = [aConfig floatValueFromChildElementNamed:@"duration" parentElement:rootXMLElement];
    rotationStart = [aConfig floatValueFromChildElementNamed:@"rotationStart" parentElement:rootXMLElement];
    rotationStartVariance = [aConfig floatValueFromChildElementNamed:@"rotationStartVariation" parentElement:rootXMLElement];
    rotationEnd = [aConfig floatValueFromChildElementNamed:@"rotationEnd" parentElement:rootXMLElement];
    rotationEndVariance = [aConfig floatValueFromChildElementNamed:@"rotationEndVariance" parentElement:rootXMLElement];
		
	// Calculate the emission rate
	emissionRate = maxParticles / particleLifespan;

}

- (void)setupArrays {
    
	// Allocate the memory necessary for the particle emitter arrays
	particles = (Particle *)malloc( sizeof(Particle) * maxParticles );
    particleQuads = (ParticleQuad *)calloc(sizeof(ParticleQuad), maxParticles);
    indices = (GLushort *)calloc(sizeof(GLushort), maxParticles * 6);
    
    // Set up the indices for all particles. This provides an array of indices into the quads array that is used during 
    // rendering. As we are rendering quads there are six indices for each particle as each particle is made of two triangles
    // that are each defined by three vertices.
    for( int i = 0; i < maxParticles; i++) {
		indices[i*6+0] = i*4+0;
		indices[i*6+1] = i*4+1;
		indices[i*6+2] = i*4+2;
		
		indices[i*6+5] = i*4+1;
		indices[i*6+4] = i*4+2;
		indices[i*6+3] = i*4+3;
	}
	
    // Set up texture coordinates for all particles as these will not change.
    for(int i = 0; i < maxParticles; i++) {
        particleQuads[i].bl.texture.s = 0;
        particleQuads[i].bl.texture.t = 0;
        
        particleQuads[i].br.texture.s = 1;
        particleQuads[i].br.texture.t = 0;
		
        particleQuads[i].tl.texture.s = 0;
        particleQuads[i].tl.texture.t = 1;
        
        particleQuads[i].tr.texture.s = 1;
        particleQuads[i].tr.texture.t = 1;
	}

    // Generate the buffer array and bind the necessary 
    glGenBuffers(1, &vertexBufferName);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferName);
    glBufferData(GL_ARRAY_BUFFER, sizeof(ParticleQuad) * maxParticles, particleQuads, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

	// By default the particle emitter is not active when created
	active = NO;
	
	// Set the particle count to zero
	particleCount = 0;
	
	// Reset the elapsed time
	elapsedTime = 0;	
}

int compare (const void *a, const void *b) {
    Particle *ia = (Particle*)a;
    Particle *ib = (Particle*)b;
    return (int)ib->distanceToCamera - ia->distanceToCamera; // Subtract b from a so the array is sorted from furthest to closest
}

@end

