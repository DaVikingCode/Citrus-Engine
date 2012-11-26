package com.citrusengine.objects.platformer.box2d {

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.b2Body;

	import com.citrusengine.math.MathVector;
	import com.citrusengine.physics.box2d.Box2DUtils;

	/**
	 * A platform that rotates around a specified point
	 */
	public class RevolvingPlatform extends Platform {
		
		/**
		 * The speed at which the revolving platform travels. 
		 */
		[Inspectable(defaultValue="1")]
		public var speed:Number = 5;

		protected var _startAngle:Number = 0;
		protected var _accAngle:Number = 0;
		protected var _xOffset:Number = 60;
		// distance from center on the x axis
		protected var _yOffset:Number = 60;
		// distance from center on the y axis
		protected var _center:MathVector = new MathVector();
		protected var _passengers:Vector.<b2Body> = new Vector.<b2Body>();

		public function RevolvingPlatform(name:String, params:Object = null) {
			super(name, params);
		}

		override public function destroy():void {
			_passengers.length = 0;
			
			super.destroy();
		}

		override public function set x(value:Number):void {
			super.x = value;
			
			centerX = value;
		}

		override public function set y(value:Number):void {
			super.y = value;
			
			centerY = value;
		}

		[Inspectable(defaultValue="0")]
		public function set startAngle(value:Number):void {
			_startAngle = value * Math.PI / 180;
			_accAngle = _startAngle;
		}

		[Inspectable(defaultValue="0")]
		public function set centerX(value:Number):void {
			_center.x = value / _box2D.scale;
		}

		[Inspectable(defaultValue="0")]
		public function set centerY(value:Number):void {
			_center.y = value / _box2D.scale;
		}

		public function get xOffset():Number {
			return _xOffset * _box2D.scale;
		}

		[Inspectable(defaultValue="60")]
		public function set xOffset(value:Number):void {
			_xOffset = value / _box2D.scale;
		}

		public function get yOffset():Number {
			return _yOffset * _box2D.scale;
		}

		[Inspectable(defaultValue="60")]
		public function set yOffset(value:Number):void {
			_yOffset = value / _box2D.scale;
		}

		override protected function defineBody():void {
			super.defineBody();
			
			_bodyDef.type = b2Body.b2_kinematicBody;
			_bodyDef.allowSleep = false;
		}

		override public function handleBeginContact(contact:b2Contact):void {

			_passengers.push(Box2DUtils.CollisionGetOther(this, contact).body);
		}

		override public function handleEndContact(contact:b2Contact):void {

			_passengers.splice(_passengers.indexOf(Box2DUtils.CollisionGetOther(this, contact).body), 1);
		}

		override public function update(timeDelta:Number):void {
			
			var platformVec:b2Vec2;
			var differenceVec:b2Vec2;
			var passengerVec:b2Vec2;

			super.update(timeDelta);

			_accAngle += timeDelta;

			// calculate new position
			platformVec = new b2Vec2();
			platformVec.x = _center.x + Math.sin(_accAngle * speed) * _xOffset;
			platformVec.y = _center.y + Math.cos(_accAngle * speed) * _yOffset;

			// get the difference between the new position and the current position
			differenceVec = platformVec.Copy();
			differenceVec.Subtract(_body.GetPosition());

			// update passenger positions to account for platform's motion
			for each (var b:b2Body in _passengers) {
				passengerVec = b.GetPosition();
				passengerVec.Add(differenceVec);
				b.SetPosition(passengerVec);
			}

			// update platform's position
			_body.SetPosition(platformVec);
		}
	}

}