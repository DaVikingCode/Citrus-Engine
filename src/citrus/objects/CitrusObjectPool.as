package citrus.objects 
{

	import citrus.core.CitrusObject;
	import citrus.datastructures.DoublyLinkedListNode;
	import citrus.datastructures.PoolObject;
	import flash.utils.describeType;

	/**
	 * Base CitrusObject PoolObject (ex: CitrusSprites)
	 */
	public class CitrusObjectPool extends PoolObject
	{
		
		public function CitrusObjectPool(pooledType:Class,defaultParams:Object, poolGrowthRate:uint = 1)
		{
			super(pooledType, defaultParams, poolGrowthRate, true);
			
			if (!(describeType(pooledType).factory.extendsClass.(@type == "citrus.core::CitrusObject").length() > 0))
				throw new Error("CitrusObjectPool: " + String(pooledType) + " is not a CitrusObject");
		}
		
		override protected function _create(node:DoublyLinkedListNode, params:Object = null):void
		{
			var co:CitrusObject = node.data = new _poolType("aPoolObject", params);
			co.initialize(params);
			onCreate.dispatch(co, params);
		}
		
		override protected function _recycle(node:DoublyLinkedListNode, params:Object = null):void
		{
			var co:CitrusObject = node.data as CitrusObject;
			co.initialize(params);
			super._recycle(node, params);
		}
		
		override protected function _destroy(node:DoublyLinkedListNode):void
		{
			var co:CitrusObject = node.data as CitrusObject;
			co.destroy();
			super._destroy(node);
		}
	}

}