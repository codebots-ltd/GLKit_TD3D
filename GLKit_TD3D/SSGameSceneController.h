//
//  SSViewController.h
//  GLKit_TD3D
//
//  Created by Michael Daley on 12/09/2011.
//  Copyright (c) 2011 71Squared. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>
#import "OpenGLCommon.h"

@class AssetManager;

@interface SSGameSceneController : GLKViewController {
    GLKMatrix4 sceneModelMatrix;
    AssetManager __strong *assetManager;
}
    
@property (nonatomic) GLKMatrix4 sceneModelMatrix;
@property (nonatomic, strong) AssetManager *assetManager;

@end
