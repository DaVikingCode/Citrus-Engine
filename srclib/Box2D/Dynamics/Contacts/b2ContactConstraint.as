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

package Box2D.Dynamics.Contacts{


	import Box2D.Collision.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
use namespace b2internal;


/**
* @private
*/
public class b2ContactConstraint
{
	public function b2ContactConstraint(){
		points = new Vector.<b2ContactConstraintPoint>(b2Settings.b2_maxManifoldPoints);
		for (var i:int = 0; i < b2Settings.b2_maxManifoldPoints; i++){
			points[i] = new b2ContactConstraintPoint();
		}
		
		
	}
	public var points:Vector.<b2ContactConstraintPoint>;
	public var localPlaneNormal:b2Vec2 = new b2Vec2();
	public var localPoint:b2Vec2 = new b2Vec2();
	public var normal:b2Vec2 = new b2Vec2();
	public var normalMass:b2Mat22 = new b2Mat22();
	public var K:b2Mat22 = new b2Mat22();
	public var bodyA:b2Body;
	public var bodyB:b2Body;
	public var type:int;//b2Manifold::Type
	public var radius:Number;
	public var friction:Number;
	public var restitution:Number;
	public var pointCount:int;
	public var manifold:b2Manifold;
};


}