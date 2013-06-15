package citrus.objects 
{
	import citrus.core.CitrusEngine;
	import citrus.datastructures.DoublyLinkedListNode;
	import citrus.datastructures.PoolObject;
	import citrus.view.ACitrusView;
	/**
	 * ...
	 * @author gsynuh
	 */
	public class Box2DObjectPool extends PoolObject
	{
		
		private static var activationQueue:Vector.<Object>;
		
		private static var stateView:ACitrusView;
		
		public function Box2DObjectPool(pooledType:Class,defaultParams:Object, poolGrowthRate:uint = 1) 
		{
			super(pooledType, defaultParams, poolGrowthRate, true);
			
			//test if defined pooledType class inherits from Box2DPhysicsObject
			var test:Object;
			if ((test = new pooledType("test")) is Box2DPhysicsObject)
			{ test.kill = true; test = null; }
			else
				throw new Error("Box2DPoolObject: " + String(pooledType) + " is not a Box2DPhysicsObject");
			
			if(!activationQueue)
			activationQueue = new Vector.<Object>();
			
			stateView = CitrusEngine.getInstance().state.view;
		}
		
		override protected function _create(node:DoublyLinkedListNode, params:Object = null):void
		{
			if (!params)
				params = { };
			else if (_defaultParams)
			{
				if (params["width"] != _defaultParams["width"])
				{
					trace(this, "you cannot change the default width of your object.");
					params["width"] = _defaultParams["width"];
				}
				if (params["height"] != _defaultParams["height"])
				{
					trace(this, "you cannot change the default height of your object.");
					params["height"] = _defaultParams["height"];
				}
			}
			params["type"] = "aPhysicsObject";
			node.data = new _poolType("aPoolObject", params);
			var bp:Box2DPhysicsObject = node.data as Box2DPhysicsObject;
			bp.initialize(params);
			onCreate.dispatch(bp, params);
			bp.addPhysics();
			stateView.addArt(bp);
		}
		
		override protected function _recycle(node:DoublyLinkedListNode, params:Object = null):void
		{
			var bp:Box2DPhysicsObject = node.data as Box2DPhysicsObject;
			bp.updateCallEnabled = true;
			bp.initialize(params);
			activationQueue.unshift( { object:bp, activate:true } );
			if ("pauseAnimation" in bp.view)
				bp.view.pauseAnimation(true);
			super._recycle(node, params);
			bp.visible = true;
		}
		
		override protected function _dispose(node:DoublyLinkedListNode):void
		{
			var bp:Box2DPhysicsObject = node.data as Box2DPhysicsObject;
			bp.updateCallEnabled = false;
			activationQueue.unshift( { object:bp, activate:false } );
			if ("pauseAnimation" in bp.view)
				bp.view.pauseAnimation(false);
			bp.visible = false;
			super._dispose(node);
		}
		
		override public function updatePhysics(timeDelta:Number):void
		{
			super.updatePhysics(timeDelta);
			updateBodies();
		}
		
		private static function updateBodies():void
		{
			var entry:Object;
			
			while(entry = activationQueue.pop())
			{
				entry.object.body.SetActive(entry.activate);
				entry.object.body.SetAwake(entry.activate);
			}
			
		}
		
		override protected function _destroy(node:DoublyLinkedListNode):void
		{
			updateBodies();
			activationQueue.length = 0;
			var bp:Box2DPhysicsObject = node.data as Box2DPhysicsObject;
			stateView.removeArt(bp);
			bp.destroy();
			super._destroy(node);
		}
		
	}

}