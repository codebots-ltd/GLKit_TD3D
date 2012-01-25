//
//  TBXMLParticleAdditions.h
//  ParticleEmitterDemo
//
// Copyright (c) 2010 71Squared
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

#import "TBXML.h"
#import "OpenGLCommon.h"

// This is a category that has been added to the TBML class.  Reading specific attributes from a
// particle emitter XML config file is not something the TBXML class should be altered for.  This
// is a perfect opportunity to create a category on top of TBXML that adds specfic features that
// meet our needs when processing the particle config files.
//
// The new methods below grab data from specific attributes that we know will contain the information
// we need in a particle config file and returns values that are specific to our implementation such 
// as Color4f and Vector4f
//
// These changes will only work when processing the particle config files and a further category would
// need to be made to process other types of data if necessary
//
@interface TBXML (TBXMLParticleAdditions)

// Returns a int value from the processes element
- (float) intValueFromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement;

// Returns a float value from the processes element
- (float) floatValueFromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement;

// Returns a bool value from the processes element
- (BOOL) boolValueFromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement;

// Returns a SSVertex3D structure from the processes element
- (GLKVector3) SSVertex3DFromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement;

// Returns a GLKVector4 structure from the processes element
- (GLKVector4)GLKVector4FromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement;

@end
