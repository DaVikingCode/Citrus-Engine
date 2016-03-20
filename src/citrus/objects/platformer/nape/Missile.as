package citrus.objects.platformer.nape {

	import citrus.objects.NapePhysicsObject;
	import citrus.physics.PhysicsCollisionCategories;
	import citrus.physics.nape.NapeUtils;

	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.dynamics.InteractionFilter;
	import nape.geom.Vec2;

	import org.osflash.signals.Signal;

	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * A missile is an object that moves at a particular trajectory and speed, and explodes when it comes into contact with something.
	 * Often you will want the object that it exploded on to also die (or at least get hurt), such as a hero or an enemy.
	 * Since the missile can potentially be used for any purpose, by default the missiles do not do any damage or kill the object that
	 * they collide with. You will have to handle this manually using the onExplode() handler.
	 * 
	 * Properties:
	 * angle - In degrees, the angle that the missile will fire at. Right is zero degrees, going clockwise.
	 * speed - The speed that the missile moves at.
	 * fuseDuration - In milliseconds, how long the missile lasts before it explodes if it doesn't touch anything.
	 * explodeDuration - In milliseconds, how long the explode animation lasts before the missile object is destroyed.
	 * 
	 * Events
	 * onExplode - Dispatched when the missile explodes. Passes two parameters:
	 * 		1. The Missile (Missile)
	 * 		2. The Object it exploded on (PhysicsObject)
	 */
	public class Missile extends NapePhysicsObject {
		
		public static const MISSILE:CbType = new CbType();
		
		/**
		 * The speed that the missile moves at.
		 */
		[Inspectable(defaultValue="60")]
		public var speed:Number = 60;
		
		/**
		 * In degrees, the angle that the missile will fire at. Right is zero degrees, going clockwise.
		 */
		[Inspectable(defaultValue="0")]
		public var angle:Number = 0;
		
		/**
		 * In milliseconds, how long the explode animation lasts before the missile object is destroyed.
		 */
		[Inspectable(defaultValue="1000")]
		public var explodeDuration:Number = 1000;
		
		/**
		 * In milliseconds, how long the missile lasts before it explodes if it doesn't touch anything.
		 */
		[Inspectable(defaultValue="10000")]
		public var fuseDuration:Number = 10000;
		
		/**
		 * Dispatched when the missile explodes. Passes two parameters:
		 * 		1. The Missile (Missile)
		 * 		2. The Object it exploded on (PhysicsObject)
		 */
		public var onExplode:Signal;
		
		protected var _velocity:Vec2;
		protected var _exploded:Boolean = false;
		protected var _explodeTimeoutID:uint = 0;
		protected var _fuseDurationTimeoutID:uint = 0;
		protected var _contact:NapePhysicsObject;
		
		public function Missile(name:String, params:Object = null) {
			
			updateCallEnabled = true;
			_beginContactCallEnabled = true;
			
			super(name, params);
			
			onExplode = new Signal(Missile, NapePhysicsObject);
			
			_velocity = new Vec2(speed, 0);
			_velocity.rotate(angle * Math.PI / 180);
			_inverted = speed < 0;
		}
			
		override public function addPhysics():void {
			super.addPhysics();
			
			_fuseDurationTimeoutID = setTimeout(explode, fuseDuration);
			_body.velocity = _velocity;
			
			updateAnimation();
		}

		override public function destroy():void {
			
			onExplode.removeAll();
			
			clearTimeout(_explodeTimeoutID);
			clearTimeout(_fuseDurationTimeoutID);
			
			super.destroy();
		}
		
		override public function get rotation():Number {
			return angle;
		}
			
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			if (_exploded) 
				_body.velocity = new Vec2();
			
			updateAnimation();
		}
		
		/**
		 * Explodes the missile
		 */
		public function explode():void {
			
			if (_exploded)
				return;
			
			_exploded = true;
			updateAnimation();
			
			var filter:InteractionFilter = new InteractionFilter();
			filter.collisionMask = PhysicsCollisionCategories.GetNone();
			_body.setShapeFilters(filter);
			
			onExplode.dispatch(this, _contact);
			
			clearTimeout(_fuseDurationTimeoutID);
			_explodeTimeoutID = setTimeout(killMissile, explodeDuration);
		}
		
		override protected function createBody():void {
			
			super.createBody();
			
			_body.allowRotation = false;
			_body.gravMass = 0;
			_body.rotate(new Vec2(_x, _y), angle * Math.PI / 180);
		}
			
		override protected function createConstraint():void {
			
			_body.space = _nape.space;			
			_body.cbTypes.add(MISSILE);
		}
		
		override public function handleBeginContact(callback:InteractionCallback):void {
			
			_contact = NapeUtils.CollisionGetOther(this, callback);
			
			if (!callback.arbiters.at(0).shape1.sensorEnabled && !callback.arbiters.at(0).shape2.sensorEnabled)
				explode();
		}
		
		protected function updateAnimation():void {
			
			_animation = _exploded ? "exploded" : "normal";
		}
		
		protected function killMissile():void {
			
			kill = true;
		}

	}
}
