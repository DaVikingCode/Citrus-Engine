package dragonBones.animation
{
	
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.events.AnimationEvent;
	import dragonBones.events.FrameEvent;
	import dragonBones.events.SoundEvent;
	import dragonBones.events.SoundEventManager;
	import dragonBones.objects.AnimationData;
	import dragonBones.objects.MovementBoneData;
	import dragonBones.objects.MovementData;
	import dragonBones.objects.MovementFrameData;
	import dragonBones.utils.dragonBones_internal;
	
	use namespace dragonBones_internal;
	
	/**
	 * A core object that can control the state of an armature
	 * @see dragonBones.Armature
	 */
	final public class Animation extends ProcessBase
	{
		private static var _soundManager:SoundEventManager = SoundEventManager.getInstance();
		
		/**
		 * The playing movement ID.
		 */
		public var movementID:String;
		
		/**
		 * An vector containing all movements the animation can play.
		 */
		public var movementList:Vector.<String>;
		
		private var _animationData:AnimationData;
		private var _movementData:MovementData;
		private var _currentFrameData:MovementFrameData;
		
		private var _armature:Armature;
		
		/**
		 * @inheritDoc
		 */
		override public function set timeScale(value:Number):void
		{
			super.timeScale = value;
			for each(var bone:Bone in _armature._boneDepthList)
			{
				bone._tween.timeScale = value;
			}
		}
		
		/**
		 * Creates a new <code>Animation</code>
		 * @param	armature
		 */
		public function Animation(armature:Armature)
		{
			_armature = armature;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			movementList = null;
			_animationData = null;
			_movementData = null;
			_currentFrameData  = null;
			_armature = null;
		}
		/** @private */
		public function setData(animationData:AnimationData):void
		{
			if (animationData)
			{
				stop();
				_animationData = animationData;
				
				movementList = _animationData.movementList;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function gotoAndPlay(movementID:Object, durationTo:int = -1, durationTween:int = -1, loop:* = null, tweenEasing:Number = NaN):void
		{
			if (!_animationData)
			{
				return;
			}
			var movementData:MovementData = _animationData.getMovementData(movementID as String);
			if (!movementData)
			{
				return;
			}
			_currentFrameData = null;
			_toIndex = 0;
			_movementData = movementData;
			var exMovementID:String = this.movementID;
			this.movementID = movementID as String;
			
			durationTo = durationTo < 0?_movementData.durationTo:durationTo;
			durationTween = durationTween < 0?_movementData.durationTween:durationTween;
			loop = loop === null?_movementData.loop:loop;
			tweenEasing = isNaN(tweenEasing)?_movementData.tweenEasing:tweenEasing;
			
			super.gotoAndPlay(null, durationTo, durationTween);
			
			_duration = _movementData.duration;
			if (_duration == 1)
			{
				_loop = SINGLE;
			}
			else
			{
				if (loop)
				{
					_loop = LIST_LOOP_START
				}
				else
				{
					_loop = LIST_START
					_duration --;
				}
				_durationTween = durationTween;
			}
			
			for each(var bone:Bone in _armature._boneDepthList)
			{
				var movementBoneData:MovementBoneData = _movementData.getMovementBoneData(bone.name);
				if (movementBoneData)
				{
					bone._tween.gotoAndPlay(movementBoneData, durationTo, durationTween, loop, tweenEasing);
					if(bone.childArmature)
					{
						bone.childArmature.animation.gotoAndPlay(movementID);
					}
				}
				else if(bone.origin.name)
				{
					bone.changeDisplay(-1);
					bone._tween.stop();
				}
			}
			
			if(_armature.hasEventListener(AnimationEvent.MOVEMENT_CHANGE))
			{
				var event:AnimationEvent = new AnimationEvent(AnimationEvent.MOVEMENT_CHANGE);
				event.exMovementID = exMovementID;
				event.movementID = this.movementID;
				_armature.dispatchEvent(event);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function play():void
		{
			if (!_animationData)
			{
				return;
			}
			
			if(!movementID)
			{
				gotoAndPlay(movementList[0]);
				return;
			}
			
			if(_isPause)
			{
				super.play();
				for each(var bone:Bone in _armature._boneDepthList)
				{
					bone._tween.play();
				}
			}
			else if(_isComplete)
			{
				gotoAndPlay(movementID);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{
			super.stop();
			for each(var bone:Bone in _armature._boneDepthList)
			{
				bone._tween.stop();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateHandler():void
		{
			var event:AnimationEvent;
			if (_currentPrecent >= 1)
			{
				switch(_loop)
				{
					case LIST_START:
						_loop = LIST;
						_currentPrecent = (_currentPrecent - 1) * _totalFrames / _durationTween;
						if (_currentPrecent >= 1)
						{
							//the speed of playing is too fast or the durationTween is too short
						}
						else
						{
							_totalFrames = _durationTween;
							if(_armature.hasEventListener(AnimationEvent.START))
							{
								event = new AnimationEvent(AnimationEvent.START);
								event.movementID = movementID;
								_armature.dispatchEvent(event);
							}
							break;
						}
					case LIST:
					case SINGLE:
						_currentPrecent = 1;
						_isComplete = true;
						if(_armature.hasEventListener(AnimationEvent.COMPLETE))
						{
							event = new AnimationEvent(AnimationEvent.COMPLETE);
							event.movementID = movementID;
							_armature.dispatchEvent(event);
						}
						break;
					case LIST_LOOP_START:
						_loop = 0;
						_totalFrames = _durationTween > 0?_durationTween:1;
						_currentPrecent %= 1;
						if(_armature.hasEventListener(AnimationEvent.START))
						{
							event = new AnimationEvent(AnimationEvent.START);
							event.movementID = movementID;
							_armature.dispatchEvent(event);
						}
						break;
					default:
						//change the loop
						_loop += int(_currentPrecent);
						_currentPrecent %= 1;
						_toIndex = 0;
						if(_armature.hasEventListener(AnimationEvent.LOOP_COMPLETE))
						{
							event = new AnimationEvent(AnimationEvent.LOOP_COMPLETE);
							event.movementID = movementID;
							_armature.dispatchEvent(event);
						}
						break;
				}
			}
			if (_loop >= LIST)
			{
				updateFrameData(_currentPrecent);
			}
		}
		
		private function updateFrameData(currentPrecent:Number):void
		{
			var length:uint = _movementData._movementFrameList.length;
			if(length == 0)
			{
				return;
			}
			var played:Number = _duration * currentPrecent;
			//refind the current frame
			if (!_currentFrameData || played >= _currentFrameData.duration + _currentFrameData.start || played < _currentFrameData.start)
			{
				while (true)
				{
					_currentFrameData =  _movementData._movementFrameList[_toIndex];
					if (++_toIndex >= length)
					{
						_toIndex = 0;
					}
					if(_currentFrameData && played >= _currentFrameData.start && played < _currentFrameData.duration + _currentFrameData.start)
					{
						break;
					}
				}
				if(_currentFrameData.event && _armature.hasEventListener(FrameEvent.MOVEMENT_FRAME_EVENT))
				{
					var frameEvent:FrameEvent = new FrameEvent(FrameEvent.MOVEMENT_FRAME_EVENT);
					frameEvent.movementID = movementID;
					frameEvent.frameLabel = _currentFrameData.event;
					_armature.dispatchEvent(frameEvent);
				}
				if(_currentFrameData.sound && _soundManager.hasEventListener(SoundEvent.SOUND))
				{
					var soundEvent:SoundEvent = new SoundEvent(SoundEvent.SOUND);
					soundEvent.movementID = movementID;
					soundEvent.sound = _currentFrameData.sound;
					soundEvent._armature = _armature;
					_soundManager.dispatchEvent(soundEvent);
				}
				if(_currentFrameData.movement)
				{
					gotoAndPlay(_currentFrameData.movement);
				}
			}
		}
	}
	
}