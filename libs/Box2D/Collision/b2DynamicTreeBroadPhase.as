package Box2D.Collision 
{

	import Box2D.Common.Math.*;
	
/**
 * The broad-phase is used for computing pairs and performing volume queries and ray casts.
 * This broad-phase does not persist pairs. Instead, this reports potentially new pairs.
 * It is up to the client to consume the new pairs and to track subsequent overlap.
 */
public class b2DynamicTreeBroadPhase implements IBroadPhase
{
	/**
	 * Create a proxy with an initial AABB. Pairs are not reported until
	 * UpdatePairs is called.
	 */
	public function CreateProxy(aabb:b2AABB, userData:*):*
	{
		var proxy:b2DynamicTreeNode = m_tree.CreateProxy(aabb, userData);
		++m_proxyCount;
		BufferMove(proxy);
		return proxy;
	}
	
	/**
	 * Destroy a proxy. It is up to the client to remove any pairs.
	 */
	public function DestroyProxy(proxy:*):void
	{
		UnBufferMove(proxy);
		--m_proxyCount;
		m_tree.DestroyProxy(proxy);
	}
	
	/**
	 * Call MoveProxy as many times as you like, then when you are done
	 * call UpdatePairs to finalized the proxy pairs (for your time step).
	 */
	public function MoveProxy(proxy:*, aabb:b2AABB, displacement:b2Vec2):void
	{
		var buffer:Boolean = m_tree.MoveProxy(proxy, aabb, displacement);
		if (buffer)
		{
			BufferMove(proxy);
		}
	}
	
	public function TestOverlap(proxyA:*, proxyB:*):Boolean
	{
		var aabbA:b2AABB = m_tree.GetFatAABB(proxyA);
		var aabbB:b2AABB = m_tree.GetFatAABB(proxyB);
		return aabbA.TestOverlap(aabbB);
	}
	
	/**
	 * Get user data from a proxy. Returns null if the proxy is invalid.
	 */
	public function GetUserData(proxy:*):*
	{
		return m_tree.GetUserData(proxy);
	}
	
	/**
	 * Get the AABB for a proxy.
	 */
	public function GetFatAABB(proxy:*):b2AABB
	{
		return m_tree.GetFatAABB(proxy);
	}
	
	/**
	 * Get the number of proxies.
	 */
	public function GetProxyCount():int
	{
		return m_proxyCount;
	}
	
	/**
	 * Update the pairs. This results in pair callbacks. This can only add pairs.
	 */
	public function UpdatePairs(callback:Function):void
	{
		m_pairCount = 0;
		// Perform tree queries for all moving queries
		for each(var queryProxy:b2DynamicTreeNode in m_moveBuffer)
		{
			function QueryCallback(proxy:b2DynamicTreeNode):Boolean
			{
				// A proxy cannot form a pair with itself.
				if (proxy == queryProxy)
					return true;
					
				// Grow the pair buffer as needed
				if (m_pairCount == m_pairBuffer.length)
				{
					m_pairBuffer[m_pairCount] = new b2DynamicTreePair();
				}
				
				var pair:b2DynamicTreePair = m_pairBuffer[m_pairCount];
				pair.proxyA = proxy < queryProxy?proxy:queryProxy;
				pair.proxyB = proxy >= queryProxy?proxy:queryProxy;
				++m_pairCount;
				
				return true;
			}
			// We have to query the tree with the fat AABB so that
			// we don't fail to create a pair that may touch later.
			var fatAABB:b2AABB = m_tree.GetFatAABB(queryProxy);
			m_tree.Query(QueryCallback, fatAABB);
		}
		
		// Reset move buffer
		m_moveBuffer.length = 0;
		
		// Sort the pair buffer to expose duplicates.
		// TODO: Something more sensible
		//m_pairBuffer.sort(ComparePairs);
		
		// Send the pair buffer
		for (var i:int = 0; i < m_pairCount; )
		{
			var primaryPair:b2DynamicTreePair = m_pairBuffer[i];
			var userDataA:* = m_tree.GetUserData(primaryPair.proxyA);
			var userDataB:* = m_tree.GetUserData(primaryPair.proxyB);
			callback(userDataA, userDataB);
			++i;
			
			// Skip any duplicate pairs
			while (i < m_pairCount)
			{
				var pair:b2DynamicTreePair = m_pairBuffer[i];
				if (pair.proxyA != primaryPair.proxyA || pair.proxyB != primaryPair.proxyB)
				{
					break;
				}
				++i;
			}
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function Query(callback:Function, aabb:b2AABB):void
	{
		m_tree.Query(callback, aabb);
	}
	
	/**
	 * @inheritDoc
	 */
	public function RayCast(callback:Function, input:b2RayCastInput):void
	{
		m_tree.RayCast(callback, input);
	}
	
	
	public function Validate():void
	{
		//TODO_BORIS
	}
	
	public function Rebalance(iterations:int):void
	{
		m_tree.Rebalance(iterations);
	}
	
	
	// Private ///////////////
	
	private function BufferMove(proxy:b2DynamicTreeNode):void
	{
		m_moveBuffer[m_moveBuffer.length] = proxy;
	}
	
	private function UnBufferMove(proxy:b2DynamicTreeNode):void
	{
		var i:int = m_moveBuffer.indexOf(proxy);
		m_moveBuffer.splice(i, 1);
	}
	
	private function ComparePairs(pair1:b2DynamicTreePair, pair2:b2DynamicTreePair):int
	{
		//TODO_BORIS:
		// We cannot consistently sort objects easily in AS3
		// The caller of this needs replacing with a different method.
		return 0;
	}
	private var m_tree:b2DynamicTree = new b2DynamicTree();
	private var m_proxyCount:int;
	private var m_moveBuffer:Vector.<b2DynamicTreeNode> = new Vector.<b2DynamicTreeNode>();
	
	private var m_pairBuffer:Vector.<b2DynamicTreePair> = new Vector.<b2DynamicTreePair>();
	private var m_pairCount:int = 0;
}
	
}