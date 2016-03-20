package dragonBones.fast.animation {

	import dragonBones.cache.AnimationCache;
	import dragonBones.core.IAnimationState;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.events.AnimationEvent;
	import dragonBones.fast.FastArmature;
	import dragonBones.fast.FastBone;
	import dragonBones.fast.FastSlot;
	import dragonBones.objects.AnimationData;
	import dragonBones.objects.Frame;
	import dragonBones.objects.SlotTimeline;
	import dragonBones.objects.TransformTimeline;

	use namespace dragonBones_internal;
	
	public class FastAnimationState implements IAnimationState
	{
		
		public var animationCache:AnimationCache;
		/**
		 * If auto genterate tween between keyframes.
		 */
		public var autoTween:Boolean;
		private var _progress:Number;
		
		dragonBones_internal var _armature:FastArmature;
		
		private var _boneTimelineStateList:Vector.<FastBoneTimelineState> = new Vector.<FastBoneTimelineState>;
		private var _slotTimelineStateList:Vector.<FastSlotTimelineState> = new Vector.<FastSlotTimelineState>;
		public var animationData:AnimationData;
		
		public var name:String;
		private var _time:Number;//秒
		private var _currentFrameIndex:int;
		private var _currentFramePosition:int;
		private var _currentFrameDuration:int;
		
		private var _currentPlayTimes:int;
		private var _totalTime:int;//毫秒
		private var _currentTime:int;
		private var _lastTime:int;
		
		private var _isComplete:Boolean;
		private var _isPlaying:Boolean;
		private var _timeScale:Number;
		private var _playTimes:int;
		
		private var _fading:Boolean = false;
		private var _listenCompleteEvent:Boolean;
		private var _listenLoopCompleteEvent:Boolean;
		
		dragonBones_internal var _fadeTotalTime:Number;
		
		
		public function FastAnimationState()
		{
		}
		
		public function dispose():void
		{
			resetTimelineStateList();
			_armature = null;
		}
		
		/**
		 * Play the current animation. 如果动画已经播放完毕, 将不会继续播放.
		 */
		public function play():FastAnimationState
		{
			_isPlaying = true;
			return this;
		}
		
		/**
		 * Stop playing current animation.
		 */
		public function stop():FastAnimationState
		{
			_isPlaying = false;
			return this;
		}
		
		public function setCurrentTime(value:Number):FastAnimationState
		{
			if(value < 0 || isNaN(value))
			{
				value = 0;
			}
			_time = value;
			_currentTime = _time * 1000;
			return this;
		}
		
		dragonBones_internal function resetTimelineStateList():void
		{
			var i:int = _boneTimelineStateList.length;
			while(i --)
			{
				FastBoneTimelineState.returnObject(_boneTimelineStateList[i]);
			}
			_boneTimelineStateList.length = 0;
			
			i = _slotTimelineStateList.length;
			while(i --)
			{
				FastSlotTimelineState.returnObject(_slotTimelineStateList[i]);
			}
			_slotTimelineStateList.length = 0;
			name = null;
		}
		
		/** @private */
		dragonBones_internal function fadeIn(aniData:AnimationData, playTimes:Number, timeScale:Number, fadeTotalTime:Number):void
		{
			animationData = aniData;
			
			name = animationData.name;
			_totalTime = animationData.duration;
			autoTween = aniData.autoTween;
			setTimeScale(timeScale);
			setPlayTimes(playTimes);
			
			//reset
			_isComplete = false;
			_currentFrameIndex = -1;
			_currentPlayTimes = -1;
			if(Math.round(_totalTime * animationData.frameRate * 0.001) < 2)
			{
				_currentTime = _totalTime;
			}
			else
			{
				_currentTime = -1;
			}

			_fadeTotalTime = fadeTotalTime * _timeScale;
			_fading = _fadeTotalTime>0;
			//default
			_isPlaying = true;
			
			_listenCompleteEvent = _armature.hasEventListener(AnimationEvent.COMPLETE);
			
			if(this._armature.enableCache && animationCache && _fading && _boneTimelineStateList)
			{
				updateTransformTimeline(progress);
			}
			
			_time = 0;
			_progress = 0;
			
			updateTimelineStateList();
			hideBones();
			return;
		}
		
		/**
		 * @private
		 * Update timeline state based on mixing transforms and clip.
		 */
		dragonBones_internal function updateTimelineStateList():void
		{	
			resetTimelineStateList();
			var timelineName:String;
			for each(var boneTimeline:TransformTimeline in animationData.timelineList)
			{
				timelineName = boneTimeline.name;
				var bone:FastBone = _armature.getBone(timelineName);
				if(bone)
				{
					var boneTimelineState:FastBoneTimelineState = FastBoneTimelineState.borrowObject();
					boneTimelineState.fadeIn(bone, this, boneTimeline);
					_boneTimelineStateList.push(boneTimelineState);
				}
			}
			
			for each(var slotTimeline:SlotTimeline in animationData.slotTimelineList)
			{
				timelineName = slotTimeline.name;
				var slot:FastSlot = _armature.getSlot(timelineName);
				if(slot && slot.displayList.length > 0)
				{
					var slotTimelineState:FastSlotTimelineState = FastSlotTimelineState.borrowObject();
					slotTimelineState.fadeIn(slot, this, slotTimeline);
					_slotTimelineStateList.push(slotTimelineState);
				}
			}
		}
		
		/** @private */
		dragonBones_internal function advanceTime(passedTime:Number):void
		{
			passedTime *= _timeScale;
			if(_fading)
			{
				//计算progress
				_time += passedTime;
				_progress = _time / _fadeTotalTime;
				if(progress >= 1)
				{
					_progress = 0;
					_time = 0;
					_fading = false;
				}
			}
			
			if(_fading)
			{
				//update boneTimelie
				for each(var timeline:FastBoneTimelineState in _boneTimelineStateList)
				{
					timeline.updateFade(progress);
				}
				//update slotTimelie
				for each(var slotTimeline:FastSlotTimelineState in _slotTimelineStateList)
				{
					slotTimeline.updateFade(progress);
				}
			}
			else
			{
				advanceTimelinesTime(passedTime);
			}
		}
		
		private function advanceTimelinesTime(passedTime:Number):void
		{
			_time += passedTime;
			
			//计算是否已经播放完成isThisComplete

			var loopCompleteFlg:Boolean = false;
			var completeFlg:Boolean = false;
			var isThisComplete:Boolean = false;
			var currentPlayTimes:int = 0;
			var currentTime:int = _time * 1000;
			if( _playTimes == 0 || //无限循环
				currentTime < _playTimes * _totalTime) //没有播放完毕
			{
				isThisComplete = false;
				
				_progress = currentTime / _totalTime;
				currentPlayTimes = Math.ceil(progress) || 1;
				_progress -= Math.floor(progress);
				currentTime %= _totalTime;
			}
			else
			{
				currentPlayTimes = _playTimes;
				currentTime = _totalTime;
				isThisComplete = true;
				_progress = 1;
			}
			
			_isComplete = isThisComplete;

			if(this.isUseCache())
			{
				animationCache.update(progress);
			}
			else
			{
				updateTransformTimeline(progress);
			}
			
			//update main timeline
			if(_currentTime != currentTime)
			{
				if(_currentPlayTimes != currentPlayTimes)    //check loop complete
				{
					if(_currentPlayTimes > 0 && currentPlayTimes > 1)
					{
						loopCompleteFlg = true;
					}
					_currentPlayTimes = currentPlayTimes;
				}
				if (_isComplete)
				{
					completeFlg = true;
				}
				_lastTime = _currentTime;
				_currentTime = currentTime;
				updateMainTimeline(isThisComplete);
			}
			
			//抛事件
			var event:AnimationEvent;
			if(completeFlg)
			{
				if (_armature.hasEventListener(AnimationEvent.COMPLETE))
				{
					event = new AnimationEvent(AnimationEvent.COMPLETE);
					event.animationState = this;
					_armature.addEvent(event);
				}
			}
			else if(loopCompleteFlg)
			{
				if (_armature.hasEventListener(AnimationEvent.LOOP_COMPLETE))
				{
					event = new AnimationEvent(AnimationEvent.LOOP_COMPLETE);
					event.animationState = this;
					_armature.addEvent(event);
				}
				
			}
		}
		
		private function updateTransformTimeline(progress:Number):void
		{
			var i:int = _boneTimelineStateList.length;
			var boneTimeline:FastBoneTimelineState;
			var slotTimeline:FastSlotTimelineState;
			
			if(_isComplete) // 性能优化
			{
				//update boneTimelie
				while(i--)
				{
					boneTimeline = _boneTimelineStateList[i];
					boneTimeline.update(progress);
					_isComplete = boneTimeline._isComplete && _isComplete;
				}
				
				i = _slotTimelineStateList.length;
				
				//update slotTimelie
				while(i--)
				{
					slotTimeline = _slotTimelineStateList[i];
					slotTimeline.update(progress);
					_isComplete = slotTimeline._isComplete && _isComplete;
				}
			}
			else
			{
				//update boneTimelie
				while(i--)
				{
					boneTimeline = _boneTimelineStateList[i];
					boneTimeline.update(progress);
				}
				
				i = _slotTimelineStateList.length;
				
				//update slotTimelie
				while(i--)
				{
					slotTimeline = _slotTimelineStateList[i];
					slotTimeline.update(progress);
				}
			}
		}
		
		private function updateMainTimeline(isThisComplete:Boolean):void
		{
			var frameList:Vector.<Frame> = animationData.frameList;
			if(frameList.length > 0)
			{
				var prevFrame:Frame;
				var currentFrame:Frame;
				for (var i:int = 0, l:int = animationData.frameList.length; i < l; ++i)
				{
					if(_currentFrameIndex < 0)
					{
						_currentFrameIndex = 0;
					}
					else if(_currentTime < _currentFramePosition || _currentTime >= _currentFramePosition + _currentFrameDuration || _currentTime < _lastTime)
					{
						_lastTime = _currentTime;
						_currentFrameIndex ++;
						if(_currentFrameIndex >= frameList.length)
						{
							if(isThisComplete)
							{
								_currentFrameIndex --;
								break;
							}
							else
							{
								_currentFrameIndex = 0;
							}
						}
					}
					else
					{
						break;
					}
					currentFrame = frameList[_currentFrameIndex];
					
					if(prevFrame)
					{
						_armature.arriveAtFrame(prevFrame, this);
					}
					
					_currentFrameDuration = currentFrame.duration;
					_currentFramePosition = currentFrame.position;
					prevFrame = currentFrame;
				}
				
				if(currentFrame)
				{
					_armature.arriveAtFrame(currentFrame, this);
				}
			}
		}

		private function hideBones():void
		{
			for each(var timelineName:String in animationData.hideTimelineNameMap)
			{
				
				var slot:FastSlot = _armature.getSlot(timelineName);
				if(slot)
				{
					slot.hideSlots();
				}
			}
		}
		
		public function setTimeScale(value:Number):FastAnimationState
		{
			if(isNaN(value) || value == Infinity)
			{
				value = 1;
			}
			_timeScale = value;
			return this;
		}
		
		public function setPlayTimes(value:int):FastAnimationState
		{
			//如果动画只有一帧  播放一次就可以
			if(Math.round(_totalTime * 0.001 * animationData.frameRate) < 2)
			{
				_playTimes = 1;
			}
			else
			{
				_playTimes = value;
			}
			return this;
		}
		
		/**
		 * playTimes Play times(0:loop forever, 1~+∞:play times, -1~-∞:will fade animation after play complete).
		 */
		public function get playTimes():int
		{
			return _playTimes;
		}
		
		/**
		 * Current animation played times
		 */
		public function get currentPlayTimes():int
		{
			return _currentPlayTimes < 0 ? 0 : _currentPlayTimes;
		}
		
		/**
		 * Is animation complete.
		 */
		public function get isComplete():Boolean
		{
			return _isComplete; 
		}
		
		/**
		 * Is animation playing.
		 */
		public function get isPlaying():Boolean
		{
			return (_isPlaying && !_isComplete);
		}
		
		/**
		 * The length of the animation clip in seconds.
		 */
		public function get totalTime():Number
		{
			return _totalTime * 0.001;
		}
		
		/**
		 * The current time of the animation.
		 */
		public function get currentTime():Number
		{
			return _currentTime < 0 ? 0 : _currentTime * 0.001;
		}
		
		
		public function isUseCache():Boolean
		{
			return _armature.enableCache && animationCache && !_fading;
		}
		
		public function get progress():Number
		{
			return _progress;
		}
	}
}