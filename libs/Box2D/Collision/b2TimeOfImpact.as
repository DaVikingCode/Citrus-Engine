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

package Box2D.Collision {

	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	
use namespace b2internal;


/**
* @private
*/
public class b2TimeOfImpact
{
	
	private static var b2_toiCalls:int = 0;
	private static var b2_toiIters:int = 0;
	private static var b2_toiMaxIters:int = 0;
	private static var b2_toiRootIters:int = 0;
	private static var b2_toiMaxRootIters:int = 0;

	private static var s_cache:b2SimplexCache = new b2SimplexCache();
	private static var s_distanceInput:b2DistanceInput = new b2DistanceInput();
	private static var s_xfA:b2Transform = new b2Transform();
	private static var s_xfB:b2Transform = new b2Transform();
	private static var s_fcn:b2SeparationFunction = new b2SeparationFunction();
	private static var s_distanceOutput:b2DistanceOutput = new b2DistanceOutput();
	public static function TimeOfImpact(input:b2TOIInput):Number
	{
		++b2_toiCalls;
		
		var proxyA:b2DistanceProxy = input.proxyA;
		var proxyB:b2DistanceProxy = input.proxyB;
		
		var sweepA:b2Sweep = input.sweepA;
		var sweepB:b2Sweep = input.sweepB;
		
		b2Settings.b2Assert(sweepA.t0 == sweepB.t0);
		b2Settings.b2Assert(1.0 - sweepA.t0 > Number.MIN_VALUE);
		
		var radius:Number = proxyA.m_radius + proxyB.m_radius;
		var tolerance:Number = input.tolerance;
		
		var alpha:Number = 0.0;
		
		const k_maxIterations:int = 1000; //TODO_ERIN b2Settings
		var iter:int = 0;
		var target:Number = 0.0;
		
		// Prepare input for distance query.
		s_cache.count = 0;
		s_distanceInput.useRadii = false;
		
		for (;; )
		{
			sweepA.GetTransform(s_xfA, alpha);
			sweepB.GetTransform(s_xfB, alpha);
			
			// Get the distance between shapes
			s_distanceInput.proxyA = proxyA;
			s_distanceInput.proxyB = proxyB;
			s_distanceInput.transformA = s_xfA;
			s_distanceInput.transformB = s_xfB;
			
			b2Distance.Distance(s_distanceOutput, s_cache, s_distanceInput);
			
			if (s_distanceOutput.distance <= 0.0)
			{
				alpha = 1.0;
				break;
			}
			
			s_fcn.Initialize(s_cache, proxyA, s_xfA, proxyB, s_xfB);
			
			var separation:Number = s_fcn.Evaluate(s_xfA, s_xfB);
			if (separation <= 0.0)
			{
				alpha = 1.0;
				break;
			}
			
			if (iter == 0)
			{
				// Compute a reasonable target distance to give some breathing room
				// for conservative advancement. We take advantage of the shape radii
				// to create additional clearance
				if (separation > radius)
				{
					target = b2Math.Max(radius - tolerance, 0.75 * radius);
				}
				else
				{
					target = b2Math.Max(separation - tolerance, 0.02 * radius);
				}
			}
			
			if (separation - target < 0.5 * tolerance)
			{
				if (iter == 0)
				{
					alpha = 1.0;
					break;
				}
				break;
			}
			
//#if 0
			// Dump the curve seen by the root finder
			//{
				//const N:int = 100;
				//var dx:Number = 1.0 / N;
				//var xs:Vector.<Number> = new Array(N + 1);
				//var fs:Vector.<Number> = new Array(N + 1);
				//
				//var x:Number = 0.0;
				//for (var i:int = 0; i <= N; i++)
				//{
					//sweepA.GetTransform(xfA, x);
					//sweepB.GetTransform(xfB, x);
					//var f:Number = fcn.Evaluate(xfA, xfB) - target;
					//
					//trace(x, f);
					//xs[i] = x;
					//fx[i] = f'
					//
					//x += dx;
				//}
			//}
//#endif
			// Compute 1D root of f(x) - target = 0
			var newAlpha:Number = alpha;
			{
				var x1:Number = alpha;
				var x2:Number = 1.0;
				
				var f1:Number = separation;
				
				sweepA.GetTransform(s_xfA, x2);
				sweepB.GetTransform(s_xfB, x2);
				
				var f2:Number = s_fcn.Evaluate(s_xfA, s_xfB);
				
				// If intervals don't overlap at t2, then we are done
				if (f2 >= target)
				{
					alpha = 1.0;
					break;
				}
				
				// Determine when intervals intersect
				var rootIterCount:int = 0;
				for (;; )
				{
					// Use a mis of the secand rule and bisection
					var x:Number;
					if (rootIterCount & 1)
					{
						// Secant rule to improve convergence
						x = x1 + (target - f1) * (x2 - x1) / (f2 - f1);
					}
					else
					{
						// Bisection to guarantee progress
						x = 0.5 * (x1 + x2);
					}
					
					sweepA.GetTransform(s_xfA, x);
					sweepB.GetTransform(s_xfB, x);
					
					var f:Number = s_fcn.Evaluate(s_xfA, s_xfB);
					
					if (b2Math.Abs(f - target) < 0.025 * tolerance)
					{
						newAlpha = x;
						break;
					}
					
					// Ensure we continue to bracket the root
					if (f > target)
					{
						x1 = x;
						f1 = f;
					}
					else
					{
						x2 = x;
						f2 = f;
					}
					
					++rootIterCount;
					++b2_toiRootIters;
					if (rootIterCount == 50)
					{
						break;
					}
				}
				
				b2_toiMaxRootIters = b2Math.Max(b2_toiMaxRootIters, rootIterCount);
			}
			
			// Ensure significant advancement
			if (newAlpha < (1.0 + 100.0 * Number.MIN_VALUE) * alpha)
			{
				break;
			}
			
			alpha = newAlpha;
			
			iter++;
			++b2_toiIters;
			
			if (iter == k_maxIterations)
			{
				break;
			}
		}
		
		b2_toiMaxIters = b2Math.Max(b2_toiMaxIters, iter);

		return alpha;
	}

}

}
