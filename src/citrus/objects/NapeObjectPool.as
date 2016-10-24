package citrus.objects 
{
	import citrus.core.citrus_internal;
	import citrus.datastructures.DoublyLinkedListNode;
	import citrus.datastructures.PoolObject;
	import citrus.physics.nape.Nape;
	import citrus.view.ICitrusArt;

	import flash.utils.describeType;
	
	public class NapeObjectPool extends PoolObject
	{
		use namespace citrus_internal;
		public function NapeObjectPool(pooledType:Class,defaultParams:Object, poolGrowthRate:uint = 1) 
		{	
			super(pooledType, defaultParams, poolGrowthRate, true);
			
			if (!(describeType(pooledType).factory.extendsClass.(@type == "citrus.objects::NapePhysicsObject").length() > 0))
				throw new Error("NapePoolObject: " + String(pooledType) + " is not a NapePhysicsObject");

		}
		
		override protected function _create(node:DoublyLinkedListNode, params:Object = null):void
		{
			if (!params)
				params = { };
			params["type"] = "aPhysicsObject";
			params["name"] = "aPoolObject";
			node.data = new _poolType(params);
			var np:NapePhysicsObject = node.data as NapePhysicsObject;
			np.citrus_internal::parentScene = this.citrus_internal::scene;
			np.initialize(params);
			onCreate.dispatch((node.data as _poolType), params);
			np.addPhysics();
			np.body.space = null;
 			scene.view.addArt(np);
			np.citrus_internal::data["updateCall"] = np.updateCallEnabled;
			np.citrus_internal::data["updateArt"] = (scene.view.getArt(np) as ICitrusArt).updateArtEnabled;
		}
		
		override protected function _recycle(node:DoublyLinkedListNode, params:Object = null):void
		{
			var np:NapePhysicsObject = node.data as NapePhysicsObject;
			np.initialize(params);
			np.body.space = (scene.getFirstObjectByType(Nape) as Nape).space;
			if ("pauseAnimation" in np.view)
				np.view.pauseAnimation(true);
			np.visible = true;
			np.updateCallEnabled = np.citrus_internal::data["updateCall"] as Boolean;
			(scene.view.getArt(np) as ICitrusArt).updateArtEnabled = np.citrus_internal::data["updateArt"] as Boolean;
			super._recycle(node, params);
			np.handleAddedToScene();
		}
		
		override protected function _dispose(node:DoublyLinkedListNode):void
		{
			var np:NapePhysicsObject = node.data as NapePhysicsObject;
			np.body.space = null;
			if ("pauseAnimation" in np.view)
				np.view.pauseAnimation(false);
			np.visible = false;
			np.updateCallEnabled = false;
			(scene.view.getArt(np) as ICitrusArt).updateArtEnabled = false;
			super._dispose(node);
			(scene.view.getArt(np) as ICitrusArt).update(scene.view);
			np.handleRemovedFromScene();
		}
		
		override protected function _destroy(node:DoublyLinkedListNode):void
		{
			var np:NapePhysicsObject = node.data as NapePhysicsObject;
			scene.view.removeArt(np);
			np.destroy();
			super._destroy(node);
		}
		
	}

}