package com.citrusengine.objects.platformer.box2d
{

	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.ContactEvent;
	import Box2DAS.Dynamics.b2Fixture;

	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.Box2DPhysicsObject;
	import com.citrusengine.physics.PhysicsCollisionCategories;
	import com.citrusengine.utils.Box2DShapeMaker;

	import org.osflash.signals.Signal;

	import flash.display.MovieClip;
	import flash.ui.Keyboard;
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
	public class Hero extends Box2DPhysicsObject
	{
		//properties
		/**
		 * This is the rate at which the hero speeds up when you move him left and right. 
		 */
		[Inspectable(defaultValue="1")]
		public var acceleration:Number = 1;
		
		/**
		 * This is the fastest speed that the hero can move left or right. 
		 */
		[Inspectable(defaultValue="8")]
		public var maxVelocity:Number = 8;
		
		/**
		 * This is the initial velocity that the hero will move at when he jumps.
		 */
		[Inspectable(defaultValue="11")]
		public var jumpHeight:Number = 11;
		
		/**
		 * This is the amount of "float" that the hero has when the player holds the jump button while jumping. 
		 */
		[Inspectable(defaultValue="0.3")]
		public var jumpAcceleration:Number = 0.3;
		
		/**
		 * This is the y velocity that the hero must be travelling in order to kill a Baddy.
		 */
		[Inspectable(defaultValue="3")]
		public var killVelocity:Number = 3;
		
		/**
		 * The y velocity that the hero will spring when he kills an enemy. 
		 */
		[Inspectable(defaultValue="8")]
		public var enemySpringHeight:Number = 8;
		
		/**
		 * The y velocity that the hero will spring when he kills an enemy while pressing the jump button. 
		 */
		[Inspectable(defaultValue="9")]
		public var enemySpringJumpHeight:Number = 9;
		
		/**
		 * How long the hero is in hurt mode for. 
		 */
		[Inspectable(defaultValue="1000")]
		public var hurtDuration:Number = 1000;
		
		/**
		 * The amount of kick-back that the hero jumps when he gets hurt. 
		 */
		[Inspectable(defaultValue="6")]
		public var hurtVelocityX:Number = 6;
		
		/**
		 * The amount of kick-back that the hero jumps when he gets hurt. 
		 */
		[Inspectable(defaultValue="10")]
		public var hurtVelocityY:Number = 10;
		
		/**
		 * Determines whether or not the hero's ducking ability is enabled.
		 */
		[Inspectable(defaultValue="true")]
		public var canDuck:Boolean = true;
		
		//events
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
		
		protected var _groundContacts:Array = [];//Used to determine if he's on ground or not.
		protected var _enemyClass:Class = Baddy;
		protected var _onGround:Boolean = false;
		protected var _springOffEnemy:Number = -1;
		protected var _hurtTimeoutID:Number;
		protected var _hurt:Boolean = false;
		protected var _friction:Number = 0.75;
		protected var _playerMovingHero:Boolean = false;
		protected var _controlsEnabled:Boolean = true;
		protected var _ducking:Boolean = false;
		protected var _combinedGroundAngle:Number = 0;
		
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, view:* = null):Hero
		{
			if (view == null) view = MovieClip;
			return new Hero(name, { x: x, y: y, width: width, height: height, view: view } );
		}
		
		/**
		 * Creates a new hero object.
		 */		
		public function Hero(name:String, params:Object = null)
		{
			super(name, params);
			
			onJump = new Signal();
			onGiveDamage = new Signal();
			onTakeDamage = new Signal();
			onAnimationChange = new Signal();
		}
		
		override public function destroy():void
		{
			_fixture.removeEventListener(ContactEvent.PRE_SOLVE, handlePreSolve);
			_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			_fixture.removeEventListener(ContactEvent.END_CONTACT, handleEndContact);
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
		public function get controlsEnabled():Boolean
		{
			return _controlsEnabled;
		}
		
		public function set controlsEnabled(value:Boolean):void
		{
			_controlsEnabled = value;
			
			if (!_controlsEnabled)
				_fixture.SetFriction(_friction);
		}
		
		/**
		 * Returns true if the hero is on the ground and can jump. 
		 */		
		public function get onGround():Boolean
		{
			return _onGround;
		}
		
		/**
		 * The Hero uses the enemyClass parameter to know who he can kill (and who can kill him).
		 * Use this setter to to pass in which base class the hero's enemy should be, in String form
		 * or Object notation.
		 * For example, if you want to set the "Baddy" class as your hero's enemy, pass
		 * "com.citrusengine.objects.platformer.Baddy", or Baddy (with no quotes). Only String
		 * form will work when creating objects via a level editor.
		 */
		[Inspectable(defaultValue="com.citrusengine.objects.platformer.box2d.Baddy",type="String")]
		public function set enemyClass(value:*):void
		{
			if (value is String)
				_enemyClass = getDefinitionByName(value as String) as Class;
			else if (value is Class)
				_enemyClass = value;
		}
		
		/**
		 * This is the amount of friction that the hero will have. Its value is multiplied against the
		 * friction value of other physics objects.
		 */	
		public function get friction():Number
		{
			return _friction;
		}
		
		[Inspectable(defaultValue="0.75")]
		public function set friction(value:Number):void
		{
			_friction = value;
			
			if (_fixture)
			{
				_fixture.SetFriction(_friction);
			}
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			var velocity:V2 = _body.GetLinearVelocity();
			
			if (controlsEnabled)
			{
				var moveKeyPressed:Boolean = false;
				
				_ducking = (_ce.input.isDown(Keyboard.DOWN) && _onGround && canDuck);
				
				if (_ce.input.isDown(Keyboard.RIGHT) && !_ducking)
				{
					velocity = V2.add(velocity, getSlopeBasedMoveAngle());
					moveKeyPressed = true;
				}
				
				if (_ce.input.isDown(Keyboard.LEFT) && !_ducking)
				{
					velocity = V2.subtract(velocity, getSlopeBasedMoveAngle());
					moveKeyPressed = true;
				}
				
				//If player just started moving the hero this tick.
				if (moveKeyPressed && !_playerMovingHero)
				{
					_playerMovingHero = true;
					_fixture.SetFriction(0); //Take away friction so he can accelerate.
				}
				//Player just stopped moving the hero this tick.
				else if (!moveKeyPressed && _playerMovingHero)
				{
					_playerMovingHero = false;
					_fixture.SetFriction(_friction); //Add friction so that he stops running
				}
				
				if (_onGround && _ce.input.justPressed(Keyboard.SPACE) && !_ducking)
				{
					velocity.y = -jumpHeight;
					onJump.dispatch();
				}
				
				if (_ce.input.isDown(Keyboard.SPACE) && !_onGround && velocity.y < 0)
				{
					velocity.y -= jumpAcceleration;
				}
				
				if (_springOffEnemy != -1)
				{
					if (_ce.input.isDown(Keyboard.SPACE))
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
				_body.SetLinearVelocity(velocity);
			}
			
			updateAnimation();
		}
		
		/**
		 * Returns the absolute walking speed, taking moving platforms into account.
		 * Isn't super performance-light, so use sparingly.
		 */
		public function getWalkingSpeed():Number
		{
			var groundVelocityX:Number = 0;
			for each (var groundContact:b2Fixture in _groundContacts)
			{
				groundVelocityX += groundContact.GetBody().GetLinearVelocity().x;
			}
			
			return _body.GetLinearVelocity().x - groundVelocityX;
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
				_fixture.SetFriction(_friction);
			}
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			_bodyDef.fixedRotation = true;
			_bodyDef.allowSleep = false;
		}
		
		override protected function createShape():void
		{
			_shape = Box2DShapeMaker.BeveledRect(_width, _height, 0.1);
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.friction = _friction;
			_fixtureDef.restitution = 0;
			_fixtureDef.filter.categoryBits = PhysicsCollisionCategories.Get("GoodGuys");
			_fixtureDef.filter.maskBits = PhysicsCollisionCategories.GetAll();
		}
		
		override protected function createFixture():void
		{
			super.createFixture();
			_fixture.m_reportPreSolve = true;
			_fixture.m_reportBeginContact = true;
			_fixture.m_reportEndContact = true;
			_fixture.addEventListener(ContactEvent.PRE_SOLVE, handlePreSolve);
			_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			_fixture.addEventListener(ContactEvent.END_CONTACT, handleEndContact);
		}
		
		protected function handlePreSolve(e:ContactEvent):void 
		{
			if (!_ducking)
				return;
				
			var other:Box2DPhysicsObject = e.other.GetBody().GetUserData() as Box2DPhysicsObject;
			
			var heroTop:Number = y;
			var objectBottom:Number = other.y + (other.height / 2);
			
			if (objectBottom < heroTop)
				e.contact.Disable();
		}
		
		protected function handleBeginContact(e:ContactEvent):void
		{
			var collider:Box2DPhysicsObject = e.other.GetBody().GetUserData();
			
			if (_enemyClass && collider is _enemyClass)
			{
				if (_body.GetLinearVelocity().y < killVelocity && !_hurt)
				{
					hurt();
					
					//fling the hero
					var hurtVelocity:V2 = _body.GetLinearVelocity();
					hurtVelocity.y = -hurtVelocityY;
					hurtVelocity.x = hurtVelocityX;
					if (collider.x > x)
						hurtVelocity.x = -hurtVelocityX;
					_body.SetLinearVelocity(hurtVelocity);
				}
				else
				{
					_springOffEnemy = collider.y - height;
					onGiveDamage.dispatch();
				}
			}
			
			
			//Collision angle
			if (e.normal) //The normal property doesn't come through all the time. I think doesn't come through against sensors.
			{
				var collisionAngle:Number = new MathVector(e.normal.x, e.normal.y).angle * 180 / Math.PI;
				if ((collisionAngle > 45 && collisionAngle < 135) || e.other.GetBody().GetUserData() is Crate)
				{
					_groundContacts.push(e.other);
					_onGround = true;
					updateCombinedGroundAngle();
				}
			}
		}
		
		protected function handleEndContact(e:ContactEvent):void
		{
			//Remove from ground contacts, if it is one.
			var index:int = _groundContacts.indexOf(e.other);
			if (index != -1)
			{
				_groundContacts.splice(index, 1);
				if (_groundContacts.length == 0)
					_onGround = false;
				updateCombinedGroundAngle();
			}
		}
		
		protected function getSlopeBasedMoveAngle():V2
		{
			return new V2(acceleration, 0).rotate(_combinedGroundAngle);
		}
		
		protected function updateCombinedGroundAngle():void
		{
			_combinedGroundAngle = 0;
			
			if (_groundContacts.length == 0)
				return;
			
			for each (var contact:b2Fixture in _groundContacts)
				var angle:Number = contact.GetBody().GetAngle();
				
			var turn:Number = 45 * Math.PI / 180;
			angle = angle % turn;
			_combinedGroundAngle += angle;
			_combinedGroundAngle /= _groundContacts.length;
		}
		
		protected function endHurtState():void
		{
			_hurt = false;
			controlsEnabled = true;
		}
		
		protected function updateAnimation():void
		{
			var prevAnimation:String = _animation;
			
			if (_hurt)
			{
				_animation = "hurt";
			}
			else if (!_onGround)
			{
				_animation = "jump";
			}
			else if (_ducking)
			{
				_animation = "duck";
			}
			else
			{
				var walkingSpeed:Number = getWalkingSpeed();
				if (walkingSpeed < -acceleration)
				{
					_inverted = true;
					_animation = "walk";
				}
				else if (walkingSpeed > acceleration)
				{
					_inverted = false;
					_animation = "walk";
				}
				else
				{
					_animation = "idle";
				}
			}
			
			if (prevAnimation != _animation)
			{
				onAnimationChange.dispatch();
			}
		}
	}
}