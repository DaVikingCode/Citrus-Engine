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


/*
This broad phase uses the Sweep and Prune algorithm as described in:
Collision Detection in Interactive 3D Environments by Gino van den Bergen
Also, some ideas, such as using integral values for fast compares comes from
Bullet (http:/www.bulletphysics.com).
*/


// Notes:
// - we use bound arrays instead of linked lists for cache coherence.
// - we use quantized integral values for fast compares.
// - we use short indices rather than pointers to save memory.
// - we use a stabbing count for fast overlap queries (less than order N).
// - we also use a time stamp on each proxy to speed up the registration of
//   overlap query results.
// - where possible, we compare bound indices instead of values to reduce
//   cache misses (TODO_ERIN).
// - no broadphase is perfect and neither is this one: it is not great for huge
//   worlds (use a multi-SAP instead), it is not great for large objects.

/**
* @private
*/
public class b2BroadPhase implements IBroadPhase
{
//public:
	public function b2BroadPhase(worldAABB:b2AABB){
		//b2Settings.b2Assert(worldAABB.IsValid());
		var i:int;
		
		m_pairManager.Initialize(this);
		
		m_worldAABB = worldAABB;
		
		m_proxyCount = 0;
		
		// bounds array
		m_bounds = new Vector.<Vector.<b2Bound> >();
		for (i = 0; i < 2; i++){
			m_bounds[i] = new Vector.<b2Bound>();
		}
		
		//b2Vec2 d = worldAABB.upperBound - worldAABB.lowerBound;
		var dX:Number = worldAABB.upperBound.x - worldAABB.lowerBound.x;;
		var dY:Number = worldAABB.upperBound.y - worldAABB.lowerBound.y;
		
		m_quantizationFactor.x = b2Settings.USHRT_MAX / dX;
		m_quantizationFactor.y = b2Settings.USHRT_MAX / dY;
		
		m_timeStamp = 1;
		m_queryResultCount = 0;
	}
	//~b2BroadPhase();
	
	// Use this to see if your proxy is in range. If it is not in range,
	// it should be destroyed. Otherwise you may get O(m^2) pairs, where m
	// is the number of proxies that are out of range.
	public function InRange(aabb:b2AABB):Boolean{
		//b2Vec2 d = b2Max(aabb.lowerBound - m_worldAABB.upperBound, m_worldAABB.lowerBound - aabb.upperBound);
		var dX:Number;
		var dY:Number;
		var d2X:Number;
		var d2Y:Number;
		
		dX = aabb.lowerBound.x;
		dY = aabb.lowerBound.y;
		dX -= m_worldAABB.upperBound.x;
		dY -= m_worldAABB.upperBound.y;
		
		d2X = m_worldAABB.lowerBound.x;
		d2Y = m_worldAABB.lowerBound.y;
		d2X -= aabb.upperBound.x;
		d2Y -= aabb.upperBound.y;
		
		dX = b2Math.Max(dX, d2X);
		dY = b2Math.Max(dY, d2Y);
		
		return b2Math.Max(dX, dY) < 0.0;
	}

