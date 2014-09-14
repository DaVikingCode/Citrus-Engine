package citrus.objects 
{

	import citrus.core.CitrusEngine;
	import citrus.core.citrus_internal;
	import citrus.datastructures.DoublyLinkedListNode;
	import citrus.datastructures.PoolObject;
	import citrus.view.ACitrusView;
	import citrus.view.ICitrusArt;
	import flash.utils.describeType;
	
	public class Box2DObjectPool extends PoolObject
	{		
		use namespace citrus_internal;
		private static var activationQueue:Vector.<Object>;

		public function Box2DObjectPool(pooledType:Class,defaultParams:Object, poolGrowthRate:uint = 1) 
		{
			super(pooledType, defaultParams, poolGrowthRate, true);
			
			if (!(describeType(pooledType).factory.extendsClass.(@type == "citrus.objects::Box2DPhysicsObject").length() > 0))
				throw new Error("Box2DPoolObject: " + String(pooledType) + " is not a Box2DPhysicsObject");
			
			if(!activationQueue)
			activationQueue = new Vector.<Object>();

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
			bp.body.SetActive(false);
			state.view.addArt(bp);
			bp.citrus_internal::data["updateCall"] = bp.updateCallEnabled;
			bp.citrus_internal::data["updateArt"] = (state.view.getArt(bp) as ICitrusArt).updateArtEnabled;
		}
		
		override protected function _recycle(node:DoublyLinkedListNode, params:Object = null):void
		{
			var bp:Box2DPhysicsObject = node.data as Box2DPhysicsObject;
			bp.initialize(params);
			activationQueue.unshift( { object:bp, activate:true } );
			if ("pauseAnimation" in bp.view)
				bp.view.pauseAnimation(true);
			bp.visible = true;
			bp.updateCallEnabled = bp.citrus_internal::data["updateCall"] as Boolean;
			(state.view.getArt(bp) as ICitrusArt).updateArtEnabled = bp.citrus_internal::data["updateArt"] as Boolean;
			super._recycle(node, params);
		}
		
		override protected function _dispose(node:DoublyLinkedListNode):void
		{
			trace("DISPOSED");
			var bp:Box2DPhysicsObject = node.data as Box2DPhysicsObject;
			activationQueue.unshift( { object:bp, activate:false } );
			if ("pauseAnimation" in bp.view)
				bp.view.pauseAnimation(false);
			bp.visible = false;
			bp.updateCallEnabled = false;
			(state.view.getArt(bp) as ICitrusArt).updateArtEnabled = false;
			super._dispose(node);
			(state.view.getArt(bp) as ICitrusArt).update(state.view);
		}
		
		override public function updatePhysics(timeDelta:Number):void
		{
			super.updatePhysics(timeDelta);
			updateBodies();
		}
		
		private static function updateBodies():void
		{
			var entry:Object;
			
			while((entry = activationQueue.pop()) != null)
				entry.object.body.SetActive(entry.activate);
			
		}
		
		override protected function _destroy(node:DoublyLinkedListNode):void
		{
			updateBodies();
			activationQueue.length = 0;
			var bp:Box2DPhysicsObject = node.data as Box2DPhysicsObject;
			state.view.removeArt(bp);
			bp.destroy();
			super._destroy(node);
		}
		
	}

}