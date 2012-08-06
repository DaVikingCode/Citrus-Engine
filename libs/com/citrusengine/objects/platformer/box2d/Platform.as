package com.citrusengine.objects.platformer.box2d
{
	import Box2DAS.Dynamics.ContactEvent;
	import Box2DAS.Dynamics.b2Body;
	
	import com.citrusengine.objects.Box2DPhysicsObject;
	
	/**
	 * A Platform is a rectangular object that is meant to be stood on. It can be given any position, width, height, or rotation to suit your level's needs.
	 * You can make your platform a "one-way" or "cloud" platform so that you can jump on from underneath (collision is only applied when coming from above it).
	 * 
	 * There are two ways of adding graphics for your platform. You can give your platform a graphic just like you would any other object (by passing a graphical
	 * class into the view property) or you can leave your platform invisible and line it up with your backgrounds for a more custom look.
	 * 
	 * Properties:
	 * oneWay - Makes the platform only collidable when falling from above it.
	 */
	public class Platform extends Box2DPhysicsObject
	{
		private var _oneWay:Boolean = false;
		
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number):Platform
		{
			return new Platform(name, { x: x, y: y, width: width, height: height } );
		}
		
		public function Platform(name:String, params:Object = null )
		{
			super(name, params);
		}
		
		override public function destroy():void
		{
			_fixture.removeEventListener(ContactEvent.PRE_SOLVE, handlePreSolve);
			super.destroy();
		}
		
		/**
		 * Makes the platform only collidable when falling from above it.
		 */
		public function get oneWay():Boolean
		{
			return _oneWay;
		}
		
		[Property(value="false")]
		public function set oneWay(value:Boolean):void
		{
			if (_oneWay == value)
				return;
			
			_oneWay = value;
			
			if (!_fixture)
				return;
			
			if (_oneWay)
			{
				_fixture.m_reportPreSolve = true;
				_fixture.addEventListener(ContactEvent.PRE_SOLVE, handlePreSolve);
			}
			else
			{
				_fixture.m_reportPreSolve = false;
				_fixture.removeEventListener(ContactEvent.PRE_SOLVE, handlePreSolve);
			}
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
		
		override protected function createFixture():void
		{
			super.createFixture();
			
			if (_oneWay)
			{
				_fixture.m_reportPreSolve = true;
				_fixture.addEventListener(ContactEvent.PRE_SOLVE, handlePreSolve);
			}
		}
		
		protected function handlePreSolve(e:ContactEvent):void
		{
			//Get the y position of the top of the platform
			var platformTop:Number = _body.GetPosition().y - _height / 2;
			
			//Get the half-height of the collider, if we can guess what it is (we are hoping the collider extends PhysicsObject).
			var colliderHalfHeight:Number = 0;
			if (e.other.GetBody().GetUserData().height)
				colliderHalfHeight = e.other.GetBody().GetUserData().height / _box2D.scale / 2;
			else
				return;
			
			//Get the y position of the bottom of the collider
			var colliderBottom:Number = e.other.GetBody().GetPosition().y + colliderHalfHeight;
			
			//Find out if the collider is below the platform
			if (platformTop < colliderBottom)
				e.contact.Disable();
		}
	}
}