	// Create and destroy proxies. These call Flush first.
	public function CreateProxy(aabb:b2AABB, userData:*):*{
		var index:uint;
		var proxy:b2Proxy;
		var i:int;
		var j:int;
		
		//b2Settings.b2Assert(m_proxyCount < b2_maxProxies);
		//b2Settings.b2Assert(m_freeProxy != b2Pair.b2_nullProxy);
		
		if (!m_freeProxy)
		{
			// As all proxies are allocated, m_proxyCount == m_proxyPool.length
			m_freeProxy = m_proxyPool[m_proxyCount] = new b2Proxy();
			m_freeProxy.next = null;
			m_freeProxy.timeStamp = 0;
			m_freeProxy.overlapCount = b2_invalid;
			m_freeProxy.userData = null;
			
			for (i = 0; i < 2; i++)
			{
				j = m_proxyCount * 2;
				m_bounds[i][j++] = new b2Bound();
				m_bounds[i][j] = new b2Bound();
			}
			
		}
		
		proxy = m_freeProxy;
		m_freeProxy = proxy.next;
		
		proxy.overlapCount = 0;
		proxy.userData = userData;
		
		var boundCount:uint = 2 * m_proxyCount;
		
		var lowerValues:Vector.<Number> = new Vector.<Number>();
		var upperValues:Vector.<Number> = new Vector.<Number>();
		ComputeBounds(lowerValues, upperValues, aabb);
		
		for (var axis:int = 0; axis < 2; ++axis)
		{
			var bounds:Vector.<b2Bound> = m_bounds[axis];
			var lowerIndex:uint;
			var upperIndex:uint;
			var lowerIndexOut:Vector.<uint> = new Vector.<uint>();
			lowerIndexOut.push(lowerIndex);
			var upperIndexOut:Vector.<uint> = new Vector.<uint>();
			upperIndexOut.push(upperIndex);
			QueryAxis(lowerIndexOut, upperIndexOut, lowerValues[axis], upperValues[axis], bounds, boundCount, axis);
			lowerIndex = lowerIndexOut[0];
			upperIndex = upperIndexOut[0];
			
			bounds.splice(upperIndex, 0, bounds[bounds.length - 1]);
			bounds.length--;
			bounds.splice(lowerIndex, 0, bounds[bounds.length - 1]);
			bounds.length--;
			
			// The upper index has increased because of the lower bound insertion.
			++upperIndex;
			
			// Copy in the new bounds.
			var tBound1:b2Bound = bounds[lowerIndex];
			var tBound2:b2Bound = bounds[upperIndex];
			tBound1.value = lowerValues[axis];
			tBound1.proxy = proxy;
			tBound2.value = upperValues[axis];
			tBound2.proxy = proxy;
			
			var tBoundAS3:b2Bound = bounds[int(lowerIndex-1)];
			tBound1.stabbingCount = lowerIndex == 0 ? 0 : tBoundAS3.stabbingCount;
			tBoundAS3 = bounds[int(upperIndex-1)];
			tBound2.stabbingCount = tBoundAS3.stabbingCount;
			
			// Adjust the stabbing count between the new bounds.
			for (index = lowerIndex; index < upperIndex; ++index)
			{
				tBoundAS3 = bounds[index];
				tBoundAS3.stabbingCount++;
			}
			
			// Adjust the all the affected bound indices.
			for (index = lowerIndex; index < boundCount + 2; ++index)
			{
				tBound1 = bounds[index];
				var proxy2:b2Proxy = tBound1.proxy;
				if (tBound1.IsLower())
				{
					proxy2.lowerBounds[axis] = index;
				}
				else
				{
					proxy2.upperBounds[axis] = index;
				}
			}
		}
		
		++m_proxyCount;
		
		//b2Settings.b2Assert(m_queryResultCount < b2Settings.b2_maxProxies);
		
		for (i = 0; i < m_queryResultCount; ++i)
		{
			//b2Settings.b2Assert(m_queryResults[i] < b2_maxProxies);
			//b2Settings.b2Assert(m_proxyPool[m_queryResults[i]].IsValid());
			
			m_pairManager.AddBufferedPair(proxy, m_queryResults[i]);
		}
		
		// Prepare for next query.
		m_queryResultCount = 0;
		IncrementTimeStamp();
		
		return proxy;
	}
	
	public function DestroyProxy(proxy_:*) : void {
		var proxy:b2Proxy = proxy_ as b2Proxy;
		var tBound1:b2Bound;
		var tBound2:b2Bound;
		
		//b2Settings.b2Assert(proxy.IsValid());
		
		var boundCount:int = 2 * m_proxyCount;
		
		for (var axis:int = 0; axis < 2; ++axis)
		{
			var bounds:Vector.<b2Bound> = m_bounds[axis];
			
			var lowerIndex:uint = proxy.lowerBounds[axis];
			var upperIndex:uint = proxy.upperBounds[axis];
			tBound1 = bounds[lowerIndex];
			var lowerValue:uint = tBound1.value;
			tBound2 = bounds[upperIndex];
			var upperValue:uint = tBound2.value;
			
			bounds.splice(upperIndex, 1);
			bounds.splice(lowerIndex, 1);
			bounds.push(tBound1);
			bounds.push(tBound2);
			
			
			// Fix bound indices.
			var tEnd:int = boundCount - 2;
			for (var index:uint = lowerIndex; index < tEnd; ++index)
			{
				tBound1 = bounds[index];
				var proxy2:b2Proxy = tBound1.proxy;
				if (tBound1.IsLower())
				{
					proxy2.lowerBounds[axis] = index;
				}
				else
				{
					proxy2.upperBounds[axis] = index;
				}
			}
			
			// Fix stabbing count.
			tEnd = upperIndex - 1;
			for (var index2:int = lowerIndex; index2 < tEnd; ++index2)
			{
				tBound1 = bounds[index2];
				tBound1.stabbingCount--;
			}
			
			// Query for pairs to be removed. lowerIndex and upperIndex are not needed.
			// make lowerIndex and upper output using an array and do this for others if compiler doesn't pick them up
			var ignore:Vector.<uint> = new Vector.<uint>();
			QueryAxis(ignore, ignore, lowerValue, upperValue, bounds, boundCount - 2, axis);
		}
		
		//b2Settings.b2Assert(m_queryResultCount < b2Settings.b2_maxProxies);
		
		for (var i:int = 0; i < m_queryResultCount; ++i)
		{
			//b2Settings.b2Assert(m_proxyPool[m_queryResults[i]].IsValid());
			
			m_pairManager.RemoveBufferedPair(proxy, m_queryResults[i]);
		}
		
		// Prepare for next query.
		m_queryResultCount = 0;
		IncrementTimeStamp();
		
		// Return the proxy to the pool.
		proxy.userData = null;
		proxy.overlapCount = b2_invalid;
		proxy.lowerBounds[0] = b2_invalid;
		proxy.lowerBounds[1] = b2_invalid;
		proxy.upperBounds[0] = b2_invalid;
		proxy.upperBounds[1] = b2_invalid;
		
		proxy.next = m_freeProxy;
		m_freeProxy = proxy;
		--m_proxyCount;
	}


