package com.citrusengine.objects.platformer.box2d 
{

	import Box2DAS.Dynamics.ContactEvent;
	import Box2DAS.Dynamics.b2Body;

	import com.citrusengine.math.MathVector;
	import com.citrusengine.objects.Box2DPhysicsObject;

	import org.osflash.signals.Signal;

	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;
	
	/**
	 * The RewardBox is a special type of platform that you can "bump" to make a reward come out. It is meant to be similar
	 * to those "question blocks" or "mystery blocks" in mario.
	 * 
	 * Params: 
	 * - You can set the <code>rewardClass</code> value to specify what kind of reward to have the box create. The reward class object
	 * that is generated must extend the "Reward" class.
	 * 
	 * This means that you must also create a class that extends <code>Reward<code> for every reward type that you want in your game.
	 * If you were making a mario clone, you would make a FireFlowerReward. This is where you would specify the reward's graphics,
	 * its initial impulse out of the box, and any custom code such as unique movement or a death timer.
	 * 
	 * - You can specify the "collision normal" angle that you must come at it in order for it to generate a reward. The default is 90,
	 * which is "from below", as long as the box is not rotated.
	 * 
	 * Animations:
	 * Your Reward box should have a "normal" and "used" animation state. Once the box's reward has been obtained, it cannot be used again.
	 * 
	 * Events:
	 * The RewardBox has two Signals. The first event is <code>onUse</code>, which gets dispatched when the reward box gets bumped.
	 * It passes a reference of itself.
	 * 
	 * The Second event is <code>onRewardCollect</code>, which gets dispatched when the reward is collected. This is where you would
	 * write the code to grant your player the reward (such as a greater jump height, more points, or another life).
	 * 
	 * Other: 
	 * If you don't want the reward box to generate a reward, (or you want the reward to be granted immediately, like points),
	 * you can set the rewardClass to null and just listen for the "onUse" event to grant the player the reward.
	 */
	public class RewardBox extends Box2DPhysicsObject 
	{
		/**
		 * This is the vector normal that the reward box must be collided with in order for the reward to be created.
		 * On a box with no rotation, 90 is "from below", 0 is "from the right", -180 is "from the left", and -90 is "from above".
		 */
		[Property(value="90")]
		public var collisionAngle:Number = 90;
		
		/**
		 * Dispatched when the box gets "bumped" or used.
		 */
		public var onUse:Signal;
		
		/**
		 * Dispatched when the reward that came out of the box is collected by the player.
		 */
		public var onRewardCollect:Signal;
		
		private var _rewardClass:Class = Reward;
		private var _isUsed:Boolean = false;
		private var _createReward:Boolean = false;
		
		public static function Make(name:String, x:Number, y:Number, width:Number, height:Number, rewardClass:*, view:* = null):RewardBox
		{
			if (view == null) view = MovieClip;
			return new RewardBox(name, {x: x, y: y, width: width, height: height, rewardClass: rewardClass, view: view} );
		}
		
		public function RewardBox(name:String, params:Object = null) 
		{
			super(name, params);
			onUse = new Signal(RewardBox);
			onRewardCollect = new Signal(RewardBox, Reward);
		}
		
		override public function destroy():void
		{
			_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
			onUse.removeAll();
			onRewardCollect.removeAll();
			
			super.destroy();
		}
		
		override public function get animation():String
		{
			if (_isUsed)
			{
				return "used";
			}
			return "normal";
		}
		
		/**
		 * Specify the class of the object that you want the reward box to generate. The class must extend Reward in order to be valid.
		 * You can specify the rewardClass in String form (rewardClass = "com.myGame.FireballReward") or via direct reference 
		 * (rewardClass = FireballReward). You should use the String form when creating RewardBoxes in an external level editor. Make sure and
		 * specify the entire classpath.
		 */
		public function get rewardClass():*
		{
			return _rewardClass;
		}
		
		[Property(value="")]
		public function set rewardClass(value:*):void
		{
			if (value is String)
				_rewardClass = getDefinitionByName(value) as Class;
			else if (value is Class)
				_rewardClass = value;
			else
				_rewardClass = null;
		}
		
		public function get isUsed():Boolean
		{
			return _isUsed;
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			if (_createReward)
			{
				_createReward = false;
				
				//You can make the rewardClass property null if you just want to listen for the bump event and not have it generate a reward.
				if (_rewardClass)
				{
					var rewardObject:Reward = new _rewardClass(name + "Reward");
					rewardObject.onCollect.addOnce(handleRewardCollected);
					rewardObject.x = x;
					rewardObject.y = y - ((height / 2) + (rewardObject.height / 2) + 1);
					_ce.state.add(rewardObject);
				}
				
				onUse.dispatch(this);
				_isUsed = true;
			}
		}
		
		override protected function defineBody():void
		{
			super.defineBody();
			_bodyDef.type = b2Body.b2_staticBody;
		}
		
		override protected function defineFixture():void
		{
			super.defineFixture();
			_fixtureDef.restitution = 0;
		}
		
		override protected function createFixture():void
		{
			super.createFixture();
			
			_fixture.m_reportBeginContact = true;
			_fixture.addEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
		}
		
		protected function handleBeginContact(e:ContactEvent):void
		{
			if (e.normal)
			{
				var collisionAngle:Number = new MathVector(e.normal.x, e.normal.y).angle * 180 / Math.PI;
				if (collisionAngle == 90)
				{
					_fixture.m_reportBeginContact = false;
					_fixture.removeEventListener(ContactEvent.BEGIN_CONTACT, handleBeginContact);
					_createReward = true;
				}
			}
		}
		
		private function handleRewardCollected(reward:Reward):void 
		{
			onRewardCollect.dispatch(this, reward);
		}
	}

}