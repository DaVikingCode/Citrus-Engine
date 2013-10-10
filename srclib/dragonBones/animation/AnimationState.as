package dragonBones.animation
{
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.Slot;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.events.AnimationEvent;
	import dragonBones.objects.AnimationData;
	import dragonBones.objects.DBTransform;
	import dragonBones.objects.Frame;
	import dragonBones.objects.TransformTimeline;
	
	use namespace dragonBones_internal;

	final public class AnimationState
	{
		private static var _pool:Vector.<AnimationState> = new Vector.<AnimationState>;
		
		/** @private */
		dragonBones_internal static function borrowObject():AnimationState
		{
			if(_pool.length == 0)
			{
				return new AnimationState();
			}
			return _pool.pop();
		}
		
		/** @private */
		dragonBones_internal static function returnObject(animationState:AnimationState):void
		{
			animationState.clear();
			
			if(_pool.indexOf(animationState) < 0)
			{
				_pool[_pool.length] = animationState;
			}
		}
		
		/** @private */
		dragonBones_internal static function clear():void
		{
			var i:int = _pool.length;
			while(i --)
			{
				_pool[i].clear();
			}
			_pool.length = 0;
			
			TimelineState.clear();
		}
		
		public var tweenEnabled:Boolean;
		public var blend:Boolean;
		public var group:String;
		public var weight:Number;
		
		/** @private */
		dragonBones_internal var _timelineStates:Object;
		/** @private */
		dragonBones_internal var _fadeWeight:Number;
		
		private var _armature:Armature;
		private var _currentFrame:Frame;
		private var _mixingTransforms:Object;
		private var _fadeState:int;
		private var _fadeInTime:Number;
		private var _fadeOutTime:Number;
		private var _fadeOutBeginTime:Number;
		private var _fadeOutWeight:Number;
		private var _fadeIn:Boolean;
		private var _fadeOut:Boolean;
		private var _pauseBeforeFadeInCompleteState:int;
		
		private var _name:String;
		public function get name():String
		{
			return _name;
		}
		
		private var _clip:AnimationData;
		public function get clip():AnimationData
		{
			return _clip;
		}
		
		private var _loopCount:int;
		public function get loopCount():int
		{
			return _loopCount;
		}
		
		private var _loop:int;
		public function get loop():int
		{
			return _loop;
		}
		
		private var _layer:uint;
		public function get layer():uint
		{
			return _layer;
		}
		
		private var _isPlaying:Boolean;
		public function get isPlaying():Boolean
		{
			return _isPlaying && !_isComplete;
		}
		
		private var _isComplete:Boolean;
		public function get isComplete():Boolean
		{
			return _isComplete; 
		}
		
		public function get fadeInTime():Number
		{
			return _fadeInTime;
		}
		
		private var _totalTime:Number;
		public function get totalTime():Number
		{
			return _totalTime;
		}
		
		private var _currentTime:Number;
		public function get currentTime():Number
		{
			return _currentTime;
		}
		public function set currentTime(value:Number):void
		{
			if(value < 0 || isNaN(value))
			{
				value = 0;
			}
			//
			_currentTime = value;
		}
		
		private var _timeScale:Number;
		public function get timeScale():Number
		{
			return _timeScale;
		}
		public function set timeScale(value:Number):void
		{
			if(value < 0)
			{
				value = 0;
			}
			else if(isNaN(value))
			{
				value = 1;
			}
			else if(_timeScale == Infinity)
			{
				//*
				_timeScale = 1;
			}
			_timeScale = value;
		}
		
		public var displayControl:Boolean;
		
		public function AnimationState()
		{ 
			_timelineStates = {};
		}
		
		/** @private */
		dragonBones_internal function fadeIn(armature:Armature, clip:AnimationData, fadeInTime:Number, timeScale:Number, loop:int, layer:uint, displayControl:Boolean, pauseBeforeFadeInComplete:Boolean):void
		{
			_armature = armature;
			_clip = clip;
			_name = _clip.name;
			_layer = layer;
			
			_totalTime = _clip.duration;
			if(Math.round(_clip.duration * _clip.frameRate) < 2 || timeScale == Infinity)
			{
				_timeScale = 1;
				_currentTime = _totalTime;
				if(_loop >= 0)
				{
					_loop = 1;
				}
				else
				{
					_loop = -1;
				}
			}
			else
			{
				_timeScale = timeScale;
				_currentTime = 0;
				_loop = loop;
			}
			
			if(pauseBeforeFadeInComplete)
			{
				_pauseBeforeFadeInCompleteState = -1;
			}
			else
			{
				_pauseBeforeFadeInCompleteState = 1;
			}
			
			_fadeInTime = fadeInTime * _timeScale;
			
			
			_loopCount = -1;
			_fadeState = 1;
			_fadeOutBeginTime = 0;
			_fadeOutWeight = -1;
			_fadeWeight = 0;
			_isPlaying = true;
			_isComplete = false;
			_fadeIn = true;
			_fadeOut = false;
			
			this.displayControl = displayControl;
			
			weight = 1;
			blend = true;
			tweenEnabled = true;
			
			updateTimelineStates();
		}
		
		public function fadeOut(fadeOutTime:Number, pause:Boolean = false):void
		{
			if(!_armature || _fadeOutWeight >= 0)
			{
				return;
			}
			_fadeState = -1;
			_fadeOutWeight = _fadeWeight;
			_fadeOutTime = fadeOutTime * _timeScale;
			_fadeOutBeginTime = _currentTime;
			
			_isPlaying = !pause;
			_fadeOut = true;
			displayControl = false;
			
			for each(var timelineState:TimelineState in _timelineStates)
			{
				timelineState.fadeOut();
			}
		}
		
		public function play():void
		{
			_isPlaying = true;
		}
		
		public function stop():void
		{
			_isPlaying = false;
		}
		
		public function getMixingTransform(timelineName:String):int
		{
			if(_mixingTransforms)
			{
				return int(_mixingTransforms[timelineName]);
			}
			return -1;
		}
		
		public function addMixingTransform(timelineName:String, type:int = 2, recursive:Boolean = true):void
		{
			if(_clip && _clip.getTimeline(timelineName))
			{
				if(!_mixingTransforms)
				{
					_mixingTransforms = {};
				}
				if(recursive)
				{
					var i:int = _armature._boneList.length;
					var bone:Bone;
					var currentBone:Bone;
					while(i --)
					{
						bone = _armature._boneList[i];
						if(bone.name == timelineName)
						{
							currentBone = bone;
						}
						if(currentBone && (currentBone == bone || currentBone.contains(bone)))
						{
							_mixingTransforms[bone.name] = type;
						}
					}
				}
				else
				{
					_mixingTransforms[timelineName] = type;
				}
				
				updateTimelineStates();
			}
			else
			{
				throw new ArgumentError();
			}
		}
		
		public function removeMixingTransform(timelineName:String = null, recursive:Boolean = true):void
		{
			if(timelineName)
			{
				if(recursive)
				{
					var i:int = _armature._boneList.length;
					var bone:Bone;
					var currentBone:Bone;
					while(i --)
					{
						bone = _armature._boneList[i];
						if(bone.name == timelineName)
						{
							currentBone = bone;
						}
						if(currentBone && (currentBone == bone || currentBone.contains(bone)))
						{
							delete _mixingTransforms[bone.name];
						}
					}
				}
				else
				{
					delete _mixingTransforms[timelineName];
				}
				
				for each(timelineName in _mixingTransforms)
				{
					var hasMixing:Boolean = true;
					break;
				}
				if(!hasMixing)
				{
					_mixingTransforms = null;
				}
			}
			else
			{
				_mixingTransforms = null;
			}
			
			updateTimelineStates();
		}
		
		public function advanceTime(passedTime:Number):Boolean
		{
			var event:AnimationEvent;
			var isComplete:Boolean;
			
			if(_fadeIn)
			{	
				_fadeIn = false;
				_armature.animation.setActive(this, true);
				if(_armature.hasEventListener(AnimationEvent.FADE_IN))
				{
					event = new AnimationEvent(AnimationEvent.FADE_IN);
					event.animationState = this;
					_armature._eventList.push(event);
				}
			}
			
			if(_fadeOut)
			{	
				_fadeOut = false;
				_armature.animation.setActive(this, true);
				if(_armature.hasEventListener(AnimationEvent.FADE_OUT))
				{
					event = new AnimationEvent(AnimationEvent.FADE_OUT);
					event.animationState = this;
					_armature._eventList.push(event);
				}
			}
			
			_currentTime += passedTime * _timeScale;
			
			if(_isPlaying && !_isComplete && _pauseBeforeFadeInCompleteState)
			{
				var progress:Number;
				var currentLoopCount:int;
				if(_pauseBeforeFadeInCompleteState == -1)
				{
					_pauseBeforeFadeInCompleteState = 0;
					progress = 0;
					currentLoopCount = progress;
				}
				else
				{
					progress = _currentTime / _totalTime;
					//update loopCount
					currentLoopCount = progress;
					if(currentLoopCount != _loopCount)
					{
						if(_loopCount == -1)
						{
							_armature.animation.setActive(this, true);
							if(_armature.hasEventListener(AnimationEvent.START))
							{
								event = new AnimationEvent(AnimationEvent.START);
								event.animationState = this;
								_armature._eventList.push(event);
							}
						}
						_loopCount = currentLoopCount;
						if(_loopCount)
						{
							if(_loop && _loopCount * _loopCount >= _loop * _loop - 1)
							{
								isComplete = true;
								progress = 1;
								currentLoopCount = 0;
								if(_armature.hasEventListener(AnimationEvent.COMPLETE))
								{
									event = new AnimationEvent(AnimationEvent.COMPLETE);
									event.animationState = this;
									_armature._eventList.push(event);
								}
							}
							else
							{
								if(_armature.hasEventListener(AnimationEvent.LOOP_COMPLETE))
								{
									event = new AnimationEvent(AnimationEvent.LOOP_COMPLETE);
									event.animationState = this;
									_armature._eventList.push(event);
								}
							}
						}
					}
				}
				
				
				for each(var timeline:TimelineState in _timelineStates)
				{
					timeline.update(progress);
				}
				
				//
				if(_clip.frameList.length > 0)
				{
					var playedTime:Number = _totalTime * (progress - currentLoopCount);
					var isArrivedFrame:Boolean = false;
					var frameIndex:int;
					while(!_currentFrame || playedTime > _currentFrame.position + _currentFrame.duration || playedTime < _currentFrame.position)
					{
						if(isArrivedFrame)
						{
							_armature.arriveAtFrame(_currentFrame, null, this, true);
						}
						isArrivedFrame = true;
						if(_currentFrame)
						{
							frameIndex = _clip.frameList.indexOf(_currentFrame);
							frameIndex ++;
							if(frameIndex >= _clip.frameList.length)
							{
								frameIndex = 0;
							}
							_currentFrame = _clip.frameList[frameIndex];
						}
						else
						{
							_currentFrame = _clip.frameList[0];
						}
					}
					
					if(isArrivedFrame)
					{
						_armature.arriveAtFrame(_currentFrame, null, this, false);
					}
				}
			}
			
			//update weight and fadeState
			if(_fadeState > 0)
			{
				if(_fadeInTime == 0)
				{
					_fadeWeight = 1;
					_fadeState = 0;
					_pauseBeforeFadeInCompleteState = 1;
					_armature.animation.setActive(this, false);
					if(_armature.hasEventListener(AnimationEvent.FADE_IN_COMPLETE))
					{
						event = new AnimationEvent(AnimationEvent.FADE_IN_COMPLETE);
						event.animationState = this;
						_armature._eventList.push(event);
					}
				}
				else
				{
					_fadeWeight = _currentTime / _fadeInTime;
					if(_fadeWeight >= 1)
					{
						_fadeWeight = 1;
						_fadeState = 0;
						if(_pauseBeforeFadeInCompleteState == 0)
						{
							_currentTime -= _fadeInTime;
						}
						_pauseBeforeFadeInCompleteState = 1;
						_armature.animation.setActive(this, false);
						if(_armature.hasEventListener(AnimationEvent.FADE_IN_COMPLETE))
						{
							event = new AnimationEvent(AnimationEvent.FADE_IN_COMPLETE);
							event.animationState = this;
							_armature._eventList.push(event);
						}
					}
				}
			}
			else if(_fadeState < 0)
			{
				if(_fadeOutTime == 0)
				{
					_fadeWeight = 0;
					_fadeState = 0;
					_armature.animation.setActive(this, false);
					if(_armature.hasEventListener(AnimationEvent.FADE_OUT_COMPLETE))
					{
						event = new AnimationEvent(AnimationEvent.FADE_OUT_COMPLETE);
						event.animationState = this;
						_armature._eventList.push(event);
					}
					return true;
				}
				else
				{
					_fadeWeight = (1 - (_currentTime - _fadeOutBeginTime) / _fadeOutTime) * _fadeOutWeight;
					if(_fadeWeight <= 0)
					{
						_fadeWeight = 0;
						_fadeState = 0;
						_armature.animation.setActive(this, false);
						if(_armature.hasEventListener(AnimationEvent.FADE_OUT_COMPLETE))
						{
							event = new AnimationEvent(AnimationEvent.FADE_OUT_COMPLETE);
							event.animationState = this;
							_armature._eventList.push(event);
						}
						return true;
					}
				}
			}
			
			if(isComplete)
			{
				_isComplete = true;
				if(_loop < 0)
				{
					fadeOut((_fadeOutWeight || _fadeInTime) / _timeScale, true);
				}
				else
				{
					_armature.animation.setActive(this, false);
				}
			}
			
			return false;
		}
		
		private function updateTimelineStates():void
		{
			if(_mixingTransforms)
			{
				for(var timelineName:String in _timelineStates)
				{
					if(_mixingTransforms[timelineName] == null)
					{
						removeTimelineState(timelineName);
					}
				}
				
				for(timelineName in _mixingTransforms)
				{
					if(!_timelineStates[timelineName])
					{
						addTimelineState(timelineName);
					}
				}
			}
			else
			{
				for(timelineName in _clip.timelines)
				{
					if(!_timelineStates[timelineName])
					{
						addTimelineState(timelineName);
					}
				}
			}
		}
		
		private function addTimelineState(timelineName:String):void
		{
			var bone:Bone = _armature.getBone(timelineName);
			if(bone)
			{
				var timelineState:TimelineState = TimelineState.borrowObject();
				var timeline:TransformTimeline = _clip.getTimeline(timelineName);
				timelineState.fadeIn(bone, this, timeline);
				_timelineStates[timelineName] = timelineState;
			}
		}
		
		private function removeTimelineState(timelineName:String):void
		{
			TimelineState.returnObject(_timelineStates[timelineName] as TimelineState);
			delete _timelineStates[timelineName];
		}
		
		private function clear():void
		{
			_armature = null;
			_currentFrame = null;
			_clip = null;
			_mixingTransforms = null;
			
			for(var timelineName:String in _timelineStates)
			{
				removeTimelineState(timelineName);
			}
		}
	}
}