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
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	
	/**
	 * This is a common, simple, yet solid implementation of a side-scrolling Hero. 
	 * The hero can run, jump, get hurt, and kill enemies. It dispatches signals
	 * when significant events happen. The game state's logic should listen for those signals
	 * to perform game state updates (such as increment coin collections).
	 * 
	 * Don't store data on the hero object that you will need between two or more levels (such
	 * as current coin count). The hero should be re-created each time a state is created or reset.
	 */
	public class Hero extends NapePhysicsObject {
		
		public static const HERO:CbType = new CbType();		
		
		//properties
		/**
		 * This is the rate at which the hero speeds up when you move him left and right. 
		 */
		[Inspectable(defaultValue="30")]
		public var acceleration:Number = 30;
		
		/**
		 * This is the fastest speed that the hero can move left or right. 
		 */
		[Inspectable(defaultValue="240")]
		public var maxVelocity:Number = 240;
		
		/**
		 * This is the initial velocity that the hero will move at when he jumps.
		 */
		[Inspectable(defaultValue="330")]
		public var jumpHeight:Number = 330;
		
		/**
		 * This is the amount of "float" that the hero has when the player holds the jump button while jumping. 
		 */
		[Inspectable(defaultValue="9")]
		public var jumpAcceleration:Number = 9;
		
		/**
		 * This is the y velocity that the hero must be travelling in order to kill an Enemy.
		 */
		[Inspectable(defaultValue="-90")]
		public var killVelocity:Number = -90;
		
		/**
		 * The y velocity that the hero will spring when he kills an enemy. 
		 */
		[Inspectable(defaultValue="240")]
		public var enemySpringHeight:Number = 240;
		
		/**
		 * The y velocity that the hero will spring when he kills an enemy while pressing the jump button. 
		 */
		[Inspectable(defaultValue="270")]
		public var enemySpringJumpHeight:Number = 270;
		
		/**
		 * How long the hero is in hurt mode for. 
		 */
		[Inspectable(defaultValue="1000")]
		public var hurtDuration:Number = 1000;
		
		/**
		 * The amount of kick-back that the hero jumps when he gets hurt. 
		 */
		[Inspectable(defaultValue="180")]
		public var hurtVelocityX:Number = 180;
		
		/**
		 * The amount of kick-back that the hero jumps when he gets hurt. 
		 */
		[Inspectable(defaultValue="300")]
		public var hurtVelocityY:Number = 300;
		
		/**
		 * Determines whether or not the hero's ducking ability is enabled.
		 */
		[Inspectable(defaultValue="true")]
		public var canDuck:Boolean = true;
		
		/**
		 * Defines which input Channel to listen to.
		 */
		[Inspectable(defaultValue = "0")]
		public var inputChannel:uint = 0;

		// events
		/**
		 * Dispatched whenever the hero jumps. 
		 */
		public var onJump:Signal;

		/**
		 * Dispatched whenever the hero gives damage to an enemy. 
		 */
		public var onGiveDamage:Signal;

		/**
		 * Dispatched whenever the hero takes damage from an enemy. 
		 */
		public var onTakeDamage:Signal;

		/**
		 * Dispatched whenever the hero's animation changes. 
		 */
		public var onAnimationChange:Signal;

		protected var _groundContacts:Array = [];// Used to determine if he's on ground or not.
		protected var _enemyClass:Class = Enemy;
		protected var _onGround:Boolean = false;
		protected var _springOffEnemy:Number = -1;
		protected var _hurtTimeoutID:Number;
		protected var _hurt:Boolean = false;
		protected var _dynamicFriction:Number = 0.77;
		protected var _playerMovingHero:Boolean = false;
		protected var _controlsEnabled:Boolean = true;
		protected var _ducking:Boolean = false;
		protected var _combinedGroundAngle:Number = 0;

		public function Hero(name:String, params:Object = null) {

			super(name, params);

			onJump = new Signal();
			onGiveDamage = new Signal();
			onTakeDamage = new Signal();
			onAnimationChange = new Signal();
		}
		
		override protected function createConstraint():void {
			
			super.createConstraint();
			
			_body.cbTypes.add(HERO);
		}

		override public function destroy():void {
			
			clearTimeout(_hurtTimeoutID);
			onJump.removeAll();
			onGiveDamage.removeAll();
			onTakeDamage.removeAll();
			onAnimationChange.removeAll();
			
			super.destroy();
		}

		/**
		 * Whether or not the player can move and jump with the hero. 
		 */
		public function get controlsEnabled():Boolean {
			return _controlsEnabled;
		}

		public function set controlsEnabled(value:Boolean):void {
			_controlsEnabled = value;

			 if (!_controlsEnabled)
			 	_material.dynamicFriction = _dynamicFriction;
		}

		/**
		 * Returns true if the hero is on the ground and can jump. 
		 */
		public function get onGround():Boolean {
			return _onGround;
		}

		/**
		 * The Hero uses the enemyClass parameter to know who he can kill (and who can kill him).
		 * Use this setter to to pass in which base class the hero's enemy should be, in String form
		 * or Object notation.
		 * For example, if you want to set the "Enemy" class as your hero's enemy, pass
		 * "citrus.objects.platformer.Enemy", or Enemy (with no quotes). Only String
		 * form will work when creating objects via a level editor.
		 */
		[Inspectable(defaultValue="citrus.objects.platformer.nape.Enemy",type="String")]
		public function set enemyClass(value:*):void {
			
			if (value is String)
			_enemyClass = getDefinitionByName(value as String) as Class;
			else if (value is Class)
			_enemyClass = value;
		}
		
		/**
		 * This is the amount of friction that the hero will have. Its value is multiplied against the
		 * friction value of other physics objects.
		 */	
		public function get dynamicFriction():Number {
			return _dynamicFriction;
		}
		
		[Inspectable(defaultValue="1.7")]
		public function set dynamicFriction(value:Number):void {
			
			_material.dynamicFriction = _dynamicFriction = value;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			var velocity:Vec2 = _body.velocity;
			
			if (controlsEnabled)
			{
				var moveKeyPressed:Boolean = false;
				
				_ducking = (_ce.input.isDoing("duck", inputChannel) && _onGround && canDuck);
				
				if (_ce.input.isDoing("right", inputChannel)  && !_ducking)
				{
					//velocity.addeq(getSlopeBasedMoveAngle());
					velocity.x += acceleration;
					moveKeyPressed = true;
				}
				
				if (_ce.input.isDoing("left", inputChannel) && !_ducking)
				{
					//velocity.subeq(getSlopeBasedMoveAngle());
					velocity.x -= acceleration;
					moveKeyPressed = true;
				}
				
				//If player just started moving the hero this tick.
				if (moveKeyPressed && !_playerMovingHero)
				{
					_playerMovingHero = true;
					_material.dynamicFriction = 0; //Take away friction so he can accelerate.
				}
				//Player just stopped moving the hero this tick.
				else if (!moveKeyPressed && _playerMovingHero)
				{
					_playerMovingHero = false;
					_material.dynamicFriction = _dynamicFriction; //Add friction so that he stops running
				}
				
				if (_onGround && _ce.input.justDid("jump", inputChannel) && !_ducking)
				{
					velocity.y = -jumpHeight;
					onJump.dispatch();
				}
				
				if (_ce.input.isDoing("jump", inputChannel) && !_onGround && velocity.y < 0)
				{
					velocity.y -= jumpAcceleration;
				}
				
				if (_springOffEnemy != -1)
				{
					if (_ce.input.isDoing("jump", inputChannel))
						velocity.y = -enemySpringJumpHeight;
					else
						velocity.y = -enemySpringHeight;
					_springOffEnemy = -1;
				}
				
				//Cap velocities
				if (velocity.x > (maxVelocity))
					velocity.x = maxVelocity;
				else if (velocity.x < (-maxVelocity))
					velocity.x = -maxVelocity;
				
				//update physics with new velocity
				_body.velocity = velocity;
			}
			
			updateAnimation();
		}
		
		protected function getSlopeBasedMoveAngle():Vec2 {
			
			return new Vec2(acceleration, 0);
			//return new Vec2(acceleration, 0).rotate(_combinedGroundAngle);
		}
		
		/**
		 * Hurts the hero, disables his controls for a little bit, and dispatches the onTakeDamage signal. 
		 */		
		public function hurt():void
		{
			_hurt = true;
			controlsEnabled = false;
			_hurtTimeoutID = setTimeout(endHurtState, hurtDuration);
			onTakeDamage.dispatch();
			
			//Makes sure that the hero is not frictionless while his control is disabled
			if (_playerMovingHero)
			{
				_playerMovingHero = false;
				_material.dynamicFriction = _dynamicFriction;
			}
		}
		
		override protected function createBody():void {
			
			super.createBody();
			
			_body.allowRotation = false;
		}
		
		override protected function createMaterial():void {
			
			super.createMaterial();
			
			_material.elasticity = 0;
		}
		
		override protected function createFilter():void {
			
			_body.setShapeFilters(new InteractionFilter(PhysicsCollisionCategories.Get("GoodGuys"), PhysicsCollisionCategories.GetAll()));
		}
		
		override public function handleBeginContact(callback:InteractionCallback):void {
			
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
			
			if (_enemyClass && collider is _enemyClass)
			{
				if ((_body.velocity.y == 0 || _body.velocity.y < killVelocity) && !_hurt)
				{
					hurt();
					
					//fling the hero
					var hurtVelocity:Vec2 = _body.velocity;
					hurtVelocity.y = -hurtVelocityY;
					hurtVelocity.x = hurtVelocityX;
					if (collider.x > x)
						hurtVelocity.x = -hurtVelocityX;
					_body.velocity = hurtVelocity;
				}
				else
				{
					_springOffEnemy = collider.y - height;
					onGiveDamage.dispatch();
				}
			}
			
			if (callback.arbiters.length > 0 && callback.arbiters.at(0).collisionArbiter) {
				
				var collisionAngle:Number = callback.arbiters.at(0).collisionArbiter.normal.angle * 180 / Math.PI;
				
				if ((collisionAngle > 45 && collisionAngle < 135) || (collisionAngle > -30 && collisionAngle < 10 && collisionAngle != 0) || collisionAngle == -90)
				{
					//we don't want the Hero to be set up as onGround if it touches a cloud.
					if (collider is Platform && (collider as Platform).oneWay && collisionAngle == -90)
						return;
					
					_groundContacts.push(collider.body);
					_onGround = true;
					//updateCombinedGroundAngle();
				}
			}
		}
		
		override public function handleEndContact(callback:InteractionCallback):void {
			
			var collider:NapePhysicsObject = NapeUtils.CollisionGetOther(this, callback);
			
			//Remove from ground contacts, if it is one.
			var index:int = _groundContacts.indexOf(collider.body);
			if (index != -1)
			{
				_groundContacts.splice(index, 1);
				if (_groundContacts.length == 0)
					_onGround = false;
				//updateCombinedGroundAngle();
			}
		}
		
		protected function endHurtState():void {
			
			_hurt = false;
			controlsEnabled = true;
		}
		
		protected function updateAnimation():void {
			
			var prevAnimation:String = _animation;
			
			//var walkingSpeed:Number = getWalkingSpeed();
			var walkingSpeed:Number = _body.velocity.x; // this won't work long term!
			
			if (_hurt)
				_animation = "hurt";
				
			else if (!_onGround) {
				
				_animation = "jump";
				
				if (walkingSpeed < -acceleration)
					_inverted = true;
				else if (walkingSpeed > acceleration)
					_inverted = false;
				
			} else if (_ducking)
				_animation = "duck";
				
			else {
				
				if (walkingSpeed < -acceleration) {
					_inverted = true;
					_animation = "walk";
					
				} else if (walkingSpeed > acceleration) {
					
					_inverted = false;
					_animation = "walk";
					
				} else
					_animation = "idle";
			}
			
			if (prevAnimation != _animation)
				onAnimationChange.dispatch();

		}
	}
}
