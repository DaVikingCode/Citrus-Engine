package dragonBones.animation
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/
	import dragonBones.Armature;
	
	import flash.utils.getTimer;
	/**
	 * A WorldClock instance lets you conveniently update many number of Armature instances at once. You can add/remove Armature instance and set a global timescale that will apply to all registered Armature instance animations.
	 * @example
	 * <p>Download the example files <a href='http://dragonbones.github.com/downloads/DragonBones_Tutorial_Assets.zip'>here</a>: </p>
	 * <listing>	
	 *	package  
	 *	{
	 *		import dragonBones.Armature;
	 *		import dragonBones.factorys.BaseFactory;
	 *  	import flash.display.Sprite;
	 *		import flash.events.Event;	
	 * 	import dragonBones.animation.WorldClock;
	 * 
     *
	 * public class DragonAnimation extends Sprite 
	 *		{		
	 *			[Embed(source = "Dragon1.swf", mimeType = "application/octet-stream")]  
	 *			private static const ResourcesData:Class;
	 *			
	 *			private var factory:BaseFactory;
	 *			private var armature:Armature; 			
	 *			
	 *			public function DragonAnimation() 
	 *			{				
	 *				factory = new BaseFactory();
	 *				factory.addEventListener(Event.COMPLETE, handleParseData);
	 *				factory.parseData(new ResourcesData(), 'Dragon');
	 *			}
	 *			
	 *			private function handleParseData(e:Event):void 
	 *			{			
	 *				armature = factory.buildArmature('Dragon');
	 *				addChild(armature.display as Sprite); 			
	 *				armature.animation.play(); 				
	 * 				WorldClock.clock.add(armature);
	 *				addEventListener(Event.ENTER_FRAME, updateAnimation);			
	 *			}
	 *			
	 *			private function updateAnimation(e:Event):void 
	 *			{
	 *				WorldClock.clock.advanceTime(stage.frameRate / 1000);
	 *			}		
	 *		}
	 *	}
	 * </listing>
	 * @see dragonBones.Armature
	 * @see dragonBones.Bone
	 * @see dragonBones.animation.Animation
	 */
	public final class WorldClock implements IAnimatable
	{
		/**
		 * A global static WorldClock instance ready to use.
		 */
		public static var clock:WorldClock = new WorldClock();
		
		private var _animatableList:Vector.<IAnimatable>;		
		private var _time:Number;
		
		/**
		 * @private
		 */
		public function get time():Number
		{
			return _time;
		}
		
		private var _timeScale:Number = 1;
		/**
		 * The time scale to apply to the number of second passed to the advanceTime() method.
		 * @param A Number to use as a time scale (NaN or < 0 to disable).
		 */
		public function get timeScale():Number
		{
			return _timeScale;
		}
		/**
		 * @private
		 */
		public function set timeScale(value:Number):void
		{
			if (value < 0 || isNaN(value))
			{
				value = 0;
			}
			_timeScale = value;
		}
		/**
		 * Creates a new WorldClock instance. (use the static var WorldClock.clock instead).
		 */
		public function WorldClock()
		{
			_time = getTimer() * 0.001;
			_animatableList = new Vector.<IAnimatable>;
		}
		
		/** 
		 * Returns true if the IAnimatable instance is contained by WorldClock instance.
		 * @param	An IAnimatable instance (Armature or custom)
		 * @return true if the IAnimatable instance is contained by WorldClock instance.
		 */
		public function contains(animatable:IAnimatable):Boolean
		{
			return _animatableList.indexOf(animatable) >= 0;
		}
		/**
		 * Add a IAnimatable instance (Armature or custom) to this WorldClock instance.
		 * @param	An IAnimatable instance (Armature, WorldClock or custom)
		 */
		public function add(animatable:IAnimatable):void
		{
			if (animatable && _animatableList.indexOf(animatable) == -1)
			{
				_animatableList.push(animatable);
			}
		}
		/**
		 * Remove a IAnimatable instance (Armature or custom) from this WorldClock instance.
		 * @param	An IAnimatable instance (Armature or custom)
		 */
		public function remove(animatable:IAnimatable):void
		{
			var index:int = _animatableList.indexOf(animatable);
			if (index >= 0)
			{
				_animatableList[index] = null;
			}
		}
		/**
		 * Remove all IAnimatable instance (Armature or custom) from this WorldClock instance.
		 *
		 */
		public function clear():void
		{
			_animatableList.length = 0;
		}
		/**
		 * Update all registered IAnimatable instance animations using this method typically in an ENTERFRAME Event or with a Timer.
		 * @param	The amount of second to move the playhead ahead.
		 */
		public function advanceTime(passedTime:Number):void
		{
			if(passedTime < 0)
			{
				var currentTime:Number = getTimer() * 0.001;
				passedTime = currentTime - _time;
				_time = currentTime;
			}
			
			passedTime *= _timeScale;
			
			var length:int = _animatableList.length;
			if(length == 0)
			{
				return;
			}
			var currentIndex:int = 0;
			
			for(var i:int = 0;i < length;i ++)
			{
				var animatable:IAnimatable = _animatableList[i];
				if(animatable)
				{
					if(currentIndex != i)
					{
						_animatableList[currentIndex] = animatable;
						_animatableList[i] = null;
					}
					animatable.advanceTime(passedTime);
					currentIndex ++;
				}
			}
			
			if (currentIndex != i)
			{
				length = _animatableList.length;
				while(i < length)
				{
					_animatableList[currentIndex ++] = _animatableList[i ++];
				}
				_animatableList.length = currentIndex;
			}
		}
	}
}