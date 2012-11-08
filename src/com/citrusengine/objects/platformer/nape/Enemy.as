package com.citrusengine.objects.platformer.nape {

	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.geom.Vec2;

	import com.citrusengine.objects.NapePhysicsObject;

	import flash.utils.clearTimeout;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	
	/**
	 * This is a common example of a side-scrolling bad guy. He has limited logic, basically
	 * only turning around when he hits a wall.
	 * 
	 * When controlling collision interactions between two objects, such as a Hero and Enemy,
	 * I like to let each object perform its own actions, not control one object's action from the other object.
	 * For example, the Hero doesn't contain the logic for killing the Enemy, and the Enemy doesn't contain the
	 * logic for making the hero "Spring" when he kills him. 
	 */
	public class Enemy extends NapePhysicsObject {
		
		public static const ENEMY:CbType = new CbType();
		
		[Inspectable(defaultValue="39")]
		public var speed:Number = 39;
		
		[Inspectable(defaultValue="3")]
		public var enemyKillVelocity:Number = 3;
		
		[Inspectable(defaultValue="left",enumeration="left,right")]
		public var startingDirection:String = "left";
		
		[Inspectable(defaultValue="400")]
		public var hurtDuration:Number = 400;
		
		[Inspectable(defaultValue="-100000")]
		public var leftBound:Number = -100000;
		
		[Inspectable(defaultValue="100000")]
		public var rightBound:Number = 100000;
		
		protected var _hurtTimeoutID:Number = 0;
		protected var _hurt:Boolean = false;
		protected var _enemyClass:* = Hero;
		protected var _lastXPos:Number;
		protected var _lastTimeTurnedAround:Number = 0;
		protected var _waitTimeBeforeTurningAround:Number = 1000;
		
		public function Enemy(name:String, params:Object=null) {
			
			super(name, params);
		}
			
		override public function initialize(poolObjectParams:Object = null):void {
			
			super.initialize(poolObjectParams);
			
			if (startingDirection == "left")
				_inverted = true;
		}

		override public function destroy():void {
			
			clearTimeout(_hurtTimeoutID);
			
			super.destroy();
		}
		
		public function get enemyClass():* {
			return _enemyClass;
		}
		
		[Inspectable(defaultValue="com.citrusengine.objects.platformer.nape.Hero",type="String")]
		public function set enemyClass(value:*):void {
			if (value is String)
				_enemyClass = getDefinitionByName(value) as Class;
			else if (value is Class)
				_enemyClass = value;
		}
		
		override public function update(timeDelta:Number):void {
			
			super.update(timeDelta);
			
			var position:Vec2 = _body.position;
			_lastXPos = position.x;
			
			//Turn around when they pass their left/right bounds
			if ((_inverted && position.x < leftBound) || (!_inverted && position.x > rightBound))
				turnAround();
			
			var velocity:Vec2 = _body.velocity;
			
			if (!_hurt)
				velocity.x = _inverted ? -speed : speed;
			else
				velocity.x = 0;
			
			_body.velocity = velocity;
			
			updateAnimation();
		}
		
		public function hurt():void {
			
			_hurt = true;
			_hurtTimeoutID = setTimeout(endHurtState, hurtDuration);
		}
		
		public function turnAround():void {
			
			_inverted = !_inverted;
			_lastTimeTurnedAround = new Date().time;
		}
		
		override protected function createBody():void {
			
			super.createBody();
			
			_body.allowRotation = false;
		}
		
		override protected function createConstraint():void {
			
			_body.space = _nape.space;			
			_body.cbTypes.add(ENEMY);
		}
			
		override public function handleBeginContact(callback:InteractionCallback):void {
			
			var collider:NapePhysicsObject = callback.int2.castBody.userData.myData;
			
			if (collider is _enemyClass && collider.body.velocity.y > enemyKillVelocity)
				hurt();
			else if (collider is Platform || collider is Enemy)
				turnAround();
		}
		
		protected function updateAnimation():void {
			
			_animation = _hurt ? "die" : "walk";
		}
		
		protected function endHurtState():void {
			
			_hurt = false;
			kill = true;
		}

	}
}
