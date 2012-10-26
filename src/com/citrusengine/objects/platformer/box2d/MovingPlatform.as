package com.citrusengine.objects.platformer.box2d {

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;

	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.Box2DPhysicsObject;
	
	/**
	 * A platform that moves between two points. The MovingPlatform has several properties that
	 * can customize it.
	 * 
	 * Properties:
	 * speed - The speed at which the moving platform travels. 
	 * enabled - Whether or not the MovingPlatform can move, no matter the condition.
	 * startX -  The initial starting X position of the MovingPlatform, and the place it returns to when it reaches the end destination.
	 * startY -  The initial starting Y position of the MovingPlatform, and the place it returns to when it reaches the end destination.
	 * endX -  The ending X position of the MovingPlatform, and the place it returns to when it reaches the start destination.
	 * endY -  The ending Y position of the MovingPlatform, and the place it returns to when it reaches the start destination.
	 * waitForPassenger - If set to true, MovingPlatform will not move unless there is a passenger. If set to false, it continually moves.
	 */	
	public class MovingPlatform extends Platform
	{
		/**
		 * The speed at which the moving platform travels. 
		 */
		[Inspectable(defaultValue="1")]
		public var speed:Number = 1;
		
		/**
		 * Whether or not the MovingPlatform can move, no matter the condition. 
		 */		
		[Inspectable(defaultValue="true")]
		public var enabled:Boolean = true;
		
		/**
		 * If set to true, the MovingPlatform will not move unless there is a passenger. 
		 */
		[Inspectable(defaultValue="false")]
		public var waitForPassenger:Boolean = false;
		
		protected var _start:MathVector = new MathVector();
		protected var _end:MathVector = new MathVector();
		protected var _forward:Boolean = true;
		protected var _passengers:Vector.<b2Body> = new Vector.<b2Body>();
		
		public function MovingPlatform(name:String, params:Object=null)
		{
			super(name, params);
		}
		
		override public function destroy():void
		{
			_passengers.length = 0;
			
			super.destroy();
		}
		
		override public function set x(value:Number):void
		{
			super.x = value;
			
			_start.x = value / _box2D.scale;
		}
		
		override public function set y(value:Number):void
		{
			super.y = value;
			
			_start.y = value / _box2D.scale;
		}
		
		/**
		 * The initial starting X position of the MovingPlatform, and the place it returns to when it reaches
		 * the end destination.
		 */		
		public function get startX():Number
		{
			return _start.x * _box2D.scale;
		}
		
		[Inspectable(defaultValue="0")]
		public function set startX(value:Number):void
		{
			_start.x = value / _box2D.scale;
		}
		
		/**
		 * The initial starting Y position of the MovingPlatform, and the place it returns to when it reaches
		 * the end destination.
		 */		
		public function get startY():Number
		{
			return _start.y * _box2D.scale;
		}
		
		[Inspectable(defaultValue="0")]
		public function set startY(value:Number):void
		{
			_start.y = value / _box2D.scale;
		}
		
		/**
		 * The ending X position of the MovingPlatform.
		 */		
		public function get endX():Number
		{
			return _end.x * _box2D.scale;
		}
		
		[Inspectable(defaultValue="0")]
		public function set endX(value:Number):void
		{
			_end.x = value / _box2D.scale;
		}
		
		/**
		 * The ending Y position of the MovingPlatform.
		 */		
		public function get endY():Number
		{
			return _end.y * _box2D.scale;
		}
		
		[Inspectable(defaultValue="0")]
		public function set endY(value:Number):void
		{
			_end.y = value / _box2D.scale;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			var velocity:b2Vec2 = _body.GetLinearVelocity();
			
			if ((waitForPassenger && _passengers.length == 0) || !enabled)
			{
				//Platform should not move
				velocity.SetZero();
			}
			else
			{
				//Move the platform according to its destination
				
				var destination:b2Vec2 = new b2Vec2(_end.x, _end.y);
				if (!_forward)
					destination = new b2Vec2(_start.x, _start.y);
				
				destination.Subtract(_body.GetPosition());
				velocity = destination;
				
				if (velocity.Length() > speed / 30)
				{
					//Still has further to go. Normalize the velocity to the max speed
					velocity.Normalize();
				}
				else
				{
					//Destination is very close. Switch the travelling direction
					_forward = !_forward;
				}
			}
			
			_body.SetLinearVelocity(velocity);
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			_bodyDef.type = b2Body.b2_kinematicBody; //Kinematic bodies don't respond to outside forces, only velocity.
			_bodyDef.allowSleep = false;
		}
		
		
		override public function handleBeginContact(contact:b2Contact):void {
			
			_passengers.push(Box2DPhysicsObject.CollisionGetOther(this, contact).body);
		}
		
		
		override public function handleEndContact(contact:b2Contact):void {
			
			_passengers.splice(_passengers.indexOf(Box2DPhysicsObject.CollisionGetOther(this, contact).body), 1); 
		}
	}
}