	// Call MoveProxy as many times as you like, then when you are done
	// call Commit to finalized the proxy pairs (for your time step).
	public function MoveProxy(proxy_:*, aabb:b2AABB, displacement:b2Vec2) : void {
		var proxy:b2Proxy = proxy_ as b2Proxy;
		
		var as3arr:Vector.<uint>;
		var as3int:int;
		
		var axis:uint;
		var index:uint;
		var bound:b2Bound;
		var prevBound:b2Bound;
		var nextBound:b2Bound;
		var nextProxyId:uint;
		var nextProxy:b2Proxy;
		
		if (proxy == null)
		{
			//b2Settings.b2Assert(false);
			return;
		}
		
		if (aabb.IsValid() == false)
		{
			//b2Settings.b2Assert(false);
			return;
		}
		
		var boundCount:uint = 2 * m_proxyCount;
		
		// Get new bound values
		var newValues:b2BoundValues = new b2BoundValues();
		ComputeBounds(newValues.lowerValues, newValues.upperValues, aabb);
		
		// Get old bound values
		var oldValues:b2BoundValues = new b2BoundValues();
		for (axis = 0; axis < 2; ++axis)
		{
			bound = m_bounds[axis][proxy.lowerBounds[axis]];
			oldValues.lowerValues[axis] = bound.value;
			bound = m_bounds[axis][proxy.upperBounds[axis]];
			oldValues.upperValues[axis] = bound.value;
		}
		
		for (axis = 0; axis < 2; ++axis)
		{
			var bounds:Vector.<b2Bound> = m_bounds[axis];
			
			var lowerIndex:uint = proxy.lowerBounds[axis];
			var upperIndex:uint = proxy.upperBounds[axis];
			
			var lowerValue:uint = newValues.lowerValues[axis];
			var upperValue:uint = newValues.upperValues[axis];
			
			bound = bounds[lowerIndex];
			var deltaLower:int = lowerValue - bound.value;
			bound.value = lowerValue;
			
			bound = bounds[upperIndex];
			var deltaUpper:int = upperValue - bound.value;
			bound.value = upperValue;
			
			//
			// Expanding adds overlaps
			//
			
			// Should we move the lower bound down?
			if (deltaLower < 0)
			{
				index = lowerIndex;
				while (index > 0 && lowerValue < (bounds[int(index-1)] as b2Bound).value)
				{
					bound = bounds[index];
					prevBound = bounds[int(index - 1)];
					
					var prevProxy:b2Proxy = prevBound.proxy;
					
					prevBound.stabbingCount++;
					
					if (prevBound.IsUpper() == true)
					{
						if (TestOverlapBound(newValues, prevProxy))
						{
							m_pairManager.AddBufferedPair(proxy, prevProxy);
						}
						
						//prevProxy.upperBounds[axis]++;
						as3arr = prevProxy.upperBounds;
						as3int = as3arr[axis];
						as3int++;
						as3arr[axis] = as3int;
						
						bound.stabbingCount++;
					}
					else
					{
						//prevProxy.lowerBounds[axis]++;
						as3arr = prevProxy.lowerBounds;
						as3int = as3arr[axis];
						as3int++;
						as3arr[axis] = as3int;
						
						bound.stabbingCount--;
					}
					
					//proxy.lowerBounds[axis]--;
					as3arr = proxy.lowerBounds;
					as3int = as3arr[axis];
					as3int--;
					as3arr[axis] = as3int;
					
					// swap
					//var temp:b2Bound = bound;
					//bound = prevEdge;
					//prevEdge = temp;
					bound.Swap(prevBound);
					//b2Math.Swap(bound, prevEdge);
					--index;
				}
			}
			
			// Should we move the upper bound up?
			if (deltaUpper > 0)
			{
				index = upperIndex;
				while (index < boundCount-1 && (bounds[int(index+1)] as b2Bound).value <= upperValue)
				{
					bound = bounds[ index ];
					nextBound = bounds[ int(index + 1) ];
					nextProxy = nextBound.proxy;
					
					nextBound.stabbingCount++;
					
					if (nextBound.IsLower() == true)
					{
						if (TestOverlapBound(newValues, nextProxy))
						{
							m_pairManager.AddBufferedPair(proxy, nextProxy);
						}
						
						//nextProxy.lowerBounds[axis]--;
						as3arr = nextProxy.lowerBounds;
						as3int = as3arr[axis];
						as3int--;
						as3arr[axis] = as3int;
						
						bound.stabbingCount++;
					}
					else
					{
						//nextProxy.upperBounds[axis]--;
						as3arr = nextProxy.upperBounds;
						as3int = as3arr[axis];
						as3int--;
						as3arr[axis] = as3int;
						
						bound.stabbingCount--;
					}
					
					//proxy.upperBounds[axis]++;
					as3arr = proxy.upperBounds;
					as3int = as3arr[axis];
					as3int++;
					as3arr[axis] = as3int;
					
					// swap
					//var temp:b2Bound = bound;
					//bound = nextEdge;
					//nextEdge = temp;
					bound.Swap(nextBound);
					//b2Math.Swap(bound, nextEdge);
					index++;
				}
			}
			
			//
			// Shrinking removes overlaps
			//
			
			// Should we move the lower bound up?
			if (deltaLower > 0)
			{
				index = lowerIndex;
				while (index < boundCount-1 && (bounds[int(index+1)] as b2Bound).value <= lowerValue)
				{
					bound = bounds[ index ];
					nextBound = bounds[ int(index + 1) ];
					
					nextProxy = nextBound.proxy;
					
					nextBound.stabbingCount--;
					
					if (nextBound.IsUpper())
					{
						if (TestOverlapBound(oldValues, nextProxy))
						{
							m_pairManager.RemoveBufferedPair(proxy, nextProxy);
						}
						
						//nextProxy.upperBounds[axis]--;
						as3arr = nextProxy.upperBounds;
						as3int = as3arr[axis];
						as3int--;
						as3arr[axis] = as3int;
						
						bound.stabbingCount--;
					}
					else
					{
						//nextProxy.lowerBounds[axis]--;
						as3arr = nextProxy.lowerBounds;
						as3int = as3arr[axis];
						as3int--;
						as3arr[axis] = as3int;
						
						bound.stabbingCount++;
					}
					
					//proxy.lowerBounds[axis]++;
					as3arr = proxy.lowerBounds;
					as3int = as3arr[axis];
					as3int++;
					as3arr[axis] = as3int;
					
					// swap
					//var temp:b2Bound = bound;
					//bound = nextEdge;
					//nextEdge = temp;
					bound.Swap(nextBound);
					//b2Math.Swap(bound, nextEdge);
					index++;
				}
			}
			
			// Should we move the upper bound down?
			if (deltaUpper < 0)
			{
				index = upperIndex;
				while (index > 0 && upperValue < (bounds[int(index-1)] as b2Bound).value)
				{
					bound = bounds[index];
					prevBound = bounds[int(index - 1)];
					
					prevProxy = prevBound.proxy;
					
					prevBound.stabbingCount--;
					
					if (prevBound.IsLower() == true)
					{
						if (TestOverlapBound(oldValues, prevProxy))
						{
							m_pairManager.RemoveBufferedPair(proxy, prevProxy);
						}
						
						//prevProxy.lowerBounds[axis]++;
						as3arr = prevProxy.lowerBounds;
						as3int = as3arr[axis];
						as3int++;
						as3arr[axis] = as3int;
						
						bound.stabbingCount--;
					}
					else
					{
						//prevProxy.upperBounds[axis]++;
						as3arr = prevProxy.upperBounds;
						as3int = as3arr[axis];
						as3int++;
						as3arr[axis] = as3int;
						
						bound.stabbingCount++;
					}
					
					//proxy.upperBounds[axis]--;
					as3arr = proxy.upperBounds;
					as3int = as3arr[axis];
					as3int--;
					as3arr[axis] = as3int;
					
					// swap
					//var temp:b2Bound = bound;
					//bound = prevEdge;
					//prevEdge = temp;
					bound.Swap(prevBound);
					//b2Math.Swap(bound, prevEdge);
					index--;
				}
			}
		}
	}
	
