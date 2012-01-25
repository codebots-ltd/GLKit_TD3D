//
//  GLDebugDrawer.mm
//  TD3D
//
//  Created by Mike Daley on 03/09/2010.
//  Copyright 2010 71Squared. All rights reserved.
//

#include "GLDebugDrawer.h"

GLDebugDrawer::GLDebugDrawer():m_debugMode(0)
{
    
}

void    GLDebugDrawer::drawLine(const btVector3& from,const btVector3& to,const btVector3& color)
{
    {
        float tmp[ 6 ] = { from.getX(), from.getY(), from.getZ(),
            to.getX(), to.getY(), to.getZ() };

        glBindBuffer(GL_ARRAY_BUFFER, vertexBufferName);
        glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 6, tmp, GL_DYNAMIC_DRAW);

        debugEffect.constantColor = GLKVector4Make(color.getX(), color.getY(), color.getZ(), 1.0f);
        [debugEffect prepareToDraw];
        
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 3, 0);
        
        glDrawArrays( GL_LINES, 0, 2 );

        glBindBuffer(GL_ARRAY_BUFFER, 0);

        glPopGroupMarkerEXT();

    }
}

void    GLDebugDrawer::setShader(GLKBaseEffect *shaderEffect)
{
    debugEffect = shaderEffect;
    glGenBuffers(1, &vertexBufferName);
}

void    GLDebugDrawer::setDebugMode(int debugMode)
{
    m_debugMode = debugMode;
}

void    GLDebugDrawer::draw3dText(const btVector3& location,const char* textString)
{

}

void    GLDebugDrawer::reportErrorWarning(const char* warningString)
{
//    DLog(@"%S", warningString);
}

void    GLDebugDrawer::drawContactPoint(const btVector3& pointOnB,const btVector3& normalOnB,btScalar distance,int lifeTime,const btVector3& color)
{
    {
        btVector3 to=pointOnB+normalOnB*distance;
        const btVector3&from = pointOnB;
        glColor4f(color.getX(), color.getY(), color.getZ(), 1.0f);   
        
        GLDebugDrawer::drawLine(from, to, color);
    }
}

