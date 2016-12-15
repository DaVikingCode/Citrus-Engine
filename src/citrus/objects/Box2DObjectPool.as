package citrus.objects 
{
	import citrus.core.citrus_internal;
	import citrus.datastructures.DoublyLinkedListNode;
	import citrus.datastructures.PoolObject;
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
			params["type"] = "aPoolObject";
			node.data = new _poolType(params);
			var bp:Box2DPhysicsObject = node.data as Box2DPhysicsObject;
			bp.citrus_internal::parentScene = this.citrus_internal::scene;
			bp.initialize(params);
			onCreate.dispatch(bp, params);
			bp.addPhysics();
			bp.body.SetActive(false);
			scene.view.addArt(bp);
			bp.citrus_internal::data["updateCall"] = bp.updateCallEnabled;
			bp.citrus_internal::data["updateArt"] = (scene.view.getArt(bp) as ICitrusArt).updateArtEnabled;
		}
		
		override protected function _recycle(node:DoublyLinkedListNode, params:Object = null):void
		{
			var bp:Box2DPhysicsObject = node.data as Box2DPhysicsObject;
			activationQueue.unshift( { object:bp, activate:true , func:function():void {
				bp.initialize(params);
				if ("pauseAnimation" in bp.view)
					bp.view.pauseAnimation(true);
				bp.visible = true;
				bp.updateCallEnabled = bp.citrus_internal::data["updateCall"] as Boolean;
				(scene.view.getArt(bp) as ICitrusArt).updateArtEnabled = bp.citrus_internal::data["updateArt"] as Boolean;
				superRecycle(node,params);
				bp.handleAddedToScene();
			}});
		}
		
		protected function superRecycle(node:DoublyLinkedListNode,params:Object):void { super._recycle(node,params);}
		
		override protected function _dispose(node:DoublyLinkedListNode,dispatch:Boolean = true):void
		{
			var bp:Box2DPhysicsObject = node.data as Box2DPhysicsObject;
			activationQueue.unshift( { object:bp, activate:false} );
			if ("pauseAnimation" in bp.view)
				bp.view.pauseAnimation(false);
			bp.visible = false;
			bp.updateCallEnabled = false;
			(scene.view.getArt(bp) as ICitrusArt).updateArtEnabled = false;
			super._dispose(node,dispatch);
			(scene.view.getArt(bp) as ICitrusArt).update(scene.view);
			bp.handleAddedToScene();
		}
		
		override public function updatePhysics(timeDelta:Number):void
		{
			super.updatePhysics(timeDelta);
			updateBodies();
		}
		
		private static function updateBodies():void
		{
			var entry:Object;
			
			while((entry = activationQueue.pop()) != null) {
				entry.object.body.SetActive(entry.activate);
				if(entry.activate) entry.func();
			}
			
		}
		
		override protected function _destroy(node:DoublyLinkedListNode):void
		{
			updateBodies();
			activationQueue.length = 0;
			var bp:Box2DPhysicsObject = node.data as Box2DPhysicsObject;
			scene.view.removeArt(bp);
			bp.destroy();
			super._destroy(node);
		}
		
	}

}