package citrus.objects.platformer.box2d {

	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;

	import citrus.objects.Box2DPhysicsObject;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	
	/**
	 * A Platform is a rectangular object that is meant to be stood on. It can be given any position, width, height, or rotation to suit your level's needs.
	 * You can make your platform a "one-way" or "cloud" platform so that you can jump on from underneath (collision is only applied when coming from above it).
	 * 
	 * There are two ways of adding graphics for your platform. You can give your platform a graphic just like you would any other object (by passing a graphical
	 * class into the view property) or you can leave your platform invisible and line it up with your backgrounds for a more custom look.
	 * 
	 * <ul>Properties:
	 * <li>oneWay - Makes the platform only collidable when falling from above it.</li></ul>
	 */
	public class Platform extends Box2DPhysicsObject
	{
		private var _oneWay:Boolean = false;
		
		public function Platform(name:String, params:Object = null )
		{
			super(name, params);
		}
		
		/**
		 * Makes the platform only collidable when falling from above it.
		 */
		public function get oneWay():Boolean
		{
			return _oneWay;
		}
		
		[Inspectable(defaultValue="false")]
		public function set oneWay(value:Boolean):void
		{
			if (_oneWay == value)
				return;
			
			_oneWay = value;
			
			if (!_fixture)
				return;
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			
			_bodyDef.type = b2Body.b2_staticBody;
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			
			_fixtureDef.restitution = 0;
		}
			
		override public function handlePreSolve(contact:b2Contact, oldManifold:b2Manifold):void {
			
			if (_oneWay) {
				
				//Get the y position of the top of the platform
				var platformTop:Number = _body.GetPosition().y - _height / 2;
				
				//Get the half-height of the collider, if we can guess what it is (we are hoping the collider extends PhysicsObject).
				var colliderHalfHeight:Number = 0;
				var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
				if (collider.height)
					colliderHalfHeight = collider.height / _box2D.scale / 2;
				else
					return;
				
				//Get the y position of the bottom of the collider
				var colliderBottom:Number = collider.body.GetPosition().y + colliderHalfHeight;
				
				//Find out if the collider is below the platform
				if (platformTop < colliderBottom)
					contact.SetEnabled(false);
			}
		}
	}
}