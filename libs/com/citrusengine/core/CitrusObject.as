package com.citrusengine.core
{
	/**
	 * CitrusObject is simple. Too simple. Despite its simplicity, it is the foundational object that should
	 * be used for all game objects you create, such as spaceships, enemies, coins, bosses, and HUD elements.
	 * CitrusObject is basically an abstract class that gets added to a State instance.
	 * The current State calls update on all CitrusObjects. Also, CitrusObjects are useful because they can be
	 * initialized with a params object, which can be created via an object parser/factory. 
	 */	
	public class CitrusObject
	{
		public static var hideParamWarnings:Boolean = false;
		
		public var name:String;
		public var kill:Boolean = false;
		
		protected var _initialized:Boolean = false;
		
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
			if (params)
				setParams(params);
			else
				_initialized = true;
		}
		
		/**
		 * Seriously, dont' forget to release your listeners, signals, and Box2D objects here. Either that or don't ever destroy anything.
		 * Your choice.
		 */		
		public function destroy():void
		{
			
		}
		
		/**
		 * The current state calls update every tick. This is where all your per-frame logic should go. Set velocities, 
		 * determine animations, change properties, etc. 
		 * @param timeDelta This is a ratio explaining the amount of time that passed in relation to the amount of time that
		 * was supposed to pass. Multiply your stuff by this value to keep your speeds consistent no matter the frame rate. 
		 */		
		public function update(timeDelta:Number):void
		{
			
		}
		
		/**
		 * The constructor usually calls this.
		 */		
		protected function setParams(object:Object):void
		{
			for (var param:String in object)
			{
				try
				{
					if (object[param] == "true")
						this[param] = true;
					else if (object[param] == "false")
						this[param] = false;
					else
						this[param] = object[param];
				}
				catch (e:Error)
				{
					if (!hideParamWarnings)
						trace("Warning: The parameter " + param + " does not exist on " + this);
				}
			}
			_initialized = true;
		}
	}
}