	public function UpdatePairs(callback:Function) : void{
		m_pairManager.Commit(callback);
	}

	public function TestOverlap(proxyA:*, proxyB:*):Boolean
	{
		var proxyA_:b2Proxy = proxyA as b2Proxy;
		var proxyB_:b2Proxy = proxyB as b2Proxy;
		if ( proxyA_.lowerBounds[0] > proxyB_.upperBounds[0]) return false;
		if ( proxyB_.lowerBounds[0] > proxyA_.upperBounds[0]) return false;
		if ( proxyA_.lowerBounds[1] > proxyB_.upperBounds[1]) return false;
		if ( proxyB_.lowerBounds[1] > proxyA_.upperBounds[1]) return false;
		return true;
	}
	
	/**
	 * Get user data from a proxy. Returns null if the proxy is invalid.
	 */
	public function GetUserData(proxy:*):*
	{
		return (proxy as b2Proxy).userData;
	}
	
	/**
	 * Get the AABB for a proxy.
	 */
	public function GetFatAABB(proxy_:*):b2AABB
	{
		var aabb:b2AABB = new b2AABB();
		var proxy:b2Proxy = proxy_ as b2Proxy;
		aabb.lowerBound.x = m_worldAABB.lowerBound.x +  m_bounds[0][proxy.lowerBounds[0]].value  / m_quantizationFactor.x;
		aabb.lowerBound.y = m_worldAABB.lowerBound.y +  m_bounds[1][proxy.lowerBounds[1]].value  / m_quantizationFactor.y;
		aabb.upperBound.x = m_worldAABB.lowerBound.x +  m_bounds[0][proxy.upperBounds[0]].value  / m_quantizationFactor.x;
		aabb.upperBound.y = m_worldAABB.lowerBound.y +  m_bounds[1][proxy.upperBounds[1]].value  / m_quantizationFactor.y;
		return aabb;
	}
	
