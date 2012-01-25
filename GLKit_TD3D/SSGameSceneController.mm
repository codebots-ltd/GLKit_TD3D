//
//  SSViewController.m
//  GLKit_TD3D
//
//  Created by Michael Daley on 12/09/2011.
//  Copyright (c) 2011 71Squared. All rights reserved.
//

#import "SSGameSceneController.h"
#import "AssetManager.h"
#import "SSModel.h"
#import "EnemyFighter.h"
#import "EnemyBomber.h"
#import "Light.h"
#import "btBulletCollisionCommon.h"
#import "GLDebugDrawer.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#pragma mark - Private Interface

@interface SSGameSceneController () {

    GLKMatrix3 normalMatrix;
    NSMutableArray *ships;
    GLKSkyboxEffect *skyBoxEffect;
    GLKTextureInfo *skyboxTexture;
    Light *light;
    btCollisionWorld *collisionWorld;

    // Motion Manager
    BOOL coreMotionEnabled;
    CMMotionManager *motionManager;
    CMAttitude *attitude;
    
    GLDebugDrawer debugDrawer;
    
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) GLKBaseEffect *bulletDebugEffect;

// Private methods
- (void)setupGL;
- (void)tearDownGL;
- (void)initScene;
- (void)initPhysics;
- (void)initCoreMotion;

@end

#pragma mark - Public Implementation

@implementation SSGameSceneController

@synthesize context = _context;
@synthesize effect = _effect;
@synthesize bulletDebugEffect;

@synthesize sceneModelMatrix;
@synthesize assetManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.contentScaleFactor = 1;
    self.preferredFramesPerSecond = 60;
    
    // Set up the asset manager
    assetManager = [[AssetManager alloc] init];
    
    [self setupGL];
    [self initCoreMotion];
    [self initPhysics];
    [self initScene];
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//    } else {
//        return YES;
//    }
    return NO;

}

#pragma mark - Setup/tear down OpenGL

- (void)setupGL
{
    NSLog(@"Setting up OpenGL...");
    
    [EAGLContext setCurrentContext:self.context];
    
    // Calculate the projection matrix and apply it to the effect
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 500.0f);

    // Setup the skybox
    NSString *path = [[NSBundle mainBundle] pathForResource:@"skybox_texture" ofType:@"png"];
    NSError *outError;
    skyboxTexture = [GLKTextureLoader cubeMapWithContentsOfFile:path options:nil error:&outError];
    NSAssert1(!outError, @"Error occured loading skybox texture: %@", outError.localizedDescription);

    skyBoxEffect = [[GLKSkyboxEffect alloc] init];
    skyBoxEffect.textureCubeMap.name = skyboxTexture.name;
    skyBoxEffect.center = GLKVector3Make(0, 0, 0);
    skyBoxEffect.xSize = 500;
    skyBoxEffect.ySize = 500;
    skyBoxEffect.zSize = 500;
    skyBoxEffect.transform.projectionMatrix = projectionMatrix;
    
    // Setup the base effect shader for core rendering
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.position = GLKVector4Make(0, 0, 0, 1);
    self.effect.light0.ambientColor = GLKVector4Make(1, 1, 1, 1);
    self.effect.material.shininess = 20.0;
    self.effect.material.specularColor = GLKVector4Make(1, 1, 1, 1);
    self.effect.lightingType = GLKLightingTypePerPixel;
    self.effect.texture2d0.envMode = GLKTextureEnvModeModulate;
    self.effect.useConstantColor = GL_FALSE;
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    // Set up a shader to use when rendering the buller debug info
    self.bulletDebugEffect = [[GLKBaseEffect alloc] init];
    self.bulletDebugEffect.useConstantColor = GL_TRUE;
    self.bulletDebugEffect.constantColor = GLKVector4Make(0, 1, 0, 1);
    self.bulletDebugEffect.transform.projectionMatrix = projectionMatrix;
    
    // Static OpenGL states
    glClearColor(0, 0, 0, 1.0f);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
//    glDeleteBuffers(1, &vertexBuffer);
//    glDeleteVertexArraysOES(1, &vertexArray);
    
    self.effect = nil;
    self.bulletDebugEffect = nil;
    skyBoxEffect = nil;
    
}

#pragma mark - Initialize Scene

- (void)initScene {
    
    NSLog(@"Initializing Scene...");
    // Init the dictionary that will hold our ship instances and create some
    ships = [[NSMutableArray alloc] init];
    for (int i = 0; i < 2; i+=2) {
        EnemyFighter *shipModel = [[EnemyFighter alloc] initWithScene:self];
        shipModel.shader = self.effect;
        shipModel.position = GLKVector3Make(-3, 0, -10);
        [shipModel addToCollisionWorld:collisionWorld];
        [ships addObject:shipModel];
        EnemyBomber *bomberModel = [[EnemyBomber alloc] initWithScene:self];
        bomberModel.shader = self.effect;
        bomberModel.position = GLKVector3Make(3, 0, -15);
        [bomberModel addToCollisionWorld:collisionWorld];
        [ships addObject:bomberModel];
    }
    
    light = [[Light alloc] initWithScene:self];
    light.shader = self.effect;
    light.position = GLKVector3Make(-5, 0, -10);
}

