package citrus.utils {

	import flash.utils.Dictionary;
	import org.osflash.signals.Signal;
	
	/**
	 * This is an (optional) abstract class to store your game's data such as lives, score, levels or even complex objects...
	 * identified by strings.
	 * 
	 * define properties with setProperty("name",value) and get them with getProperty("name")
	 * the dataChanged signal is dispatched when any property changes with its name and value as arguments.
	 * 
	 * if typeVerification is set to true, you will get an error thrown when you try to change a property with a value of different type.
	 * 
	 * you can extend AGameData to synchronize your data with a shared object or a server for example
	 * (keep operations on shared objects/server to a strict minimum by "flushing" and "reading" values from them only
	 * when necessary...) 
	 * or simply extend it to setup initial values with setProperty in your custom AGameData constructor.
	 */
	dynamic public class AGameData {
		
		/**
		 * dispatched when a property is defined or changed.
		 */
		public var onDataChanged:Signal;
		
		/**
		 * throw an argument error when trying to change a property with a value of a different type.
		 */
		public var typeVerification:Boolean = true;
		
		/**
		 * dictionnary holding the properties indexed by property name
		 */
		protected var data:Dictionary;
		
		public function AGameData() {
			data = new Dictionary();
			onDataChanged = new Signal(String, Object);
		}
		
		/**
		 * returns the value of a property or throws an error if it is not registered in this gameData instance.
		 * @param	name property name
		 * @return value object
		 */
		public function getProperty(name:String):Object
		{
			if (name in data)
				return data[name];
			else
				throw new ArgumentError("[AGameData] property "+ name+ " doesn't exist... initialize it with a value with setData(\"" + name + "\",defaultValue)");
			return null;
		}
		
		/**
		 * tells if a property is defined.
		 * @param	name property name
		 */
		public function hasProperty(name:String):Boolean
		{
			return (name in data);
		}
		
		/**
		 * set a property with a value. (it registers a new property/value pair if it doesn't exist, on changes an existing one if it does.
		 * @param	name property name
		 * @param	value object
		 */
		public function setProperty(name:String, value:Object):void
		{
			if (name in data)
			{
				if (typeVerification)
				{
					var type1:Class = Object(value).constructor;
					var type2:Class = Object(data[name]).constructor;
					if (!( type1 === type2 ) )
						throw new ArgumentError("[AGameData] you're trying to set '" + name + "'s value of type "+ type2 + " to a new value of type " + type1);
				}
				
				if (value === data[name])
					return;
					
				data[name] = value;
			}
			else
			{
				data[name] = value;
				return;
			}
			
			onDataChanged.dispatch(name, value);
		}
		
		public function destroy():void {
			data = null;
			onDataChanged.removeAll();
		}
	}
}