	/**
	 * Get the number of proxies.
	 */
	public function GetProxyCount():int
	{
		return m_proxyCount;
	}
		
	
	/**
	 * Query an AABB for overlapping proxies. The callback class
	 * is called for each proxy that overlaps the supplied AABB.
	 */
	public function Query(callback:Function, aabb:b2AABB):void
	{
		var lowerValues:Vector.<Number> = new Vector.<Number>();
		var upperValues:Vector.<Number> = new Vector.<Number>();
		ComputeBounds(lowerValues, upperValues, aabb);
		
		var lowerIndex:uint;
		var upperIndex:uint;
		var lowerIndexOut:Vector.<uint> = new Vector.<uint>();
		lowerIndexOut.push(lowerIndex);
		var upperIndexOut:Vector.<uint> = new Vector.<uint>();
		upperIndexOut.push(upperIndex);
		QueryAxis(lowerIndexOut, upperIndexOut, lowerValues[0], upperValues[0], m_bounds[0], 2*m_proxyCount, 0);
		QueryAxis(lowerIndexOut, upperIndexOut, lowerValues[1], upperValues[1], m_bounds[1], 2*m_proxyCount, 1);
		
		//b2Settings.b2Assert(m_queryResultCount < b2Settings.b2_maxProxies);
		
		// TODO: Don't be lazy, transform QueryAxis to directly call callback
		for (var i:int = 0; i < m_queryResultCount; ++i)
		{
			var proxy:b2Proxy =  m_queryResults[i];
			//b2Settings.b2Assert(proxy.IsValid());
			if (!callback(proxy))
			{
				break;
			}
		}
		
		// Prepare for next query.
		m_queryResultCount = 0;
		IncrementTimeStamp();
	}

	public function Validate() : void{
		var pair:b2Pair;
		var proxy1:b2Proxy;
		var proxy2:b2Proxy;
		var overlap:Boolean;
		
		for (var axis:int = 0; axis < 2; ++axis)
		{
			var bounds:Vector.<b2Bound> = m_bounds[axis];
			
			var boundCount:uint = 2 * m_proxyCount;
			var stabbingCount:uint = 0;
			
			for (var i:uint = 0; i < boundCount; ++i)
			{
				var bound:b2Bound = bounds[i];
				//b2Settings.b2Assert(i == 0 || bounds[i-1].value <= bound->value);
				//b2Settings.b2Assert(bound->proxyId != b2_nullProxy);
				//b2Settings.b2Assert(m_proxyPool[bound->proxyId].IsValid());
				
				if (bound.IsLower() == true)
				{
					//b2Settings.b2Assert(m_proxyPool[bound.proxyId].lowerBounds[axis] == i);
					stabbingCount++;
				}
				else
				{
					//b2Settings.b2Assert(m_proxyPool[bound.proxyId].upperBounds[axis] == i);
					stabbingCount--;
				}
				
				//b2Settings.b2Assert(bound.stabbingCount == stabbingCount);
			}
		}
		
	}

