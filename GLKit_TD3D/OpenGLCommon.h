//
//  Strctures.h
//  GLKit_TD3D
//
//  Created by Michael Daley on 14/09/2011.
//  Copyright (c) 2011 71Squared. All rights reserved.
//

#ifndef GLKit_TD3D_Strctures_h
#define GLKit_TD3D_Strctures_h

typedef struct {
    float red;
    float green;
    float blue;
    float alpha;
} SSColor;

typedef struct {
    float x;
    float y;
} SSVertex2D;

typedef struct {
    float x;
    float y;
    float z;
} SSVertex3D;

typedef struct {
    SSVertex3D    vertex;
    SSVertex3D    normal;
} SSVertexData3D;

typedef struct {
    SSVertex3D    vertex;
    SSVertex3D    normal;
    SSVertex2D    texCoord;
} SSTexturedVertexData3D;

typedef struct {
    SSVertex3D      vertex;
    SSVertex3D      normal;
    SSColor         color;
} SSColoredVertexData3D;


#endif
