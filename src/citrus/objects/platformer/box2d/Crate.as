package citrus.objects.platformer.box2d
{

	import citrus.objects.Box2DPhysicsObject;
	
	/**
	 * An object made for Continuous Collision Detection. It should only be used for very fast, small moving dynamic bodies. 
	 */	
	public class Crate extends Box2DPhysicsObject
	{
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