package com.citrusengine.objects.common 
{
	import com.citrusengine.objects.CitrusSprite;
	
	public class EmitterParticle extends CitrusSprite
	{
		public var velocityX:Number = 0;
		public var velocityY:Number = 0;
		public var birthTime:Number = 0;
		public var canRecycle:Boolean = true;
		
		public function EmitterParticle(name:String, params:Object = null) 
		{
			super(name, params);
			
			if (birthTime == 0)
				birthTime = new Date().time;
		}
	}

}