package com.citrusengine.objects.platformer.nape 
{

	//import Box2DAS.Common.V2;
	//import Box2DAS.Dynamics.ContactEvent;

	//import com.citrusengine.objects.Box2DPhysicsObject;
	//import com.citrusengine.physics.Box2DCollisionCategories;
	
	import com.citrusengine.objects.NapePhysicsObject;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.CbType;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.space.Space;
	

	import org.osflash.signals.Signal;

	import flash.display.MovieClip;
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
	public class Missile extends NapePhysicsObject 
	{
		public static const MISSILE:CbType = new CbType();
		/**
		 * The speed that the missile moves at.
		 */
		public var speed:Number = 200;
		/**
		 * In degrees, the angle that the missile will fire at. Right is zero degrees, going clockwise.
		 */
		public var angle:Number = 0;
		/**
		 * In milliseconds, how long the explode animation lasts before the missile object is destroyed.
		 */
		public var explodeDuration:Number = 1000;
		/**
		 * In milliseconds, how long the missile lasts before it explodes if it doesn't touch anything.
		 */
		public var fuseDuration:Number = 10000;
		/**
		 * Flag to determine whether explosion exerts outward force on nearby dynamic objects
		 */
		public var useForce:Boolean = true;
		/**
		 * Dispatched when the missile explodes. Passes two parameters:
		 * 		1. The Missile (Missile)
		 * 		2. The Object it exploded on (PhysicsObject)
		 */
		public var onExplode:Signal;
		
		private var _velocity:Vec2;
		private var _exploded:Boolean = false;
		private var _explodeTimeoutID:Number = 0;
		private var _fuseDurationTimeoutID:Number = 0;
		private var _contact:NapePhysicsObject;
		
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, angle:Number, view:* = null, speed:Number = 200, fuseDuration:Number = 10000, explodeDuration:Number = 1000, useForce:Boolean = true):Missile
		{
			if (view == null) view = MovieClip;
			return new Missile(name, { x: x, y: y, width: width, height: height, angle: angle, view: view, speed: speed, fuseDuration: fuseDuration, explodeDuration: explodeDuration, useForce:useForce } );
		}
		
		public function Missile(name:String, params:Object = null) 
		{
			super(name, params);
			onExplode = new Signal(Missile, NapePhysicsObject);
		}
			
		override public function initialize():void {
			
			super.initialize();
			
			_velocity = new Vec2(speed, 0);
			_velocity.rotate(angle);
			_inverted = speed < 0;
			
			_fuseDurationTimeoutID = setTimeout(explode, fuseDuration);
			_body.velocity = _velocity;
		}
		
		override public function destroy():void
		{
			onExplode.removeAll();
			//_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			clearTimeout(_explodeTimeoutID);
			clearTimeout(_fuseDurationTimeoutID);
			
			super.destroy();
		}
		
		override public function get rotation():Number
		{
			return angle;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			var removeGravity:Vec2 = new Vec2();
			removeGravity.subeq(_nape.gravity);
			removeGravity.muleq(_body.mass);
			_body.applyLocalForce(removeGravity);
			
			if (!_exploded)
			{
				_body.velocity = _velocity;
			}
			else
			{
				_body.velocity = new Vec2();
			}
			
			updateAnimation();
		}
		
		/**
		 * Explodes the missile
		 */
		public function explode():void
		{
			if (_exploded)
				return;
			
			_exploded = true;
			
			//Not collideable with anything anymore.
			// FIXME need a nape alt for this command
			//_fixture.SetFilterData({ maskBits: Box2DCollisionCategories.GetNone() });
			
			onExplode.dispatch(this, _contact);
			
			clearTimeout(_fuseDurationTimeoutID);
			_explodeTimeoutID = setTimeout(killMissile, explodeDuration);
			
			
			// here we jump into the body list of the nape space, and poll for distance from bomb. If close enough push force from explosion point
			if (useForce) {
				
				var explosionVec2:Vec2 = new Vec2(x, y);
				
				var bodies:BodyList = _nape.space.bodies;
				var b:Body;
				var ballVec2:Vec2;
				var impulseVector:Vec2;
				var ll:uint = bodies.length;
				for (var i:int = 0; i < ll; i ++) {
					b = bodies.at(i);
					if (!b.isDynamic()) continue;
					ballVec2 = b.position;
					impulseVector = new Vec2(ballVec2.x - explosionVec2.x, ballVec2.y - explosionVec2.y);
					if (impulseVector.length < 400) {
						var impulseForce:Number = (400 - impulseVector.length) / 30;
						var impulse:Vec2 = new Vec2(impulseVector.x * impulseForce, impulseVector.y * impulseForce * 1.4);
						b.applyRelativeImpulse(impulse);
					}
				}
			}
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
		}
		
		override protected function createBody():void 
		{
			super.createBody();
			
			_body.allowRotation = false;
		}
		override protected function createConstraint():void {
			
			_body.space = _nape.space;			
			_body.cbTypes.add(MISSILE);
		}
		override public function handleBeginContact(callback:InteractionCallback):void
		{
			explode();
		}
		
		protected function updateAnimation():void
		{
			if (_exploded)
			{
				_animation = "exploded";
			}
			else
			{
				_animation = "normal";
			}
		}
		
		protected function killMissile():void
		{
			kill = true;
		}
	}

}