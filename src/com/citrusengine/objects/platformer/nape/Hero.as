package com.citrusengine.objects.platformer.nape {

	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.callbacks.CbEvent;
	import nape.geom.Vec2;
	import nape.phys.Body;

	import com.citrusengine.objects.NapePhysicsObject;

	import org.osflash.signals.Signal;

	import flash.ui.Keyboard;
	import flash.utils.getDefinitionByName;

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
		 * Determines whether or not the hero's ducking ability is enabled.
		 */
		[Inspectable(defaultValue="true")]
		public var canDuck:Boolean = true;

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
		protected var _friction:Number = 0.75;
		protected var _playerMovingHero:Boolean = false;
		protected var _controlsEnabled:Boolean = true;
		protected var _ducking:Boolean = false;
		protected var _combinedGroundAngle:Number = 0;
		
		// interaction listeners
		private var _beginContactListener:InteractionListener;
		private var _endContactListener:InteractionListener;
		
		public static const HERO:CbType = new CbType();		

		public function Hero(name:String, params:Object = null) {

			super(name, params);

			onJump = new Signal();
			onGiveDamage = new Signal();
			onTakeDamage = new Signal();
			onAnimationChange = new Signal();
		}
		
		override protected function createConstraint():void {
			
			super.createConstraint();
			
			_beginContactListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, HERO, CbType.ANY_BODY, handleBeginContact);
			_endContactListener = new InteractionListener(CbEvent.END, InteractionType.COLLISION, HERO, CbType.ANY_BODY, handleEndContact);
			_body.cbTypes.add(HERO);
			_body.space.listeners.add(_beginContactListener);
			_body.space.listeners.add(_endContactListener);
		}

		override public function destroy():void {

			onJump.removeAll();
			onGiveDamage.removeAll();
			onTakeDamage.removeAll();
			onAnimationChange.removeAll();
			
			if (_beginContactListener) {
				_beginContactListener.space = null;
				_beginContactListener = null;
			}
			
			if (_endContactListener) {
				_endContactListener.space = null;
				_endContactListener = null;
			}

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

			// if (!_controlsEnabled)
			// _fixture.SetFriction(_friction);
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
		 * "com.citrusengine.objects.platformer.Enemy", or Enemy (with no quotes). Only String
		 * form will work when creating objects via a level editor.
		 */
		[Inspectable(defaultValue="com.citrusengine.objects.platformer.nape.Enemy",type="String")]
		public function set enemyClass(value:*):void {
			
			if (value is String)
			_enemyClass = getDefinitionByName(value as String) as Class;
			else if (value is Class)
			_enemyClass = value;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			var velocity:Vec2 = _body.velocity;
			
			if (controlsEnabled)
			{
				var moveKeyPressed:Boolean = false;
				
				_ducking = (_ce.input.isDown(Keyboard.DOWN) && _onGround && canDuck);
				
				if (_ce.input.isDown(Keyboard.RIGHT)  && !_ducking)
				{
					//velocity.addeq(getSlopeBasedMoveAngle());
					velocity.x += acceleration;
					moveKeyPressed = true;
				}
				
				if (_ce.input.isDown(Keyboard.LEFT) && !_ducking)
				{
					//velocity.subeq(getSlopeBasedMoveAngle());
					velocity.x -= acceleration;
					moveKeyPressed = true;
				}
				
				//If player just started moving the hero this tick.
				if (moveKeyPressed && !_playerMovingHero)
				{
					_playerMovingHero = true;
					//_fixture.SetFriction(0); //Take away friction so he can accelerate.
				}
				//Player just stopped moving the hero this tick.
				else if (!moveKeyPressed && _playerMovingHero)
				{
					_playerMovingHero = false;
					//_fixture.SetFriction(_friction); //Add friction so that he stops running
				}
				
				//
				if (_ce.input.justPressed(Keyboard.SPACE) && _onGround && !_ducking)
				{
					velocity.y = -jumpHeight;
					_onGround = false;
					onJump.dispatch();
				}
				
				//
				if (_ce.input.isDown(Keyboard.SPACE) && !_onGround && velocity.y < 0)
				{
					velocity.y -= jumpAcceleration;
				}
				
				/*if (_springOffEnemy != -1)
				{
					if (_ce.input.isDown(Keyboard.SPACE))
						velocity.y = -enemySpringJumpHeight;
					else
						velocity.y = -enemySpringHeight;
					_springOffEnemy = -1;
				}*/
				
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
		
		override protected function createBody():void {
			
			super.createBody();
			
			_body.allowRotation = false;
		}
		
		
		override public function handleBeginContact(e:InteractionCallback):void {
			
			//trace("------------------------------");
			//trace("begin contact:", e.int2.castBody.userData.myData);
			var body2:Body = e.int2.castBody;
			_groundContacts.push(body2);
			//trace("ground contacts:", _groundContacts.length);
			
			if (e.arbiters.length > 0 && e.arbiters.at(0).collisionArbiter) {
				var angle:Number = e.arbiters.at(0).collisionArbiter.normal.angle * 180 / Math.PI;
				if ((45 < angle) && (angle < 135)) {
					_onGround = true;
				}
			}
		}
		
		override public function handleEndContact(e:InteractionCallback):void {
			//trace("****************************");
			//trace("end contact:", e.int2.castBody.userData.myData);
			_groundContacts.splice(_groundContacts.indexOf(e.int2.castBody), 1);
			//trace("ground contacts:", _groundContacts.length);
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
