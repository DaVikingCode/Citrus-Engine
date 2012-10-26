/*
* Copyright (c) 2006-2007 Erin Catto http://www.gphysics.com
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

package Box2D.Dynamics{


	import Box2D.Common.*;
	import Box2D.Dynamics.Joints.*;
use namespace b2internal;


/**
* Joints and shapes are destroyed when their associated
* body is destroyed. Implement this listener so that you
* may nullify references to these joints and shapes.
*/
public class b2DestructionListener
{

	/**
	* Called when any joint is about to be destroyed due
	* to the destruction of one of its attached bodies.
	*/
	public virtual function SayGoodbyeJoint(joint:b2Joint) : void{};

	/**
	* Called when any fixture is about to be destroyed due
	* to the destruction of its parent body.
	*/
	public virtual function SayGoodbyeFixture(fixture:b2Fixture) : void{};
	
};

}
