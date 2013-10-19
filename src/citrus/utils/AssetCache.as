package citrus.utils
{
	import flash.utils.Dictionary;
	/**
	 * @author Michelangelo Capraro (m&#64;mcapraro.com)
	 */
	public class AssetCache
	{		
		private var cacheDictionary:Dictionary;
		
		public function AssetCache()
		{			
			cacheDictionary = new Dictionary();
		}
		
		public function add(resourceKey:*, resource:*):void
		{
			//trace("AssetCache: add: resourceKey [" + resourceKey + "] resource [" + resource + "]");
			cacheDictionary[resourceKey] = resource;
		}
		
		public function getItem(resourceKey:*):*
		{
			//trace("AssetCache: getItem [" + resourceKey + "] [" + cacheDictionary[resourceKey] + "]");
			return cacheDictionary[resourceKey];
		}

		public function itemExists(resourceKey:*):Boolean
		{
			//trace("AssetCache: itemExists [" + resourceKey + "] [" + (cacheDictionary[resourceKey] != null) + "]");
			return cacheDictionary[resourceKey] != null;
		}
		
		public function reset():void
		{
			//trace("AssetCache: reset");
			cacheDictionary = new Dictionary();
		}

		public function remove(resourceKey:*):void
		{
			//trace("AssetCache: remove [" + resourceKey + "]");
			delete cacheDictionary[resourceKey];
			//TODO: this should accept a single object and also an array and it will do an eficient loop through the dictionary and remove just the relevenat objects
			// also, this should try and do some efficient refcounting so we can be sure assets are cahced spartly and not duplicated, but available when needed
		}
		

	}
}
