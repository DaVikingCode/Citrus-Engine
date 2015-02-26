package citrus.core
{
	/**
	 * CitrusObject is simple. Too simple. Despite its simplicity, it is the foundational object that should
	 * be used for all game objects logic you create, such as spaceships, enemies, coins, bosses.
	 * CitrusObject is basically an abstract class that gets added to a State instance.
	 * The current State calls update on all CitrusObjects. Also, CitrusObjects are useful because they can be
	 * initialized with a params object, which can be created via an object parser/factory. 
	 */	
	public class CitrusObject
	{
		/**
		 * data used internally
		 */
		citrus_internal var data:Object = {ID:0};
		citrus_internal static var last_id:uint = 0;
		
		public static var hideParamWarnings:Boolean = false;
		
		/**
		 * A name to identify easily an objet. You may use duplicate name if you wish.
		 */
		public var name:String;
		
		/**
		 * Set it to true if you want to remove, clean and destroy the object. 
		 */
		public var kill:Boolean = false;
		
		/**
		 * This property prevent the <code>update</code> method to be called by the enter frame, it will save performances. 
		 * Set it to true if you want to execute code in the <code>update</code> method.
		 */
		public var updateCallEnabled:Boolean = false;
		
		/**
		 * Added to the CE's render list via the State and the add method.
		 */
		public var type:String = "classicObject";
		
		protected var _initialized:Boolean = false;
		protected var _ce:CitrusEngine;
		
		protected var _params:Object;
		
		/**
		 * The time elasped between two update call.
		 */
		protected var _timeDelta:Number;
		
		/**
		 * Every Citrus Object needs a name. It helps if it's unique, but it won't blow up if it's not.
		 * Also, you can pass parameters into the constructor as well. Hopefully you'll commonly be
		 * creating CitrusObjects via an editor, which will parse your shit and create the params object for you. 
		 * @param name Name your object.
		 * @param params Any public properties or setters can be assigned values via this object.
		 * 
		 */		
		public function CitrusObject(name:String, params:Object = null)
		{
			this.name = name;
			
			_ce = CitrusEngine.getInstance();
			
			_params = params;
			
			if (params) {
				if (type == "classicObject" && !params["type"])
					initialize();
			} else
				initialize();
				
			citrus_internal::data.ID = citrus_internal::last_id += 1;
		}
		
		/**
		 * Call in the constructor if the Object is added via the State and the add method.
		 * <p>If it's a pool object or an entity initialize it yourself.</p>
		 * <p>If it's a component, it should be call by the entity.</p>
		 */
		public function initialize(poolObjectParams:Object = null):void {
			
			if (poolObjectParams)
				_params = poolObjectParams;
			
			if (_params)
				setParams(this, _params);
			else
				_initialized = true;	
				
		}
		
		/**
		 * Seriously, dont' forget to release your listeners, signals, and physics objects here. Either that or don't ever destroy anything.
		 * Your choice.
		 */		
		public function destroy():void
		{
			citrus_internal::data = null;
			_initialized = false;	
			_params = null;
		}
		
		/**
		 * The current state calls update every tick. This is where all your per-frame logic should go. Set velocities, 
		 * determine animations, change properties, etc. 
		 * @param timeDelta This is a ratio explaining the amount of time that passed in relation to the amount of time that
		 * was supposed to pass. Multiply your stuff by this value to keep your speeds consistent no matter the frame rate. 
		 */		
		public function update(timeDelta:Number):void
		{
			_timeDelta = timeDelta;
		}
		
		/**
		 * The initialize method usually calls this.
		 */
		public function setParams(object:Object, params:Object):void
		{
			for (var param:String in params)
			{
				try
				{
					if (params[param] == "true")
						object[param] = true;
					else if (params[param] == "false")
						object[param] = false;
					else
						object[param] = params[param];
				}
				catch (e:Error)
				{
					if (!hideParamWarnings)
						trace("Warning: The property " + param + " does not exist on " + this);
				}
			}
			_initialized = true;
		}
		
		public function get ID():uint
		{
			return citrus_internal::data.ID;
		}
		
		public function toString():String
		{
			use namespace citrus_internal;
			return String(Object(this).constructor) + " ID:" + (data && data["ID"]  ? data.ID : "null") + " name:" + String(name) + " type:" + String(type);
		}
	}
}