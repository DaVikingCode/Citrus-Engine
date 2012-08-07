package com.citrusengine.objects.platformer.box2d
{

	import com.citrusengine.objects.Box2DPhysicsObject;

	import flash.display.MovieClip;
	
	/**
	 * A very simple physics object. I just needed to add bullet mode and zero restitution
	 * to make it more stable, otherwise it gets very jittery. 
	 */	
	public class Crate extends Box2DPhysicsObject
	{
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, view:* = null):Crate
		{
			if (view == null) view = MovieClip;
			return new Crate(name, { x: x, y: y, width: width, height: height, view: view } );
		}
		
		public function Crate(name:String, params:Object=null)
		{
			super(name, params);
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			_bodyDef.bullet = true;
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.density = 0.1;
			_fixtureDef.restitution = 0;
		}
	}
}