package com.citrusengine.system.components.box2d.hero {

	import Box2DAS.Dynamics.ContactEvent;
	import Box2DAS.Dynamics.b2Fixture;

	import com.citrusengine.math.MathVector;
	import com.citrusengine.system.components.box2d.CollisionComponent;

	/**
	 * @author Aymeric
	 */
	public class HeroCollisionComponent extends CollisionComponent {
		
		protected var _viewComponent:HeroViewComponent;
		protected var _moveComponent:HeroMoveComponent;
		
		protected var _combinedGroundAngle:Number = 0;

		public function HeroCollisionComponent(name:String, params:Object = null) {
			
			super(name, params);
		}
			
		override public function initialize():void {
			
			super.initialize();
			
			_viewComponent = entity.components["view"];
			_moveComponent = entity.components["move"];
		}

		override public function handleBeginContact(e:ContactEvent):void {
			
			super.handleBeginContact(e);
			
			//Collision angle
			if (e.normal) //The normal property doesn't come through all the time. I think doesn't come through against sensors.
			{
				var collisionAngle:Number = new MathVector(e.normal.x, e.normal.y).angle * 180 / Math.PI;
				if (collisionAngle > 45 && collisionAngle < 135)
				{
					_viewComponent.groundContacts.push(e.other);
					_moveComponent.onGround = true;
					updateCombinedGroundAngle();
				}
			}
		}
			
		override public function handleEndContact(e:ContactEvent):void {
			
			super.handleEndContact(e);
			
			//Remove from ground contacts, if it is one.
			var index:int = _viewComponent.groundContacts.indexOf(e.other);
			if (index != -1)
			{
				_viewComponent.groundContacts.splice(index, 1);
				if (_viewComponent.groundContacts.length == 0)
					_moveComponent.onGround = false;
				updateCombinedGroundAngle();
			}
		}
		
		protected function updateCombinedGroundAngle():void {
			
			_combinedGroundAngle = 0;
			
			if (_viewComponent.groundContacts.length == 0)
				return;
			
			for each (var contact:b2Fixture in _viewComponent.groundContacts)
				var angle:Number = contact.GetBody().GetAngle();
				
			var turn:Number = 45 * Math.PI / 180;
			angle = angle % turn;
			_combinedGroundAngle += angle;
			_combinedGroundAngle /= _viewComponent.groundContacts.length;
		}

		public function get combinedGroundAngle():Number {
			return _combinedGroundAngle;
		}
	}
}
