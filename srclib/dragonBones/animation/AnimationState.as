package dragonBones.animation {

	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.Slot;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.events.AnimationEvent;
	import dragonBones.objects.AnimationData;
	import dragonBones.objects.Frame;
	import dragonBones.objects.SlotTimeline;
	import dragonBones.objects.TransformTimeline;
	
	use namespace dragonBones_internal;
	/**
	 * The AnimationState gives full control over animation blending.
	 * In most cases the Animation interface is sufficient and easier to use. Use the AnimationState if you need full control over the animation blending any playback process.
	 */
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
		
		/**
		 * Sometimes, we want slots controlled by a spedific animation state when animation is doing mix or addition.
		 * It determine if animation's color change, displayIndex change, visible change can apply to its display
		 */
		public var displayControl:Boolean;
		
		/**
		 * If animation mixing use additive blending.
		 */
		public var additiveBlending:Boolean;
		
		/**
		 * If animation auto fade out after play complete.
		 */
		public var autoFadeOut:Boolean;
		/**
		 * Duration of fade out. By default, it equals to fade in time.
		 */
		public var fadeOutTime:Number;
		
		/**
		 * The weight of animation.
		 */
		public var weight:Number;

		/**
		 * If auto genterate tween between keyframes.
		 */
		public var autoTween:Boolean;
		/**
		 * If generate tween between the lastFrame to the first frame for loop animation.
		 */
		public var lastFrameAutoTween:Boolean;
		
		/** @private */
		dragonBones_internal var _layer:int;
		/** @private */
		dragonBones_internal var _group:String;
		
		private var _armature:Armature;
		private var _timelineStateList:Vector.<TimelineState>;
		private var _slotTimelineStateList:Vector.<SlotTimelineState>;
		private var _boneMasks:Vector.<String>;
		
		private var _isPlaying:Boolean;
		private var _time:Number;
		private var _currentFrameIndex:int;
		private var _currentFramePosition:int;
		private var _currentFrameDuration:int;
		
		//Fadein 的时候是否先暂停
		private var _pausePlayheadInFade:Boolean;
		private var _isFadeOut:Boolean;
		//最终的真实权重值
		private var _fadeTotalWeight:Number;
		//受fade影响的动作权重系数，在fadein阶段他的值会由0变为1，在fadeout阶段会由1变为0
		private var _fadeWeight:Number;
		private var _fadeCurrentTime:Number;
		private var _fadeBeginTime:Number;
		
		private var _name:String;
		private var _clip:AnimationData;
		private var _isComplete:Boolean;
		private var _currentPlayTimes:int;
		private var _totalTime:int;
		private var _currentTime:int;
		private var _lastTime:int;
		//-1 beforeFade, 0 fading, 1 fadeComplete
		private var _fadeState:int;
		private var _fadeTotalTime:Number;
		
		//时间缩放参数， 各帧duration数据不变的情况下，让传入时间*timeScale 实现durationScale
		private var _timeScale:Number;
		private var _playTimes:int;
		
		public function AnimationState()
		{ 
			_timelineStateList = new Vector.<TimelineState>;
			_slotTimelineStateList = new Vector.<SlotTimelineState>;
			_boneMasks = new Vector.<String>;
		}
		
		private function clear():void
		{
			resetTimelineStateList();
			
			_boneMasks.length = 0;
			
			_armature = null;
			_clip = null;
		}
		
		dragonBones_internal function resetTimelineStateList():void
		{
			var i:int = _timelineStateList.length;
			while(i --)
			{
				TimelineState.returnObject(_timelineStateList[i]);
			}
			_timelineStateList.length = 0;
			
			i = _slotTimelineStateList.length;
			while(i --)
			{
				SlotTimelineState.returnObject(_slotTimelineStateList[i]);
			}
			_slotTimelineStateList.length = 0;
		}
		
//骨架装配
		public function containsBoneMask(boneName:String):Boolean
		{
			return _boneMasks.length == 0 || _boneMasks.indexOf(boneName) >= 0;
		}
		
		/**
		 * Adds a bone which should be animated. This allows you to reduce the number of animations you have to create.
		 * @param boneName Bone's name.
		 * @param ifInvolveChildBones if involve child bone's animation.
		 */
		public function addBoneMask(boneName:String, ifInvolveChildBones:Boolean = true):AnimationState
		{
			addBoneToBoneMask(boneName);
			
			if(ifInvolveChildBones)
			{
				var currentBone:Bone = _armature.getBone(boneName);
				if(currentBone)
				{
					var boneList:Vector.<Bone> = _armature.getBones(false);
					var i:int = boneList.length;
					while(i--)
					{
						var tempBone:Bone = boneList[i];
						if(currentBone.contains(tempBone))
						{
							addBoneToBoneMask(tempBone.name);
						}
					}
				}
			}
			
			updateTimelineStates();
			return this;
		}
		
		/**
		 * Removes a bone which was supposed be animated.
		 * @param boneName Bone's timeline name.
		 * @param ifInvolveChildBones If involved child bone's timeline.
		 */
		public function removeBoneMask(boneName:String, ifInvolveChildBones:Boolean = true):AnimationState
		{
			removeBoneFromBoneMask(boneName);
			
			if(ifInvolveChildBones)
			{
				var currentBone:Bone = _armature.getBone(boneName);
				if(currentBone)
				{
					var boneList:Vector.<Bone> = _armature.getBones(false);
					var i:int = boneList.length;
					while(i--)
					{
						var tempBone:Bone = boneList[i];
						if(currentBone.contains(tempBone))
						{
							removeBoneFromBoneMask(tempBone.name);
						}
					}
				}
			}
			updateTimelineStates();
			
			return this;
		}
		
		public function removeAllMixingTransform():AnimationState
		{
			_boneMasks.length = 0;
			updateTimelineStates();
			return this;
		}
		
		private function addBoneToBoneMask(boneName:String):void
		{
			if(_clip.getTimeline(boneName) && _boneMasks.indexOf(boneName)<0)
			{
				_boneMasks.push(boneName);
			}
		}
		
		private function removeBoneFromBoneMask(boneName:String):void
		{
			var index:int = _boneMasks.indexOf(boneName);
			if(index >= 0)
			{
				_boneMasks.splice(index, 1);
			}
		}
	
		/**
		 * @private
		 * Update timeline state based on mixing transforms and clip.
		 */
		dragonBones_internal function updateTimelineStates():void
		{
			var timelineState:TimelineState;
			var slotTimelineState:SlotTimelineState;
			var i:int = _timelineStateList.length;
			while(i --)
			{
				timelineState = _timelineStateList[i];
				if(!_armature.getBone(timelineState.name))
				{
					removeTimelineState(timelineState);
				}
			}
			
			i = _slotTimelineStateList.length;
			while (i --)
			{
				slotTimelineState = _slotTimelineStateList[i];
				if (!_armature.getSlot(slotTimelineState.name))
				{
					removeSlotTimelineState(slotTimelineState);
				}
			}
			
			if(_boneMasks.length > 0)
			{
				i = _timelineStateList.length;
				while(i --)
				{
					timelineState = _timelineStateList[i];
					if(_boneMasks.indexOf(timelineState.name) < 0)
					{
						removeTimelineState(timelineState);
					}
				}
				
				for each(var timelineName:String in _boneMasks)
				{
					addTimelineState(timelineName);
				}
			}
			else
			{
				for each(var timeline:TransformTimeline in _clip.timelineList)
				{
					addTimelineState(timeline.name);
				}
			}
			
			for each(var slotTimeline:SlotTimeline in _clip.slotTimelineList)
			{
				addSlotTimelineState(slotTimeline.name);
			}
		}
		
		private function addTimelineState(timelineName:String):void
		{
			var bone:Bone = _armature.getBone(timelineName);
			if(bone)
			{
				for each(var eachState:TimelineState in _timelineStateList)
				{
					if(eachState.name == timelineName)
					{
						return;
					}
				}
				var timelineState:TimelineState = TimelineState.borrowObject();
				timelineState.fadeIn(bone, this, _clip.getTimeline(timelineName));
				_timelineStateList.push(timelineState);
			}
		}
		
		private function removeTimelineState(timelineState:TimelineState):void
		{
			var index:int = _timelineStateList.indexOf(timelineState);
			_timelineStateList.splice(index, 1);
			TimelineState.returnObject(timelineState);
		}
		
		private function addSlotTimelineState(timelineName:String):void
		{
			var slot:Slot = _armature.getSlot(timelineName);
			if(slot && slot.displayList.length > 0)
			{
				for each(var eachState:SlotTimelineState in _slotTimelineStateList)
				{
					if(eachState.name == timelineName)
					{
						return;
					}
				}
				var timelineState:SlotTimelineState = SlotTimelineState.borrowObject();
				timelineState.fadeIn(slot, this, _clip.getSlotTimeline(timelineName));
				_slotTimelineStateList.push(timelineState);
			}
		}
		
		private function removeSlotTimelineState(timelineState:SlotTimelineState):void
		{
			var index:int = _slotTimelineStateList.indexOf(timelineState);
			_slotTimelineStateList.splice(index, 1);
			SlotTimelineState.returnObject(timelineState);
		}
		
	//动画
		/**
		 * Play the current animation. 如果动画已经播放完毕, 将不会继续播放.
		 */
		public function play():AnimationState
		{
			_isPlaying = true;
			return this;
		}
		
		/**
		 * Stop playing current animation.
		 */
		public function stop():AnimationState
		{
			_isPlaying = false;
			return this;
		}
		
		/** @private */
		dragonBones_internal function fadeIn(armature:Armature, clip:AnimationData, fadeTotalTime:Number, timeScale:Number, playTimes:Number, pausePlayhead:Boolean):AnimationState
		{
			_armature = armature;
			_clip = clip;
			_pausePlayheadInFade = pausePlayhead;
			
			_name = _clip.name;
			_totalTime = _clip.duration;
			
			autoTween = _clip.autoTween;
			
			setTimeScale(timeScale);
			setPlayTimes(playTimes);
			
			//reset
			_isComplete = false;
			_currentFrameIndex = -1;
			_currentPlayTimes = -1;
			if(Math.round(_totalTime * _clip.frameRate * 0.001) < 2 || timeScale == Infinity)
			{
				_currentTime = _totalTime;
			}
			else
			{
				_currentTime = -1;
			}
			_time = 0;
			_boneMasks.length = 0;
			
			//fade start
			_isFadeOut = false;
			_fadeWeight = 0;
			_fadeTotalWeight = 1;
			_fadeState = -1;
			_fadeCurrentTime = 0;
			_fadeBeginTime = _fadeCurrentTime;
			_fadeTotalTime = fadeTotalTime * _timeScale;
			
			//default
			_isPlaying = true;
			displayControl = true;
			lastFrameAutoTween = true;
			additiveBlending = false;
			weight = 1;
			fadeOutTime = fadeTotalTime;
			
			updateTimelineStates();
			return this;
		}
		
		/**
		 * Fade out the animation state
		 * @param fadeOutTime 
		 * @param pauseBeforeFadeOutComplete pause the animation before fade out complete
		 */
		public function fadeOut(fadeTotalTime:Number, pausePlayhead:Boolean):AnimationState
		{
			if(!_armature)
			{
				return null;
			}
			
			if(isNaN(fadeTotalTime) || fadeTotalTime < 0)
			{
				fadeTotalTime = 0;
			}
			_pausePlayheadInFade = pausePlayhead;
			
			if(_isFadeOut)
			{
				if(fadeTotalTime > _fadeTotalTime / _timeScale - (_fadeCurrentTime - _fadeBeginTime))
				{
					//如果已经在淡出中，新的淡出需要更长的淡出时间，则忽略
					//If the animation is already in fade out, the new fade out will be ignored.
					return this;
				}
			}
			else
			{
				//第一次淡出
				//The first time to fade out.
				for each(var timelineState:TimelineState in _timelineStateList)
				{
					timelineState.fadeOut();
				}
			}
			
			//fade start
			_isFadeOut = true;
			_fadeTotalWeight = _fadeWeight;
			_fadeState = -1;
			_fadeBeginTime = _fadeCurrentTime;
			_fadeTotalTime = _fadeTotalWeight >= 0?fadeTotalTime * _timeScale:0;
			
			//default
			displayControl = false;
			
			return this;
		}
		
		/** @private */
		dragonBones_internal function advanceTime(passedTime:Number):Boolean
		{
			passedTime *= _timeScale;
			
			advanceFadeTime(passedTime);
			
			if(_fadeWeight)
			{
				advanceTimelinesTime(passedTime);
			}
			
			return _isFadeOut && _fadeState == 1;
		}
		
		private function advanceFadeTime(passedTime:Number):void
		{
			var fadeStartFlg:Boolean = false;
			var fadeCompleteFlg:Boolean = false;
			
			if(_fadeBeginTime >= 0)
			{
				var fadeState:int = _fadeState;
				_fadeCurrentTime += passedTime < 0?-passedTime:passedTime;
				if(_fadeCurrentTime >= _fadeBeginTime + _fadeTotalTime)
				{
					//fade完全结束之后触发 
					//TODO 研究明白为什么要下次再触发
					if(
						_fadeWeight == 1 || 
						_fadeWeight == 0
					)
					{
						fadeState = 1;
						if (_pausePlayheadInFade)
						{
							_pausePlayheadInFade = false;
							_currentTime = -1;
						}
					}
					
					_fadeWeight = _isFadeOut?0:1;
				}
				else if(_fadeCurrentTime >= _fadeBeginTime)
				{
					//fading
					fadeState = 0;
					//暂时只支持线性淡入淡出
					//Currently only support Linear fadein and fadeout
					_fadeWeight = (_fadeCurrentTime - _fadeBeginTime) / _fadeTotalTime * _fadeTotalWeight;
					if(_isFadeOut)
					{
						_fadeWeight = _fadeTotalWeight - _fadeWeight;
					}
				}
				else
				{
					//before fade
					fadeState = -1;
					_fadeWeight = _isFadeOut?1:0;
				}
				
				if(_fadeState != fadeState)
				{
					//_fadeState == -1 && (fadeState == 0 || fadeState == 1)
					if(_fadeState == -1)
					{
						fadeStartFlg = true;
					}
					
					//(_fadeState == -1 || _fadeState == 0) && fadeState == 1
					if(fadeState == 1)
					{
						fadeCompleteFlg = true;
					}
					_fadeState = fadeState;
				}
			}
			
			var event:AnimationEvent;
			
			if(fadeStartFlg)
			{
				if(_isFadeOut)
				{
					if(_armature.hasEventListener(AnimationEvent.FADE_OUT))
					{
						event = new AnimationEvent(AnimationEvent.FADE_OUT);
						event.animationState = this;
						_armature._eventList.push(event);
					}
				}
				else
				{
					//动画开始，先隐藏不需要的骨头
					hideBones();
					
					if(_armature.hasEventListener(AnimationEvent.FADE_IN))
					{
						event = new AnimationEvent(AnimationEvent.FADE_IN);
						event.animationState = this;
						_armature._eventList.push(event);
					}
				}
			}
			
			if(fadeCompleteFlg)
			{
				if(_isFadeOut)
				{
					if(_armature.hasEventListener(AnimationEvent.FADE_OUT_COMPLETE))
					{
						event = new AnimationEvent(AnimationEvent.FADE_OUT_COMPLETE);
						event.animationState = this;
						_armature._eventList.push(event);
					}
				}
				else
				{
					if(_armature.hasEventListener(AnimationEvent.FADE_IN_COMPLETE))
					{
						event = new AnimationEvent(AnimationEvent.FADE_IN_COMPLETE);
						event.animationState = this;
						_armature._eventList.push(event);
					}
				}
			}
		}
		
		private function advanceTimelinesTime(passedTime:Number):void
		{
			if(_isPlaying && !_pausePlayheadInFade)
			{
				_time += passedTime;
			}
			
			var startFlg:Boolean = false;
			var completeFlg:Boolean = false;
			var loopCompleteFlg:Boolean = false;
			var isThisComplete:Boolean = false;
			var currentPlayTimes:int = 0;
			var currentTime:int = _time * 1000;
			if(_playTimes == 0)
			{
				isThisComplete = false;
				currentPlayTimes = Math.ceil(Math.abs(currentTime) / _totalTime) || 1;
				//currentTime -= Math.floor(currentTime / _totalTime) * _totalTime;
				
				currentTime -= int(currentTime / _totalTime) * _totalTime;
				
				if(currentTime < 0)
				{
					currentTime += _totalTime;
				}
			}
			else
			{
				var totalTimes:int = _playTimes * _totalTime;
				if(currentTime >= totalTimes)
				{
					currentTime = totalTimes;
					isThisComplete = true;
				}
				else if(currentTime <= -totalTimes)
				{
					currentTime = -totalTimes;
					isThisComplete = true;
				}
				else
				{
					isThisComplete = false;
				}
				
				if(currentTime < 0)
				{
					currentTime += totalTimes;
				}
				
				currentPlayTimes = Math.ceil(currentTime / _totalTime) || 1;
				//currentTime -= Math.floor(currentTime / _totalTime) * _totalTime;
				currentTime -= int(currentTime / _totalTime) * _totalTime;
				
				if(isThisComplete)
				{
					currentTime = _totalTime;
				}
			}
			
			//update timeline
			_isComplete = isThisComplete;
			var progress:Number = _time * 1000 / _totalTime;
			for each(var timeline:TimelineState in _timelineStateList)
			{
				timeline.update(progress);
				_isComplete = timeline._isComplete && _isComplete;
			}
			//update slotTimelie
			for each(var slotTimeline:SlotTimelineState in _slotTimelineStateList)
			{
				slotTimeline.update(progress);
				_isComplete = slotTimeline._isComplete && _isComplete;
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
				
				if(_currentTime < 0)    //check start
				{
					startFlg = true;
				}
				
				if(_isComplete)    //check complete
				{
					completeFlg = true;
				}
				_lastTime = _currentTime;
				_currentTime = currentTime;
				/*
				if(isThisComplete)
				{
				currentTime = _totalTime * 0.999999;
				}
				//[0, _totalTime)
				*/
				updateMainTimeline(isThisComplete);
			}
			
			var event:AnimationEvent;
			if(startFlg)
			{
				if(_armature.hasEventListener(AnimationEvent.START))
				{
					event = new AnimationEvent(AnimationEvent.START);
					event.animationState = this;
					_armature._eventList.push(event);
				}
			}
			
			if(completeFlg)
			{
				if(_armature.hasEventListener(AnimationEvent.COMPLETE))
				{
					event = new AnimationEvent(AnimationEvent.COMPLETE);
					event.animationState = this;
					_armature._eventList.push(event);
				}
				if(autoFadeOut)
				{
					fadeOut(fadeOutTime, true);
				}
			}
			else if(loopCompleteFlg)
			{
				if(_armature.hasEventListener(AnimationEvent.LOOP_COMPLETE))
				{
					event = new AnimationEvent(AnimationEvent.LOOP_COMPLETE);
					event.animationState = this;
					_armature._eventList.push(event);
				}
			}
		}
		
		private function updateMainTimeline(isThisComplete:Boolean):void
		{
			var frameList:Vector.<Frame> = _clip.frameList;
			if(frameList.length > 0)
			{
				var prevFrame:Frame;
				var currentFrame:Frame;
				for (var i:int = 0, l:int = _clip.frameList.length; i < l; ++i)
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
						_armature.arriveAtFrame(prevFrame, null, this, true);
					}
					
					_currentFrameDuration = currentFrame.duration;
					_currentFramePosition = currentFrame.position;
					prevFrame = currentFrame;
				}
				
				if(currentFrame)
				{
					_armature.arriveAtFrame(currentFrame, null, this, false);
				}
			}
		}
		
		private function hideBones():void
		{
			for each(var timelineName:String in _clip.hideTimelineNameMap)
			{
				var bone:Bone = _armature.getBone(timelineName);
				if(bone)
				{
					bone.hideSlots();
				}
			}
		}
		
	//属性访问
		public function setAdditiveBlending(value:Boolean):AnimationState
		{
			additiveBlending = value;
			return this;
		}
		
		
		public function setAutoFadeOut(value:Boolean, fadeOutTime:Number = -1):AnimationState
		{
			autoFadeOut = value;
			if(fadeOutTime >= 0)
			{
				this.fadeOutTime = fadeOutTime * _timeScale;
			}
			return this;
		}
		
		public function setWeight(value:Number):AnimationState
		{
			if(isNaN(value) || value < 0)
			{
				value = 1;
			}
			weight = value;
			return this;
		}
		
		public function setFrameTween(autoTween:Boolean, lastFrameAutoTween:Boolean):AnimationState
		{
			this.autoTween = autoTween;
			this.lastFrameAutoTween = lastFrameAutoTween;
			return this;
		}
		
		public function setCurrentTime(value:Number):AnimationState
		{
			if(value < 0 || isNaN(value))
			{
				value = 0;
			}
			_time = value;
			_currentTime = _time * 1000;
			return this;
		}
		
		public function setTimeScale(value:Number):AnimationState
		{
			if(isNaN(value) || value == Infinity)
			{
				value = 1;
			}
			_timeScale = value;
			return this;
		}
		
		public function setPlayTimes(value:int):AnimationState
		{
			//如果动画只有一帧  播放一次就可以
			if(Math.round(_totalTime * 0.001 * _clip.frameRate) < 2)
			{
				_playTimes = value < 0?-1:1;
			}
			else
			{
				_playTimes = value < 0?-value:value;
			}
			autoFadeOut = value < 0?true:false;
			return this;
		}
		
		/**
		 * The name of the animation state.
		 */
		public function get name():String
		{
			return _name;
		}
		
		/**
		 * The layer of the animation. When calculating the final blend weights, animations in higher layers will get their weights.
		 */
		public function get layer():int
		{
			return _layer;
		}
		
		/**
		 * The group of the animation.
		 */
		public function get group():String
		{
			return _group;
		}
		
		/**
		 * The clip that is being played by this animation state.
		 * @see dragonBones.objects.AnimationData.
		 */
		public function get clip():AnimationData
		{
			return _clip;
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
		 * Current animation played times
		 */
		public function get currentPlayTimes():int
		{
			return _currentPlayTimes < 0 ? 0 : _currentPlayTimes;
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
		
		public function get fadeWeight():Number
		{
			return _fadeWeight;
		}
		
		public function get fadeState():int
		{
			return _fadeState;
		}
		
		public function get fadeTotalTime():Number
		{
			return _fadeTotalTime;
		}
		
		/**
		 * The amount by which passed time should be scaled. Used to slow down or speed up the animation. Defaults to 1.
		 */
		public function get timeScale():Number
		{
			return _timeScale;
		}
		
		/**
		 * playTimes Play times(0:loop forever, 1~+∞:play times, -1~-∞:will fade animation after play complete).
		 */
		public function get playTimes():int
		{
			return _playTimes;
		}
	}
}