	public function Rebalance(iterations:int):void
	{
		// Do nothing
	}

	
	/**
	 * @inheritDoc
	 */
	public function RayCast(callback:Function, input:b2RayCastInput):void
	{
		var subInput:b2RayCastInput = new  b2RayCastInput();
		subInput.p1.SetV(input.p1);
		subInput.p2.SetV(input.p2);
		subInput.maxFraction = input.maxFraction;
		
		
		var dx:Number = (input.p2.x-input.p1.x)*m_quantizationFactor.x;
		var dy:Number = (input.p2.y-input.p1.y)*m_quantizationFactor.y;
		
		var sx:int = dx<-Number.MIN_VALUE ? -1 : (dx>Number.MIN_VALUE ? 1 : 0);
		var sy:int = dy<-Number.MIN_VALUE ? -1 : (dy>Number.MIN_VALUE ? 1 : 0);
		
		//b2Settings.b2Assert(sx!=0||sy!=0);
		
		var p1x:Number = m_quantizationFactor.x * (input.p1.x - m_worldAABB.lowerBound.x);
		var p1y:Number = m_quantizationFactor.y * (input.p1.y - m_worldAABB.lowerBound.y);
		
		var startValues:Array = new Array();
		var startValues2:Array = new Array();
		startValues[0]=uint(p1x) & (b2Settings.USHRT_MAX - 1);
		startValues[1]=uint(p1y) & (b2Settings.USHRT_MAX - 1);
		startValues2[0]=startValues[0]+1;
		startValues2[1]=startValues[1]+1;
		
		var startIndices:Array = new Array();
		
		var xIndex:int;
		var yIndex:int;
		
		var proxy:b2Proxy;
		
		
		//First deal with all the proxies that contain segment.p1
		var lowerIndex:uint;
		var upperIndex:uint;
		var lowerIndexOut:Vector.<uint> = new Vector.<uint>(); 
		lowerIndexOut.push(lowerIndex);
		var upperIndexOut:Vector.<uint> = new Vector.<uint>();
		upperIndexOut.push(upperIndex);
		QueryAxis(lowerIndexOut, upperIndexOut, startValues[0], startValues2[0], m_bounds[0], 2*m_proxyCount, 0);
		if(sx>=0)	xIndex = upperIndexOut[0]-1;
		else		xIndex = lowerIndexOut[0];
		QueryAxis(lowerIndexOut, upperIndexOut, startValues[1], startValues2[1], m_bounds[1], 2*m_proxyCount, 1);
		if(sy>=0)	yIndex = upperIndexOut[0]-1;
		else		yIndex = lowerIndexOut[0];
			
		// Callback for starting proxies:
		for (var i:int = 0; i < m_queryResultCount; i++) {
			subInput.maxFraction = callback(m_queryResults[i], subInput);
		}
		
		//Now work through the rest of the segment
		for (;; )
		{
			var xProgress:Number = 0;
			var yProgress:Number = 0;
			//Move on to next bound
			xIndex += sx >= 0?1: -1;
			if(xIndex<0||xIndex>=m_proxyCount*2)
				break;
			if(sx!=0){
				xProgress = (m_bounds[0][xIndex].value - p1x) / dx;
			}
			//Move on to next bound
			yIndex += sy >= 0?1: -1;
			if(yIndex<0||yIndex>=m_proxyCount*2)
				break;
			if(sy!=0){
				yProgress = (m_bounds[1][yIndex].value - p1y) / dy;	
			}
			for (;; )
			{	
				if(sy==0||(sx!=0&&xProgress<yProgress)){
					if(xProgress>subInput.maxFraction)
						break;
					
					//Check that we are entering a proxy, not leaving
					if(sx>0?m_bounds[0][xIndex].IsLower():m_bounds[0][xIndex].IsUpper()){
						//Check the other axis of the proxy
						proxy = m_bounds[0][xIndex].proxy;
						if(sy>=0){
							if(proxy.lowerBounds[1]<=yIndex-1&&proxy.upperBounds[1]>=yIndex){
								//Add the proxy
								subInput.maxFraction = callback(proxy, subInput);
							}
						}else{
							if(proxy.lowerBounds[1]<=yIndex&&proxy.upperBounds[1]>=yIndex+1){
								//Add the proxy
								subInput.maxFraction = callback(proxy, subInput);
							}
						}
					}
					
					//Early out
					if(subInput.maxFraction==0)
						break;
					
					//Move on to the next bound
					if(sx>0){
						xIndex++;
						if(xIndex==m_proxyCount*2)
							break;
					}else{
						xIndex--;
						if(xIndex<0)
							break;
					}
					xProgress = (m_bounds[0][xIndex].value - p1x) / dx;
				}else{
					if(yProgress>subInput.maxFraction)
						break;
					
					//Check that we are entering a proxy, not leaving
					if(sy>0?m_bounds[1][yIndex].IsLower():m_bounds[1][yIndex].IsUpper()){
						//Check the other axis of the proxy
						proxy = m_bounds[1][yIndex].proxy;
						if(sx>=0){
							if(proxy.lowerBounds[0]<=xIndex-1&&proxy.upperBounds[0]>=xIndex){
								//Add the proxy
								subInput.maxFraction = callback(proxy, subInput);
							}
						}else{
							if(proxy.lowerBounds[0]<=xIndex&&proxy.upperBounds[0]>=xIndex+1){
								//Add the proxy
								subInput.maxFraction = callback(proxy, subInput);
							}
						}
					}
					
					//Early out
					if(subInput.maxFraction==0)
						break;
					
					//Move on to the next bound
					if(sy>0){
						yIndex++;
						if(yIndex==m_proxyCount*2)
							break;
					}else{
						yIndex--;
						if(yIndex<0)
							break;
					}
					yProgress = (m_bounds[1][yIndex].value - p1y) / dy;
				}
			}
			break;
		}
		
		// Prepare for next query.
		m_queryResultCount = 0;
		IncrementTimeStamp();
		
		return;
	}
	
//private:
	private function ComputeBounds(lowerValues:Vector.<Number>, upperValues:Vector.<Number>, aabb:b2AABB) : void
	{
		//b2Settings.b2Assert(aabb.upperBound.x >= aabb.lowerBound.x);
		//b2Settings.b2Assert(aabb.upperBound.y >= aabb.lowerBound.y);
		
		//var minVertex:b2Vec2 = b2Math.ClampV(aabb.minVertex, m_worldAABB.minVertex, m_worldAABB.maxVertex);
		var minVertexX:Number = aabb.lowerBound.x;
		var minVertexY:Number = aabb.lowerBound.y;
		minVertexX = b2Math.Min(minVertexX, m_worldAABB.upperBound.x);
		minVertexY = b2Math.Min(minVertexY, m_worldAABB.upperBound.y);
		minVertexX = b2Math.Max(minVertexX, m_worldAABB.lowerBound.x);
		minVertexY = b2Math.Max(minVertexY, m_worldAABB.lowerBound.y);
		
		//var maxVertex:b2Vec2 = b2Math.ClampV(aabb.maxVertex, m_worldAABB.minVertex, m_worldAABB.maxVertex);
		var maxVertexX:Number = aabb.upperBound.x;
		var maxVertexY:Number = aabb.upperBound.y;
		maxVertexX = b2Math.Min(maxVertexX, m_worldAABB.upperBound.x);
		maxVertexY = b2Math.Min(maxVertexY, m_worldAABB.upperBound.y);
		maxVertexX = b2Math.Max(maxVertexX, m_worldAABB.lowerBound.x);
		maxVertexY = b2Math.Max(maxVertexY, m_worldAABB.lowerBound.y);
		
		// Bump lower bounds downs and upper bounds up. This ensures correct sorting of
		// lower/upper bounds that would have equal values.
		// TODO_ERIN implement fast float to uint16 conversion.
		lowerValues[0] = uint(m_quantizationFactor.x * (minVertexX - m_worldAABB.lowerBound.x)) & (b2Settings.USHRT_MAX - 1);
		upperValues[0] = (uint(m_quantizationFactor.x * (maxVertexX - m_worldAABB.lowerBound.x))& 0x0000ffff) | 1;
		
		lowerValues[1] = uint(m_quantizationFactor.y * (minVertexY - m_worldAABB.lowerBound.y)) & (b2Settings.USHRT_MAX - 1);
		upperValues[1] = (uint(m_quantizationFactor.y * (maxVertexY - m_worldAABB.lowerBound.y))& 0x0000ffff) | 1;
	}

