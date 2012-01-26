### What is GLKit_TD3D

GLKit_TD3D is a 3D prototype game tech demo that uses the new iOS 5 GLKit features and Arc. It's a space shooter in which the player is in a static location surrounded by enemy ships firing at the player. The player must physically move their iPhone or iPad up, down, and 360 degrees around to see the ships, track them and shoot at them. The code uses the gyroscope in the iPhone/iPad to work out where the player is looking within the 3D world.

### Features

* Collision detection managed using the Bullet 3D physics engine
* All rendering is performed using iOS 5 GLKit including skybox, texturing and Vertex Array Objects
* Gyroscope based movement providing the players view into the 3D world
* 3D particle system for explosions, sparks on enemy ships when hit and enemy shots at the player
* Models developed in Blender and exported using Jeff Lamarche's blender exporter script [here](https://github.com/jlamarche/iOS-OpenGLES-Stuff)

### Design Goals

* Provide an example of how the new iOS GLKit can be used to create a 3D game
* Demonstrate how Bullet 3D can be used to manage collision detection only
* Provide a framework for creating a game that contains different scenes without using a pre-built engine

### What Now?

Take a look, have a play and enjoy. If this inspires you and you create something based on this code then share it with us as we love to see what people are doing :o)

<br/>
### MIT License
  Copyright 2012 71Squared All rights reserved.
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.