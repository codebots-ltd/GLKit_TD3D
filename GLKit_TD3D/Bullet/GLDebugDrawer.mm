//
//  GLDebugDrawer.mm
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

#include "GLDebugDrawer.h"

GLDebugDrawer::GLDebugDrawer():m_debugMode(0)
{

}

void    GLDebugDrawer::drawLine(const btVector3& from,const btVector3& to,const btVector3& color)
{
    tmp[0] = from.getX();
    tmp[1] = from.getY();
    tmp[2] = from.getZ();
    tmp[3] = to.getX();
    tmp[4] = to.getY();
    tmp[5] = to.getZ();

    debugEffect.constantColor = GLKVector4Make(color.getX(), color.getY(), color.getZ(), 1.0f);
    [debugEffect prepareToDraw];

    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferName);
    glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 6, tmp, GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 3, 0);
    glDisableVertexAttribArray(GLKVertexAttribColor);
    glLineWidth(1.0f);
    glDrawArrays( GL_LINES, 0, 2 );
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
    NSLog(@"%@", warningString);
}

void    GLDebugDrawer::drawContactPoint(const btVector3& pointOnB,const btVector3& normalOnB,btScalar distance,int lifeTime,const btVector3& color)
{
    btVector3 to=pointOnB+normalOnB*distance;
    const btVector3&from = pointOnB;
    glColor4f(color.getX(), color.getY(), color.getZ(), 1.0f);   
    
    GLDebugDrawer::drawLine(from, to, color);
}