	// This one is only used for validation.
	private function TestOverlapValidate(p1:b2Proxy, p2:b2Proxy):Boolean{
		
		for (var axis:int = 0; axis < 2; ++axis)
		{
			var bounds:Vector.<b2Bound> = m_bounds[axis];
			
			//b2Settings.b2Assert(p1.lowerBounds[axis] < 2 * m_proxyCount);
			//b2Settings.b2Assert(p1.upperBounds[axis] < 2 * m_proxyCount);
			//b2Settings.b2Assert(p2.lowerBounds[axis] < 2 * m_proxyCount);
			//b2Settings.b2Assert(p2.upperBounds[axis] < 2 * m_proxyCount);
			
			var bound1:b2Bound = bounds[p1.lowerBounds[axis]];
			var bound2:b2Bound = bounds[p2.upperBounds[axis]];
			if (bound1.value > bound2.value)
				return false;
			
			bound1 = bounds[p1.upperBounds[axis]];
			bound2 = bounds[p2.lowerBounds[axis]];
			if (bound1.value < bound2.value)
				return false;
		}
		
		return true;
	}
	
	public function TestOverlapBound(b:b2BoundValues, p:b2Proxy):Boolean
	{
		for (var axis:int = 0; axis < 2; ++axis)
		{
			var bounds:Vector.<b2Bound> = m_bounds[axis];
			
			//b2Settings.b2Assert(p.lowerBounds[axis] < 2 * m_proxyCount);
			//b2Settings.b2Assert(p.upperBounds[axis] < 2 * m_proxyCount);
			
			var bound:b2Bound = bounds[p.upperBounds[axis]];
			if (b.lowerValues[axis] > bound.value)
				return false;
			
			bound = bounds[p.lowerBounds[axis]];
			if (b.upperValues[axis] < bound.value)
				return false;
		}
		
		return true;
	}

