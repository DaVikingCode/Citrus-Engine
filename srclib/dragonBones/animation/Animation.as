package dragonBones.animation
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0
	* @langversion 3.0
	* @version 2.0
	*/
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
	 * An Animation instance is used to control the animation state of an Armature.
	 * @example
	 * <p>Download the example files <a href='http://dragonbones.github.com/downloads/DragonBones_Tutorial_Assets.zip'>here</a>: </p>
	 * <listing>	
	 *	package  
	 *	{
	 *		import dragonBones.Armature;
	 *		import dragonBones.factorys.BaseFactory;
	 *  	import flash.display.Sprite;
	 *		import flash.events.Event;	
     *
	 *		public class DragonAnimation extends Sprite 
	 *		{		
	 *			[Embed(source = "Dragon1.swf", mimeType = "application/octet-stream")]  
	 *			private static const ResourcesData:Class;
	 *			
	 *			private var factory:BaseFactory;
	 *			private var armature:Armature;		
	 *			
	 *			public function DragonAnimation() 
	 *			{				
	 *				factory = new BaseFactory();
	 *				factory.addEventListener(Event.COMPLETE, handleParseData);
	 *				factory.parseData(new ResourcesData(), 'Dragon');
	 *			}
	 *			
	 *			private function handleParseData(e:Event):void 
	 *			{			
	 *				armature = factory.buildArmature('Dragon');
	 *				addChild(armature.display as Sprite); 			
	 *				armature.animation.play();
	 *				addEventListener(Event.ENTER_FRAME, updateAnimation);			
	 *			}
	 *			
	 *			private function updateAnimation(e:Event):void 
	 *			{
	 *				armature.advanceTime(1 / stage.frameRate);
	 *			}		
	 *		}
	 *	}
	 * </listing>
	 * @see dragonBones.Bone
	 * @see dragonBones.Armature
	 */
	final public class Animation
	{/**
	 * @private
	 */
		internal static const SINGLE:int = 0;
		/**
	 * @private
	 */
		internal static const LIST_START:int = 1;
		/**
	 * @private
	 */
		internal static const LOOP_START:int = 2;
		/**
	 * @private
	 */
		internal static const LIST:int = 3;
		/**
	 * @private
	 */
		internal static const LOOP:int = 4;		
		private static var _soundManager:SoundEventManager = SoundEventManager.getInstance();
		/**
		 * Whether animation tweening is enabled or not.
		 */
		public var tweenEnabled:Boolean = true;
		
		private var _playType:int;
		private var _duration:Number;
		private var _rawDuration:Number;		
		private var _nextFrameDataTimeEdge:Number;
		private var _nextFrameDataID:int;
		private var _loop:int;		
		private var _breakFrameWhile:Boolean;		
		private var _armature:Armature;
		private var _movementData:MovementData;		
		private var _animationData:AnimationData;
		
		/**
		 * The AnimationData assiociated with this Animation instance.
		 * @see dragonBones.objects.AnimationData.
		 */
		public function get animationData():AnimationData
		{
			return _animationData;
		}
		/**
		 * @private
		 */
		public function set animationData(value:AnimationData):void
		{
			if (value)
			{
				stop();
				_animationData = value;
			}
		}
		
		private var _currentTime:Number;
		/**
		 * Get the current playhead time in seconds.
		 */
		public function get currentTime():Number
		{
			return _currentTime;
		}
		
		private var _totalTime:Number;
		/**
		 * Get the total elapsed time in second.
		 */
		public function get totalTime():Number
		{
			return _totalTime;
		}
		
		private var _isPlaying:Boolean;
		
		/**
		 * Indicates whether the animation is playing or not.
		 */
		public function get isPlaying():Boolean
		{
			if (_isPlaying)
			{
				return _loop >= 0 || _currentTime < _totalTime;
			}
			return false;
		}
		
		/**
		 * Indicates whether the animation has completed or not.
		 */
		public function get isComplete():Boolean
		{
			return _loop < 0 && _currentTime >= _totalTime;
		}
		
		/**
		 * Indicates whether the animation is paused or not.
		 */
		public function get isPause():Boolean
		{
			return !_isPlaying;
		}
		
		private var _timeScale:Number = 1;
		
		/**
		 * The amount by which passed time should be scaled. Used to slow down or speed up animations. Defaults to 1.
		 */
		public function get timeScale():Number
		{
			return _timeScale;
		}
		/**
		 * @private
		 */
		public function set timeScale(value:Number):void
		{
			if (value < 0)
			{
				value = 0;
			}
			_timeScale = value;
			
			for each (var bone:Bone in _armature._boneDepthList)
			{
				if (bone.childArmature)
				{
					bone.childArmature.animation.timeScale = _timeScale;
				}
			}
		}
		
		private var _movementID:String;
		
		/**
		 * The name ID of the current MovementData.
		 * @see dragonBones.objects.MovementData.
		 */
		public function get movementID():String
		{
			return _movementID;
		}
		
		/**
		 * An vector containing all MovementData names the animation can play.
		 * @see dragonBones.objects.MovementData.
		 */
		public function get movementList():Vector.<String>
		{
			return _animationData ? _animationData.movementList : null;
		}
		
		/**
		 * Creates a new Animation instance and attaches it to the passed Arnature.
		 * @param	An Armature to attach this Animation instance to.
		 */
		public function Animation(armature:Armature)
		{
			_armature = armature;
		}
		/**
		 * Qualifies all resources used by this Animation instance for garbage collection.
		 */
		public function dispose():void
		{
			stop();
			_animationData = null;
			_movementData = null;
			_armature = null;
		}
		/**
		 * Move the playhead to that MovementData id
		 * @param	The id of the MovementData to play.
		 * @param	A tween time to apply (> 0)
		 * @param	The duration in seconds of that MovementData.
		 * @param	Whether that MovementData should loop or play only once (true/false).
		 * @see dragonBones.objects.MovementData.
		 */
		public function gotoAndPlay(movementID:String, tweenTime:Number = -1, duration:Number = -1, loop:* = null):void
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
			_movementData = movementData;
			_isPlaying = true;
			_currentTime = 0;
			_breakFrameWhile = true;
			
			var exMovementID:String = _movementID;
			_movementID = movementID as String;
			
			if (tweenTime >= 0)
			{
				_totalTime = tweenTime;
			}
			else if (tweenEnabled && exMovementID)
			{
				_totalTime = _movementData.durationTo;
			}
			else
			{
				_totalTime = 0;
			}
			
			if (_totalTime < 0)
			{
				_totalTime = 0;
			}
			
			_duration = duration >= 0 ? duration : _movementData.durationTween;
			if (_duration < 0)
			{
				_duration = 0;
			}
			loop = Boolean(loop === null ? _movementData.loop : loop);
			
			_rawDuration = _movementData.duration;
			
			_loop = loop ? 0 : -1;
			if (_rawDuration == 0)
			{
				_playType = SINGLE;
			}
			else
			{
				_nextFrameDataTimeEdge = 0;
				_nextFrameDataID = 0;
				if (loop)
				{
					_playType = LOOP_START;
				}
				else
				{
					_playType = LIST_START;
				}
			}
			
			var tweenEasing:Number = _movementData.tweenEasing;
			
			for each (var bone:Bone in _armature._boneDepthList)
			{
				var movementBoneData:MovementBoneData = _movementData.getMovementBoneData(bone.name);
				if (movementBoneData)
				{
					bone._tween.gotoAndPlay(movementBoneData, _rawDuration, loop, tweenEasing);
					if (bone.childArmature)
					{
						bone.childArmature.animation.gotoAndPlay(movementID);
					}
				}
				else
				{
					bone._tween.stop();
				}
			}
			
			if (_armature.hasEventListener(AnimationEvent.MOVEMENT_CHANGE))
			{
				var event:AnimationEvent = new AnimationEvent(AnimationEvent.MOVEMENT_CHANGE);
				event.exMovementID = exMovementID;
				event.movementID = _movementID;
				_armature.dispatchEvent(event);
			}
		}
		
		/**
		 * Play the animation from the current position.
		 */
		public function play():void
		{
			if (!_animationData)
			{
				return;
			}
			
			if (!_movementID)
			{
				if (movementList)
				{
					gotoAndPlay(movementList[0]);
				}
				return;
			}
			
			if (isComplete)
			{
				gotoAndPlay(_movementID);
			}
			else if (!_isPlaying)
			{
				_isPlaying = true;
				for each(var bone:Bone in _armature._boneDepthList)
				{
					if (bone.childArmature)
					{
						bone.childArmature.animation.play();
					}
				}
			}
		}
		
		/** @private */
		dragonBones_internal function clearMovement():void
		{
			_movementID = null;
		}
		
		/**
		 * Stop the playhead.
		 */
		public function stop():void
		{
			_isPlaying = false;
			
			for each(var bone:Bone in _armature._boneDepthList)
			{
				if (bone.childArmature)
				{
					bone.childArmature.animation.stop();
				}
			}
		}
		
		/** @private */
		dragonBones_internal function advanceTime(passedTime:Number):void
		{
			if (_isPlaying && (_loop > 0 || _currentTime < _totalTime || _totalTime == 0))
			{
				var progress:Number;
				if (_totalTime > 0)
				{
					_currentTime += passedTime * _timeScale;
					progress = _currentTime / _totalTime;
				}
				else
				{
					_currentTime = 1;
					_totalTime = 1;
					progress = 1;
				}
				
				var event:AnimationEvent;
				if (_playType == LOOP)
				{
					var loop:int = progress;
					if (loop != _loop)
					{
						_loop = loop;
						_nextFrameDataTimeEdge = 0;
						if (_armature.hasEventListener(AnimationEvent.LOOP_COMPLETE))
						{
							event = new AnimationEvent(AnimationEvent.LOOP_COMPLETE);
							event.movementID = _movementID;
						}
					}
				}
				else if (progress >= 1)
				{
					switch (_playType)
					{
						case SINGLE: 
						case LIST: 
							progress = 1;
							if (_armature.hasEventListener(AnimationEvent.COMPLETE))
							{
								event = new AnimationEvent(AnimationEvent.COMPLETE);
								event.movementID = _movementID;
							}
							break;
						case LIST_START: 
							progress = 0;
							_playType = LIST;
							_currentTime = 0;
							_totalTime = _duration;
							if (_armature.hasEventListener(AnimationEvent.START))
							{
								event = new AnimationEvent(AnimationEvent.START);
								event.movementID = _movementID;
							}
							break;
						case LOOP_START: 
							progress = 0;
							_playType = LOOP;
							_currentTime = 0;
							_totalTime = _duration;
							if (_armature.hasEventListener(AnimationEvent.START))
							{
								event = new AnimationEvent(AnimationEvent.START);
								event.movementID = _movementID;
							}
							break;
					}
				}
				
				var i:int = _armature._boneDepthList.length;
				while(i --)
				{
					_armature._boneDepthList[i]._tween.advanceTime(progress, _playType);
				}
				
				if ((_playType == LIST || _playType == LOOP) && _movementData._movementFrameList.length > 0)
				{
					if (_loop > 0)
					{
						progress -= _loop;
					}
					updateFrameData(progress);
				}
				
				if (event)
				{
					_armature.dispatchEvent(event);
				}
			}
		}
		
		private function updateFrameData(progress:Number):void
		{
			var playedTime:Number = _rawDuration * progress;
			if (playedTime >= _nextFrameDataTimeEdge)
			{
				_breakFrameWhile = false;
				var length:uint = _movementData._movementFrameList.length;
				do
				{
					var currentFrameDataID:int = _nextFrameDataID;
					var currentFrameData:MovementFrameData = _movementData._movementFrameList[currentFrameDataID];
					var frameDuration:Number = currentFrameData.duration;
					_nextFrameDataTimeEdge += frameDuration;
					if (++_nextFrameDataID >= length)
					{
						_nextFrameDataID = 0;
					}
					arriveFrameData(currentFrameData);
					if (_breakFrameWhile)
					{
						break;
					}
				} while (playedTime >= _nextFrameDataTimeEdge);
			}
		}
		
		private function arriveFrameData(movementFrameData:MovementFrameData):void
		{
			//Tracer.reveal(movementFrameData)
			if (movementFrameData.event && _armature.hasEventListener(FrameEvent.MOVEMENT_FRAME_EVENT))
			{
				var frameEvent:FrameEvent = new FrameEvent(FrameEvent.MOVEMENT_FRAME_EVENT);
				frameEvent.movementID = _movementID;
				frameEvent.frameLabel = movementFrameData.event;
				_armature.dispatchEvent(frameEvent);
			}
			if (movementFrameData.sound && _soundManager.hasEventListener(SoundEvent.SOUND))
			{
				var soundEvent:SoundEvent = new SoundEvent(SoundEvent.SOUND);
				soundEvent.movementID = _movementID;
				soundEvent.sound = movementFrameData.sound;
				soundEvent._armature = _armature;
				_soundManager.dispatchEvent(soundEvent);
			}
			if (movementFrameData.movement)
			{
				gotoAndPlay(movementFrameData.movement);
			}
		}
	}

}