- (void)initCoreMotion
{
    NSLog(@"Initializing CoreMotion...");
    
    // By default coremotion is not enabled
    coreMotionEnabled = NO;
    
    // Creation a CMMotionManager instance
    motionManager = [[CMMotionManager alloc] init];
    
    // Make sure the data we need is available
    if (!motionManager.deviceMotionAvailable) {
        NSLog(@"CoreMotion Not Available");
        return;
    }

    // Set up the desired update interval
    motionManager.deviceMotionUpdateInterval = 1.0f / 60;
    motionManager.gyroUpdateInterval = 1.0f / 60;
    
    // Start updates
    [motionManager startDeviceMotionUpdates];
    [motionManager startGyroUpdates];
    coreMotionEnabled = YES;
    
}

- (void)initPhysics
{

    NSLog(@"Initializing Bullet Physics...");
    
    // Configure the bullet collision world parameters. This includes setting up the default collision
    // dispatcher as well as the bounds for the collision worlds AABB checking. This needs to be as large
    // as the world in which colliions will be taking place
    btDefaultCollisionConfiguration *collisionConfiguration = new btDefaultCollisionConfiguration();
    btCollisionDispatcher *collisionDispatcher = new btCollisionDispatcher(collisionConfiguration);
    btVector3 worldAabbMin(-500, -500, -500);
    btVector3 worldAabbMax(500, 500, 500);
    
    // Configure the broadphase to be used in the collision world. This will detect collisions of objects
    // AABB
    btAxisSweep3 *broadphase = new btAxisSweep3(worldAabbMin, worldAabbMax);
    
    collisionWorld = new btCollisionWorld(collisionDispatcher, broadphase, collisionConfiguration);
    
    debugDrawer.setDebugMode(btIDebugDraw::DBG_DrawWireframe);
    debugDrawer.setShader(bulletDebugEffect);
    collisionWorld->setDebugDrawer(&debugDrawer);
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{

    // Check for any collisions. This initial check will identify AABB collisions between objects. This
    // is then followed up by a more detailed OBB collision check
    int numManifolds = collisionWorld->getDispatcher()->getNumManifolds();
    for (int i=0; i < numManifolds; i++)
    {
        // Get the manifold information and extract the two objects that have collided
        btPersistentManifold *contactManifold =  collisionWorld->getDispatcher()->getManifoldByIndexInternal(i);
		btCollisionObject *colObjA = static_cast<btCollisionObject*>(contactManifold->getBody0());
		btCollisionObject *colObjB = static_cast<btCollisionObject*>(contactManifold->getBody1());
        
        // Having detected a collision between the objects OBB, now check to see if there are any actual contacts
        // between the two objects. Only if there are and the distance is <= 0 should a collision be reported.
        int numContacts = contactManifold->getNumContacts();
        for (int j=0;j<numContacts;j++)
        {
            btManifoldPoint& pt = contactManifold->getContactPoint(j);
            if (pt.getDistance()<=0.f)
            {
                NSLog(@"bang");
                // Pass each object the object with which it has collided
//                SSAbstractObject *objectA = (__bridge_transfer SSAbstractObject*)colObjA->getUserPointer();
//                SSAbstractObject *objectB = (__bridge_transfer SSAbstractObject*)colObjB->getUserPointer();
//                [objectA collidedWithObject:objectB];
//                [objectB collidedWithObject:objectA];
            }
        }
    }

    
    // Reset the scenes matrix
    sceneModelMatrix = GLKMatrix4Identity;
    
    // Grab the current attitude from core motion and get it's matrix
    attitude = motionManager.deviceMotion.attitude;
    CMRotationMatrix rm = attitude.rotationMatrix;

    // Transpose the matrix while loading it into a GLK compatible structure
    GLKMatrix4 deviceMatrix = GLKMatrix4MakeAndTranspose(rm.m11, rm.m12, rm.m13, 0, 
                                                         rm.m21, rm.m22, rm.m23, 0, 
                                                         rm.m31, rm.m32, rm.m33, 
                                                         0, 0, 0, 0, 1);
    
    // Apply rotation to the X and Y axis so that movement of the device is oriented with the OGL world
    deviceMatrix = GLKMatrix4RotateX(deviceMatrix, GLKMathDegreesToRadians(90));
    deviceMatrix = GLKMatrix4RotateY(deviceMatrix, GLKMathDegreesToRadians(-90));
    
    // Multiply our scene and device matrices together. This will cause all objects to then be rendered 
    // based on the rotation of the device giving the appearance that we are looking around inside our
    // 3D world
    sceneModelMatrix = GLKMatrix4Multiply(sceneModelMatrix, deviceMatrix);
    
    // Update each fighter in the game
    for (EnemyFighter *fighter in ships) {
        [fighter updateWithDelta:self.timeSinceLastUpdate];
    }
    
    [light updateWithDelta:self.timeSinceLastUpdate];
    
    // Update the collision world
    collisionWorld->performDiscreteCollisionDetection();

}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    skyBoxEffect.transform.modelviewMatrix = sceneModelMatrix;
    [skyBoxEffect prepareToDraw];
    [skyBoxEffect draw];
    
    // Ask all the ships in the ships array to render
    [ships makeObjectsPerformSelector:@selector(render)];
    
//    [light render];
    
    glPushGroupMarkerEXT(0, "Bullet Debug");
    bulletDebugEffect.transform.modelviewMatrix = sceneModelMatrix;
//    collisionWorld->debugDrawWorld();
    glPopGroupMarkerEXT();
    
    // We don't need the current contents of the depth buffer in the next frame as we are clearing it
    // so discarding it can provide a small but simple performance boost
    const GLenum discards[]  = {GL_DEPTH_ATTACHMENT};
    glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, discards);
    
}

@end
