/*
* Copyright (c) 2006-2007 Adam Newgas
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

package Box2D.Dynamics.Controllers{

	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;


/**
 * Calculates buoyancy forces for fluids in the form of a half plane
 */
public class b2BuoyancyController extends b2Controller
{
	public function b2BuoyancyController() {}
	
	/**
	 * The outer surface normal
	 */
	public var normal:b2Vec2 = new b2Vec2(0,-1);
	/**
	 * The height of the fluid surface along the normal
	 */
	public var offset:Number = 0;
	/**
	 * The fluid density
	 */
	public var density:Number = 0;
	/**
	 * Fluid velocity, for drag calculations
	 */
	public var velocity:b2Vec2 = new b2Vec2(0,0);
	/**
	 * Linear drag co-efficient
	 */
	public var linearDrag:Number = 2;
	/**
	 * Linear drag co-efficient
	 */
	public var angularDrag:Number = 1;
	/**
	 * If false, bodies are assumed to be uniformly dense, otherwise use the shapes densities
	 */
	public var useDensity:Boolean = false; //False by default to prevent a gotcha
	/**
	 * If true, gravity is taken from the world instead of the gravity parameter.
	 */
	public var useWorldGravity:Boolean = true;
	/**
	 * Gravity vector, if the world's gravity is not used
	 */
	public var gravity:b2Vec2 = null;
	
		
	public override function Step(step:b2TimeStep):void{
		if(!m_bodyList)
			return;
		if(useWorldGravity){
			gravity = GetWorld().GetGravity().Copy();
		}
		for(var i:b2ControllerEdge=m_bodyList;i;i=i.nextBody){
			var body:b2Body = i.body;
			if(body.IsAwake() == false){
				//Buoyancy force is just a function of position,
				//so unlike most forces, it is safe to ignore sleeping bodes
				continue;
			}
			var areac:b2Vec2 = new b2Vec2();
			var massc:b2Vec2 = new b2Vec2();
			var area:Number = 0.0;
			var mass:Number = 0.0;
			for(var fixture:b2Fixture=body.GetFixtureList();fixture;fixture=fixture.GetNext()){
				var sc:b2Vec2 = new b2Vec2();
				var sarea:Number = fixture.GetShape().ComputeSubmergedArea(normal, offset, body.GetTransform(), sc);
				area += sarea;
				areac.x += sarea * sc.x;
				areac.y += sarea * sc.y;
				var shapeDensity:Number;
				if (useDensity) {
					//TODO: Figure out what to do now density is gone
					shapeDensity = 1;
				}else{
					shapeDensity = 1;
				}
				mass += sarea*shapeDensity;
				massc.x += sarea * sc.x * shapeDensity;
				massc.y += sarea * sc.y * shapeDensity;
			}
			areac.x/=area;
			areac.y/=area;
			massc.x/=mass;
			massc.y/=mass;
			if(area<Number.MIN_VALUE)
				continue;
			//Buoyancy
			var buoyancyForce:b2Vec2 = gravity.GetNegative();
			buoyancyForce.Multiply(density*area)
			body.ApplyForce(buoyancyForce,massc);
			//Linear drag
			var dragForce:b2Vec2 = body.GetLinearVelocityFromWorldPoint(areac);
			dragForce.Subtract(velocity);
			dragForce.Multiply(-linearDrag*area);
			body.ApplyForce(dragForce,areac);
			//Angular drag
			//TODO: Something that makes more physical sense?
			body.ApplyTorque(-body.GetInertia()/body.GetMass()*area*body.GetAngularVelocity()*angularDrag)
			
		}
	}
	
	public override function Draw(debugDraw:b2DebugDraw):void
	{
		var r:Number = 1000;
		//Would like to draw a semi-transparent box
		//But debug draw doesn't support that
		var p1:b2Vec2 = new b2Vec2();
		var p2:b2Vec2 = new b2Vec2();
		p1.x = normal.x * offset + normal.y * r;
		p1.y = normal.y * offset - normal.x * r;
		p2.x = normal.x * offset - normal.y * r;
		p2.y = normal.y * offset + normal.x * r;
		var color:b2Color = new b2Color(0,0,1);
		debugDraw.DrawSegment(p1,p2,color);
	}
}

}