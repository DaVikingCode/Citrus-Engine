package citrus.objects 
{

	import citrus.core.CitrusEngine;
	import citrus.datastructures.DoublyLinkedListNode;
	import citrus.datastructures.PoolObject;
	import citrus.physics.nape.Nape;
	import citrus.view.ACitrusView;
	import citrus.view.ICitrusArt;
	import citrus.core.citrus_internal;
	
	public class CitrusSpritePool extends PoolObject
	{
		private static var stateView:ACitrusView;
		
		public function CitrusSpritePool(pooledType:Class,defaultParams:Object, poolGrowthRate:uint = 1) 
		{
			super(pooledType, defaultParams, poolGrowthRate, true);
			
			//test if defined pooledType class inherits from CitrusSprite
			var test:Object;
			if ((test = new pooledType("test")) is CitrusSprite)
			{ test.kill = true; test = null; }
			else
				throw new Error("CitrusSpritePool: " + String(pooledType) + " is not a CitrusSprite");
				
			stateView = CitrusEngine.getInstance().state.view;
		}
		
		override protected function _create(node:DoublyLinkedListNode, params:Object = null):void
		{
			if (!params)
				params = { };
				
			var cs:CitrusSprite = node.data = new _poolType("aPoolObject", params) as CitrusSprite;
			cs.initialize(params);
			onCreate.dispatch((node.data as _poolType), params);
 			stateView.addArt(cs);
			
			cs.citrus_internal::data["updateCall"] = cs.updateCallEnabled;
			cs.citrus_internal::data["updateArt"] = (stateView.getArt(cs) as ICitrusArt).updateArtEnabled;
		}
		
		override protected function _recycle(node:DoublyLinkedListNode, params:Object = null):void
		{
			var cs:CitrusSprite = node.data as CitrusSprite;
			cs.initialize(params);
			if ("pauseAnimation" in cs.view)
				cs.view.pauseAnimation(true);
			cs.visible = true;
			cs.updateCallEnabled = cs.citrus_internal::data["updateCall"] as Boolean;
			(stateView.getArt(cs) as ICitrusArt).updateArtEnabled = cs.citrus_internal::data["updateArt"] as Boolean;
			super._recycle(node, params);
		}
		
		override protected function _dispose(node:DoublyLinkedListNode):void
		{
			var cs:CitrusSprite = node.data as CitrusSprite;
			if ("pauseAnimation" in cs.view)
				cs.view.pauseAnimation(false);
			cs.visible = false;
			cs.updateCallEnabled = false;
			(stateView.getArt(cs) as ICitrusArt).updateArtEnabled = false;
			super._dispose(node);
			(stateView.getArt(cs) as ICitrusArt).update(stateView);
		}
		
		override protected function _destroy(node:DoublyLinkedListNode):void
		{
			var cs:CitrusSprite = node.data as CitrusSprite;
			stateView.removeArt(cs);
			cs.destroy();
			super._destroy(node);
		}
		
	}

}