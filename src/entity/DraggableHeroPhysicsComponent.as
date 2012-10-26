package entity {

	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;

	import com.citrusengine.system.components.box2d.hero.HeroPhysicsComponent;

	import flash.display.DisplayObject;

	public class DraggableHeroPhysicsComponent extends HeroPhysicsComponent {

		private var _jointDef:b2MouseJointDef;
		private var _joint:b2MouseJoint;
		private var _mouseScope:DisplayObject;

		public function DraggableHeroPhysicsComponent(name:String, params:Object = null) {
			super(name, params);
		}

		override public function destroy():void {
			
			if (_joint)
				_box2D.world.DestroyJoint(_joint);
				
			super.destroy();
		}

		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);

			if (_joint) {
				_joint.SetTarget(new b2Vec2(_mouseScope.mouseX / _box2D.scale, _mouseScope.mouseY / _box2D.scale));
			}
		}

		public function enableHolding(mouseScope:DisplayObject):void {
			
			if (_joint)
				return;

			_mouseScope = mouseScope;
			_jointDef.target = new b2Vec2(_mouseScope.mouseX / _box2D.scale, _mouseScope.mouseY / _box2D.scale);
			_joint = _box2D.world.CreateJoint(_jointDef) as b2MouseJoint;
		}

		public function disableHolding():void {
			
			if (!_joint)
				return;

			_box2D.world.DestroyJoint(_joint);
			_joint = null;
		}

		override protected function defineFixture():void {
			
			super.defineFixture();
			
			_fixtureDef.density = 0.1;
		}

		override protected function defineJoint():void {
			
			super.defineJoint();

			_jointDef = new b2MouseJointDef();
			_jointDef.bodyA = _box2D.world.GetGroundBody();
			_jointDef.bodyB = _body;
			_jointDef.dampingRatio = .2;
			_jointDef.frequencyHz = 100;
			_jointDef.maxForce = 100;
		}
	}
}