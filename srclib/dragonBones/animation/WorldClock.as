package dragonBones.animation
{
	import dragonBones.Armature;
	
	import flash.utils.getTimer;
	
	public final class WorldClock implements IAnimatable
	{
		public static var clock:WorldClock = new WorldClock();
		
		private var animatableList:Vector.<IAnimatable>;
		
		private var _time:Number;
		public function get time():Number
		{
			return _time;
		}
		
		private var _timeScale:Number = 1;
		public function get timeScale():Number
		{
			return _timeScale;
		}
		public function set timeScale(value:Number):void
		{
			if (value < 0 || isNaN(value)) 
			{
				value = 0;
			}
			_timeScale = value;
		}
		
		public function WorldClock()
		{
			_time = getTimer() * 0.001;
			animatableList = new Vector.<IAnimatable>;
		}
		
		public function contains(animatable:IAnimatable):Boolean
		{
			return animatableList.indexOf(animatable) >= 0;
		}
		
		public function add(animatable:IAnimatable):void
		{
			if(animatable && animatableList.indexOf(animatable) == -1)
			{
				animatableList.push(animatable);
			}
		}
		
		public function remove(animatable:IAnimatable):void
		{
			var index:int = animatableList.indexOf(animatable);
			if(index >= 0)
			{
				animatableList[index] = null;
			}
		}
		
		public function clear():void
		{
			animatableList.length = 0;
		}
		
		public function advanceTime(passedTime:Number):void 
		{
			if(passedTime < 0)
			{
				var currentTime:Number = getTimer() * 0.001;
				passedTime = currentTime - _time;
				_time = currentTime;
			}
			
			passedTime *= _timeScale;
			
			var length:int = animatableList.length;
			if (length == 0)
			{
				return;
			}
			var currentIndex:int = 0;
			
			for(var i:int = 0; i< length;i ++)
			{
				var animatable:IAnimatable = animatableList[i];
				if (animatable)
				{
					if (currentIndex != i) 
					{
						animatableList[currentIndex] = animatable;
						animatableList[i] = null;
					}
					animatable.advanceTime(passedTime);
					currentIndex ++;
				}
			}
			
			if (currentIndex != i)
			{
				length = animatableList.length;
				while (i < length)
				{
					animatableList[currentIndex ++] = animatableList[i ++];
				}
				animatableList.length = currentIndex;
			}
		}
	}
}