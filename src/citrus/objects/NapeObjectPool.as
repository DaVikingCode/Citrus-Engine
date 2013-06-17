package citrus.objects 
{

	import citrus.core.CitrusEngine;
	import citrus.datastructures.DoublyLinkedListNode;
	import citrus.datastructures.PoolObject;
	import citrus.physics.nape.Nape;
	import citrus.view.ACitrusView;
	
	public class NapeObjectPool extends PoolObject
	{
		private static var stateView:ACitrusView;
		
		public function NapeObjectPool(pooledType:Class,defaultParams:Object, poolGrowthRate:uint = 1) 
		{
			super(pooledType, defaultParams, poolGrowthRate, true);
			
			//test if defined pooledType class inherits from NapePhysicsObject
			var test:Object;
			if ((test = new pooledType("test")) is NapePhysicsObject)
			{ test.kill = true; test = null; }
			else
				throw new Error("NapePoolObject: " + String(pooledType) + " is not a NapePhysicsObject");
				
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
			var np:NapePhysicsObject = node.data as NapePhysicsObject;
			np.initialize(params);
			onCreate.dispatch((node.data as _poolType), params);
			np.addPhysics();
 			stateView.addArt(np);
		}
		
		override protected function _recycle(node:DoublyLinkedListNode, params:Object = null):void
		{
			var np:NapePhysicsObject = node.data as NapePhysicsObject;
			np.updateCallEnabled = true;
			np.initialize(params);
			np.body.space = (CitrusEngine.getInstance().state.getFirstObjectByType(Nape) as Nape).space;
			if ("pauseAnimation" in np.view)
				np.view.pauseAnimation(true);
			super._recycle(node, params);
			np.visible = true;
		}
		
		override protected function _dispose(node:DoublyLinkedListNode):void
		{
			var np:NapePhysicsObject = node.data as NapePhysicsObject;
			np.updateCallEnabled = false;
			np.body.space = null;
			if ("pauseAnimation" in np.view)
				np.view.pauseAnimation(false);
			np.visible = false;
			super._dispose(node);
		}
		
		override protected function _destroy(node:DoublyLinkedListNode):void
		{
			var np:NapePhysicsObject = node.data as NapePhysicsObject;
			stateView.removeArt(np);
			np.destroy();
			super._destroy(node);
		}
		
	}

}