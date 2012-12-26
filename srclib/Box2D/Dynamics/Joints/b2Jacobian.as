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

package Box2D.Dynamics.Joints{


	import Box2D.Common.Math.*;
	import Box2D.Common.b2internal;
use namespace b2internal;


/**
* @private
*/
public class b2Jacobian
{
	public function b2Jacobian() {}
	
	public var linearA:b2Vec2 = new b2Vec2();
	public var angularA:Number;
	public var linearB:b2Vec2 = new b2Vec2();
	public var angularB:Number;

	public function SetZero() : void{
		linearA.SetZero(); angularA = 0.0;
		linearB.SetZero(); angularB = 0.0;
	}
	public function Set(x1:b2Vec2, a1:Number, x2:b2Vec2, a2:Number) : void{
		linearA.SetV(x1); angularA = a1;
		linearB.SetV(x2); angularB = a2;
	}
	public function Compute(x1:b2Vec2, a1:Number, x2:b2Vec2, a2:Number):Number{
		
		//return b2Math.b2Dot(linearA, x1) + angularA * a1 + b2Math.b2Dot(linearV, x2) + angularV * a2;
		return (linearA.x*x1.x + linearA.y*x1.y) + angularA * a1 + (linearB.x*x2.x + linearB.y*x2.y) + angularB * a2;
	}
};


}