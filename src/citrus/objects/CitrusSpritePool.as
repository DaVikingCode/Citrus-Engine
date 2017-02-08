package citrus.objects 
{
	import citrus.core.citrus_internal;
	import citrus.datastructures.DoublyLinkedListNode;
	import citrus.datastructures.PoolObject;
	import citrus.view.ICitrusArt;
	
	public class CitrusSpritePool extends PoolObject
	{
		use namespace citrus_internal;
		public function CitrusSpritePool(pooledType:Class,defaultParams:Object, poolGrowthRate:uint = 1) 
		{
			super(pooledType, defaultParams, poolGrowthRate, true);
			
			//test if defined pooledType class inherits from CitrusSprite
			var test:Object;
			if ((test = new pooledType("test")) is CitrusSprite)
			{ test.kill = true; test = null; }
			else
				throw new Error("CitrusSpritePool: " + String(pooledType) + " is not a CitrusSprite");
		}
		
		override protected function _create(node:DoublyLinkedListNode, params:Object = null):void
		{
			if (!params)
				params = { };
			params["type"] = "aPoolObject";
			var cs : CitrusSprite = node.data = new _poolType(params) as CitrusSprite;
			cs.citrus_internal::parentScene = this.citrus_internal::scene;
			cs.initialize(params);
			onCreate.dispatch((node.data as _poolType), params);
 			scene.view.addArt(cs);
			
			cs.citrus_internal::data["updateCall"] = cs.updateCallEnabled;
			cs.citrus_internal::data["updateArt"] = (scene.view.getArt(cs) as ICitrusArt).updateArtEnabled;
		}
		
		override protected function _recycle(node:DoublyLinkedListNode, params:Object = null):void
		{
			var cs:CitrusSprite = node.data as CitrusSprite;
			cs.initialize(params);
			if ("pauseAnimation" in cs.view)
				cs.view.pauseAnimation(true);
			cs.visible = true;
			cs.updateCallEnabled = cs.citrus_internal::data["updateCall"] as Boolean;
			(scene.view.getArt(cs) as ICitrusArt).updateArtEnabled = cs.citrus_internal::data["updateArt"] as Boolean;
			super._recycle(node, params);
			cs.handleAddedToScene();
		}
		
		override protected function _dispose(node:DoublyLinkedListNode,dispatch:Boolean = true):void
		{
			var cs:CitrusSprite = node.data as CitrusSprite;
			if ("pauseAnimation" in cs.view)
				cs.view.pauseAnimation(false);
			cs.visible = false;
			cs.updateCallEnabled = false;
			(scene.view.getArt(cs) as ICitrusArt).updateArtEnabled = false;
			super._dispose(node,dispatch);
			(scene.view.getArt(cs) as ICitrusArt).update(scene.view);
			cs.handleRemovedFromScene();
		}
		
		override protected function _destroy(node:DoublyLinkedListNode):void
		{
			var cs:CitrusSprite = node.data as CitrusSprite;
			scene.view.removeArt(cs);
			cs.destroy();
			super._destroy(node);
		}
		
	}

}