	private function QueryAxis(lowerQueryOut:Vector.<uint>, upperQueryOut:Vector.<uint>, lowerValue:uint, upperValue:uint, bounds:Vector.<b2Bound>, boundCount:uint, axis:int) : void{
		
		var lowerQuery:uint = BinarySearch(bounds, boundCount, lowerValue);
		var upperQuery:uint = BinarySearch(bounds, boundCount, upperValue);
		var bound: b2Bound;
		
		// Easy case: lowerQuery <= lowerIndex(i) < upperQuery
		// Solution: search query range for min bounds.
		for (var j:uint = lowerQuery; j < upperQuery; ++j)
		{
			bound = bounds[j];
			if (bound.IsLower())
			{
				IncrementOverlapCount(bound.proxy);
			}
		}
		
		// Hard case: lowerIndex(i) < lowerQuery < upperIndex(i)
		// Solution: use the stabbing count to search down the bound array.
		if (lowerQuery > 0)
		{
			var i:int = lowerQuery - 1;
			bound = bounds[i];
			var s:int = bound.stabbingCount;
			
			// Find the s overlaps.
			while (s)
			{
				//b2Settings.b2Assert(i >= 0);
				bound = bounds[i];
				if (bound.IsLower())
				{
					var proxy:b2Proxy = bound.proxy;
					if (lowerQuery <= proxy.upperBounds[axis])
					{
						IncrementOverlapCount(bound.proxy);
						--s;
					}
				}
				--i;
			}
		}
		
		lowerQueryOut[0] = lowerQuery;
		upperQueryOut[0] = upperQuery;
	}

	private function IncrementOverlapCount(proxy:b2Proxy) : void{
		if (proxy.timeStamp < m_timeStamp)
		{
			proxy.timeStamp = m_timeStamp;
			proxy.overlapCount = 1;
		}
		else
		{
			proxy.overlapCount = 2;
			//b2Settings.b2Assert(m_queryResultCount < b2Settings.b2_maxProxies);
			m_queryResults[m_queryResultCount] = proxy;
			++m_queryResultCount;
		}
	}
	private function IncrementTimeStamp() : void{
		if (m_timeStamp == b2Settings.USHRT_MAX)
		{
			for (var i:uint = 0; i < m_proxyPool.length; ++i)
			{
				(m_proxyPool[i] as b2Proxy).timeStamp = 0;
			}
			m_timeStamp = 1;
		}
		else
		{
			++m_timeStamp;
		}
	}
	
	b2internal var m_pairManager:b2PairManager = new b2PairManager();

	b2internal var m_proxyPool:Array = new Array();
	private var m_freeProxy:b2Proxy;

	b2internal var m_bounds:Vector.<Vector.<b2Bound> > ;

	private var m_querySortKeys:Array = new Array();
	private var m_queryResults:Array = new Array();
	private var m_queryResultCount:int;

	b2internal var m_worldAABB:b2AABB;
	b2internal var m_quantizationFactor:b2Vec2 = new b2Vec2();
	b2internal var m_proxyCount:int;
	private var m_timeStamp:uint;

	static public var s_validate:Boolean = false;
	
	static public const b2_invalid:uint = b2Settings.USHRT_MAX;
	static public const b2_nullEdge:uint = b2Settings.USHRT_MAX;


	static public function BinarySearch(bounds:Vector.<b2Bound>, count:int, value:uint):uint
	{
		var low:int = 0;
		var high:int = count - 1;
		while (low <= high)
		{
			var mid:int = ((low + high) / 2);
			var bound:b2Bound = bounds[mid];
			if (bound.value > value)
			{
				high = mid - 1;
			}
			else if (bound.value < value)
			{
				low = mid + 1;
			}
			else
			{
				return uint(mid);
			}
		}
		
		return uint(low);
	}
	
	
};
}
