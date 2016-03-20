package citrus.utils
{
	
	import flash.utils.Dictionary;
	import flash.utils.flash_proxy;
	import flash.utils.Proxy;
	import org.osflash.signals.Signal;
	
	/**
	 * This is an (optional) abstract class to store your game's data such as lives, score, levels or even complex objects...
	 * identified by strings.
	 *
	 * the dataChanged signal is dispatched when any property changes with its name and value as arguments.
	 *
	 * if typeVerification is set to true, you will get an error thrown when you try to change a property with a value of different type.
	 *
	 * you can extend AGameData to synchronize your data with a shared object or a server for example
	 * (keep operations on shared objects/server to a strict minimum by "flushing" and "reading" values from them only
	 * when necessary...)
	 * or simply extend it to setup initial values in your custom AGameData constructor.
	 */
	dynamic public class AGameData extends Proxy
	{
		
		/**
		 * dispatched when a property is defined or changed.
		 */
		public var dataChanged:Signal;
		
		/**
		 * throw an argument error when trying to change a property with a value of a different type.
		 */
		public var typeVerification:Boolean = true;
		
		private var __dict:Dictionary;
		private var __propNames:Vector.<String>;
		private var __numProps:int;
		
		public function AGameData()
		{
			__dict = new Dictionary();
			__propNames = new Vector.<String>();
			
			dataChanged = new Signal(String, Object);
		}
		
		override flash_proxy function callProperty(methodName:*, ... args):*
		{
			if (__dict[methodName] is Function)
				return __dict[methodName].apply(this, args);
			return undefined;
		}
		
		override flash_proxy function getDescendants(name:*):*
		{
			return __dict[name];
		}
		
		override flash_proxy function isAttribute(name:*):Boolean
		{
			return name in __dict;
		}
		
		override flash_proxy function nextName(index:int):String
		{
			return __propNames[index - 1];
		}
		
		override flash_proxy function nextNameIndex(index:int):int
		{
			if (index == 0)
			{
				var propNames:Vector.<String> = __propNames;
				propNames.length = 0;
				var size:int;
				for (var k:*in __dict)
				{
					propNames[size++] = k;
				}
				__numProps = size;
			}
			
			return (index < __numProps) ? (index + 1) : 0;
		}
		
		override flash_proxy function nextValue(index:int):*
		{
			return __dict[__propNames[index - 1]];
		}
		
		override flash_proxy function deleteProperty(name:*): Boolean
		{
			var ret:Boolean = (name in __dict);
			delete __dict[name];
			return ret;
		}
		
		override flash_proxy function getProperty(name:*):*
		{
			if (__dict[name] != undefined)
				return __dict[name];
			
			throw new ArgumentError("[AGameData] property " + name + " doesn't exist.");
		}
		
		override flash_proxy function hasProperty(name:*):Boolean
		{
			return __dict[name] != undefined;
		}
		
		override flash_proxy function setProperty(name:*, value:*):void
		{
			if (__dict[name] != undefined)
			{
				if (typeVerification)
				{
					var type1:Class = value.constructor;
					var type2:Class = __dict[name].constructor;
					if (!(type1 === type2))
						throw new ArgumentError("[AGameData] you're trying to set '" + name + "'s value of type " + type2 + " to a new value of type " + type1);
				}
				
				if (value === __dict[name])
					return;
				
				__dict[name] = value;
			}
			else
				__dict[name] = value;
			
			dataChanged.dispatch(String(name), value);
		}
		
		public function destroy():void
		{
			__dict = null;
			__propNames.length = 0;
			dataChanged.removeAll();
		}
	}
}
