package dragonBones.animation
{
	import dragonBones.objects.CurveData;
	import flash.geom.ColorTransform;
	
	import dragonBones.Armature;
	import dragonBones.Slot;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.objects.Frame;
	import dragonBones.objects.SlotFrame;
	import dragonBones.objects.SlotTimeline;
	import dragonBones.utils.MathUtil;
	
	use namespace dragonBones_internal;
	
	/** @private */
	public final class SlotTimelineState
	{
		private static const HALF_PI:Number = Math.PI * 0.5;
		private static const DOUBLE_PI:Number = Math.PI * 2;
		
		private static var _pool:Vector.<SlotTimelineState> = new Vector.<SlotTimelineState>;
		
		/** @private */
		dragonBones_internal static function borrowObject():SlotTimelineState
		{
			if(_pool.length == 0)
			{
				return new SlotTimelineState();
			}
			return _pool.pop();
		}
		
		/** @private */
		dragonBones_internal static function returnObject(timeline:SlotTimelineState):void
		{
			if(_pool.indexOf(timeline) < 0)
			{
				_pool[_pool.length] = timeline;
			}
			
			timeline.clear();
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
		}
		
		public var name:String;
		
		/** @private */
		dragonBones_internal var _weight:Number;
		
		//TO DO 干什么用的
		/** @private */
		dragonBones_internal var _blendEnabled:Boolean;
		
		/** @private */
		dragonBones_internal var _isComplete:Boolean;
		
		/** @private */
		dragonBones_internal var _animationState:AnimationState;
		
		private var _totalTime:int; //duration
		
		private var _currentTime:int;
		private var _currentFrameIndex:int;
		private var _currentFramePosition:int;
		private var _currentFrameDuration:int;
		
		private var _tweenEasing:Number;
		private var _tweenCurve:CurveData;
		private var _tweenColor:Boolean;
		
		private var _rawAnimationScale:Number;
		
		//-1: frameLength>1, 0:frameLength==0, 1:frameLength==1
		private var _updateMode:int;
		
		private var _armature:Armature;
		private var _animation:Animation;
		private var _slot:Slot;
		
		private var _timelineData:SlotTimeline;
		private var _durationColor:ColorTransform;
		
		
		public function SlotTimelineState()
		{
			_durationColor = new ColorTransform();
		}
		
		private function clear():void
		{
//			if(_slot)
//			{
//				_slot.removeState(this);
//				_slot = null;
//			}
			_slot = null;
			_armature = null;
			_animation = null;
			_animationState = null;
			_timelineData = null;
		}
		
	//动画开始结束
		/** @private */
		dragonBones_internal function fadeIn(slot:Slot, animationState:AnimationState, timelineData:SlotTimeline):void
		{
			_slot = slot;
			_armature = _slot.armature;
			_animation = _armature.animation;
			_animationState = animationState;
			_timelineData = timelineData;
			
			name = timelineData.name;
			
			_totalTime = _timelineData.duration;
			_rawAnimationScale = _animationState.clip.scale;
			
			_isComplete = false;
			_blendEnabled = false;
			_tweenColor = false;
			_currentFrameIndex = -1;
			_currentTime = -1;
			_tweenEasing = NaN;
			_weight = 1;
			
			switch(_timelineData.frameList.length)
			{
				case 0:
					_updateMode = 0;
					break;
				
				case 1:
					_updateMode = 1;
					break;
				
				default:
					_updateMode = -1;
					break;
			}
			
//			_slot.addState(this);
		}
		
	//动画进行中
		
		/** @private */
		dragonBones_internal function update(progress:Number):void
		{
			if(_updateMode == -1)
			{
				updateMultipleFrame(progress);
			}
			else if(_updateMode == 1)
			{
				_updateMode = 0;
				updateSingleFrame();
			}
		}
		
		private function updateMultipleFrame(progress:Number):void
		{
			var currentPlayTimes:int = 0;
			progress /= _timelineData.scale;
			progress += _timelineData.offset;
			
			var currentTime:int = _totalTime * progress;
			var playTimes:int = _animationState.playTimes;
			if(playTimes == 0)
			{
				_isComplete = false;
				currentPlayTimes = Math.ceil(Math.abs(currentTime) / _totalTime) || 1;
				currentTime -= int(currentTime / _totalTime) * _totalTime;
				
				if(currentTime < 0)
				{
					currentTime += _totalTime;
				}
			}
			else
			{
				var totalTimes:int = playTimes * _totalTime;
				if(currentTime >= totalTimes)
				{
					currentTime = totalTimes;
					_isComplete = true;
				}
				else if(currentTime <= -totalTimes)
				{
					currentTime = -totalTimes;
					_isComplete = true;
				}
				else
				{
					_isComplete = false;
				}
				
				if(currentTime < 0)
				{
					currentTime += totalTimes;
				}
				
				currentPlayTimes = Math.ceil(currentTime / _totalTime) || 1;
				if(_isComplete)
				{
					currentTime = _totalTime;
				}
				else
				{
					currentTime -= int(currentTime / _totalTime) * _totalTime;
				}
			}
			
			if(_currentTime != currentTime)
			{
				_currentTime = currentTime;
				
				var frameList:Vector.<Frame> = _timelineData.frameList;
				var prevFrame:SlotFrame;
				var currentFrame:SlotFrame;
				
				for (var i:int = 0, l:int = _timelineData.frameList.length; i < l; ++i)
				{
					if(_currentFrameIndex < 0)
					{
						_currentFrameIndex = 0;
					}
					else if(_currentTime < _currentFramePosition || _currentTime >= _currentFramePosition + _currentFrameDuration)
					{
						_currentFrameIndex ++;
						if(_currentFrameIndex >= frameList.length)
						{
							if(_isComplete)
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
					currentFrame = frameList[_currentFrameIndex] as SlotFrame;
					
					if(prevFrame)
					{
						_slot.arriveAtFrame(prevFrame, this, _animationState, true);
					}
					
					_currentFrameDuration = currentFrame.duration;
					_currentFramePosition = currentFrame.position;
					prevFrame = currentFrame;
				}
				
				if(currentFrame)
				{
					_slot.arriveAtFrame(currentFrame, this, _animationState, false);
					
					_blendEnabled = currentFrame.displayIndex >= 0;
					if(_blendEnabled)
					{
						updateToNextFrame(currentPlayTimes);
					}
					else
					{
						_tweenEasing = NaN;
						_tweenColor = false;
					}
				}
				
				if(_blendEnabled)
				{
					updateTween();
				}
			}
		}
		
		private function updateToNextFrame(currentPlayTimes:int):void
		{
			var nextFrameIndex:int = _currentFrameIndex + 1;
			if(nextFrameIndex >= _timelineData.frameList.length)
			{
				nextFrameIndex = 0;
			}
			var currentFrame:SlotFrame = _timelineData.frameList[_currentFrameIndex] as SlotFrame;
			var nextFrame:SlotFrame = _timelineData.frameList[nextFrameIndex] as SlotFrame;
			var tweenEnabled:Boolean = false;
			if(
				nextFrameIndex == 0 &&
				(
					!_animationState.lastFrameAutoTween ||
					(
						_animationState.playTimes &&
						_animationState.currentPlayTimes >= _animationState.playTimes && 
						((_currentFramePosition + _currentFrameDuration) / _totalTime + currentPlayTimes - _timelineData.offset) * _timelineData.scale > 0.999999
					)
				)
			)
			{
				_tweenEasing = NaN;
				tweenEnabled = false;
			}
			else if(currentFrame.displayIndex < 0 || nextFrame.displayIndex < 0)
			{
				_tweenEasing = NaN;
				tweenEnabled = false;
			}
			else if(_animationState.autoTween)
			{
				_tweenEasing = _animationState.clip.tweenEasing;
				if(isNaN(_tweenEasing))
				{
					_tweenEasing = currentFrame.tweenEasing;
					_tweenCurve = currentFrame.curve;
					if(isNaN(_tweenEasing) && _tweenCurve == null)    //frame no tween
					{
						tweenEnabled = false;
					}
					else
					{
						if(_tweenEasing == 10)
						{
							_tweenEasing = 0;
						}
						//_tweenEasing [-1, 0) 0 (0, 1] (1, 2]
						tweenEnabled = true;
					}
				}
				else    //animationData overwrite tween
				{
					//_tweenEasing [-1, 0) 0 (0, 1] (1, 2]
					tweenEnabled = true;
				}
			}
			else
			{
				_tweenEasing = currentFrame.tweenEasing;
				_tweenCurve = currentFrame.curve;
				if((isNaN(_tweenEasing) || _tweenEasing == 10) && _tweenCurve == null)   //frame no tween
				{
					_tweenEasing = NaN;
					tweenEnabled = false;
				}
				else
				{
					//_tweenEasing [-1, 0) 0 (0, 1] (1, 2]
					tweenEnabled = true;
				}
			}
			
			if(tweenEnabled)
			{
				if(currentFrame.color && nextFrame.color)
				{
					_durationColor.alphaOffset = nextFrame.color.alphaOffset - currentFrame.color.alphaOffset;
					_durationColor.redOffset = nextFrame.color.redOffset - currentFrame.color.redOffset;
					_durationColor.greenOffset = nextFrame.color.greenOffset - currentFrame.color.greenOffset;
					_durationColor.blueOffset = nextFrame.color.blueOffset - currentFrame.color.blueOffset;
					
					_durationColor.alphaMultiplier = nextFrame.color.alphaMultiplier - currentFrame.color.alphaMultiplier;
					_durationColor.redMultiplier = nextFrame.color.redMultiplier - currentFrame.color.redMultiplier;
					_durationColor.greenMultiplier = nextFrame.color.greenMultiplier - currentFrame.color.greenMultiplier;
					_durationColor.blueMultiplier = nextFrame.color.blueMultiplier - currentFrame.color.blueMultiplier;
					
					if(
						_durationColor.alphaOffset ||
						_durationColor.redOffset ||
						_durationColor.greenOffset ||
						_durationColor.blueOffset ||
						_durationColor.alphaMultiplier ||
						_durationColor.redMultiplier ||
						_durationColor.greenMultiplier ||
						_durationColor.blueMultiplier 
					)
					{
						_tweenColor = true;
					}
					else
					{
						_tweenColor = false;
					}
				}
				else if(currentFrame.color)
				{
					_tweenColor = true;
					_durationColor.alphaOffset = -currentFrame.color.alphaOffset;
					_durationColor.redOffset = -currentFrame.color.redOffset;
					_durationColor.greenOffset = -currentFrame.color.greenOffset;
					_durationColor.blueOffset = -currentFrame.color.blueOffset;
					
					_durationColor.alphaMultiplier = 1 - currentFrame.color.alphaMultiplier;
					_durationColor.redMultiplier = 1 - currentFrame.color.redMultiplier;
					_durationColor.greenMultiplier = 1 - currentFrame.color.greenMultiplier;
					_durationColor.blueMultiplier = 1 - currentFrame.color.blueMultiplier;
				}
				else if(nextFrame.color)
				{
					_tweenColor = true;
					_durationColor.alphaOffset = nextFrame.color.alphaOffset;
					_durationColor.redOffset = nextFrame.color.redOffset;
					_durationColor.greenOffset = nextFrame.color.greenOffset;
					_durationColor.blueOffset = nextFrame.color.blueOffset;
					
					_durationColor.alphaMultiplier = nextFrame.color.alphaMultiplier - 1;
					_durationColor.redMultiplier = nextFrame.color.redMultiplier - 1;
					_durationColor.greenMultiplier = nextFrame.color.greenMultiplier - 1;
					_durationColor.blueMultiplier = nextFrame.color.blueMultiplier - 1;
				}
				else
				{
					_tweenColor = false;
				}
			}
			else
			{
				_tweenColor = false;
			}
			
			if(!_tweenColor && _animationState.displayControl)
			{
				if(currentFrame.color)
				{
					_slot.updateDisplayColor(
						currentFrame.color.alphaOffset, 
						currentFrame.color.redOffset, 
						currentFrame.color.greenOffset, 
						currentFrame.color.blueOffset, 
						currentFrame.color.alphaMultiplier, 
						currentFrame.color.redMultiplier, 
						currentFrame.color.greenMultiplier, 
						currentFrame.color.blueMultiplier,
						true
					);
				}
				else if(_slot._isColorChanged)
				{
					_slot.updateDisplayColor(0, 0, 0, 0, 1, 1, 1, 1, false);
				}
				
			}
		}
		
		private function updateTween():void
		{			
			var currentFrame:SlotFrame = _timelineData.frameList[_currentFrameIndex] as SlotFrame;
			
			if(_tweenColor && _animationState.displayControl)
			{
				var progress:Number = (_currentTime - _currentFramePosition) / _currentFrameDuration;
				if (_tweenCurve != null)
				{
					progress = _tweenCurve.getValueByProgress(progress);
				}
				if(_tweenEasing)
				{
					progress = MathUtil.getEaseValue(progress, _tweenEasing);
				}
			
				if(currentFrame.color)
				{
					_slot.updateDisplayColor(
						currentFrame.color.alphaOffset + _durationColor.alphaOffset * progress,
						currentFrame.color.redOffset + _durationColor.redOffset * progress,
						currentFrame.color.greenOffset + _durationColor.greenOffset * progress,
						currentFrame.color.blueOffset + _durationColor.blueOffset * progress,
						currentFrame.color.alphaMultiplier + _durationColor.alphaMultiplier * progress,
						currentFrame.color.redMultiplier + _durationColor.redMultiplier * progress,
						currentFrame.color.greenMultiplier + _durationColor.greenMultiplier * progress,
						currentFrame.color.blueMultiplier + _durationColor.blueMultiplier * progress,
						true
					);
				}
				else
				{
					_slot.updateDisplayColor(
						_durationColor.alphaOffset * progress,
						_durationColor.redOffset * progress,
						_durationColor.greenOffset * progress,
						_durationColor.blueOffset * progress,
						1 + _durationColor.alphaMultiplier * progress,
						1 + _durationColor.redMultiplier * progress,
						1 + _durationColor.greenMultiplier * progress,
						1 + _durationColor.blueMultiplier * progress,
						true
					);
				}
			}
		}
		
		private function updateSingleFrame():void
		{
			var currentFrame:SlotFrame = _timelineData.frameList[0] as SlotFrame;
			_slot.arriveAtFrame(currentFrame, this, _animationState, false);
			_isComplete = true;
			_tweenEasing = NaN;
			_tweenColor = false;
			
			_blendEnabled = currentFrame.displayIndex >= 0;
			if(_blendEnabled)
			{
				/**
				 * <使用绝对数据>
				 * 单帧的timeline，第一个关键帧的transform为0
				 * timeline.originTransform = firstFrame.transform;
				 * eachFrame.transform = eachFrame.transform - timeline.originTransform;
				 * firstFrame.transform == 0;
				 * 
				 * <使用相对数据>
				 * 使用相对数据时，timeline.originTransform = 0，第一个关键帧的transform有可能不为 0
				 */
				if(_animationState.displayControl)
				{
					if(currentFrame.color)
					{
						_slot.updateDisplayColor(
							currentFrame.color.alphaOffset, 
							currentFrame.color.redOffset, 
							currentFrame.color.greenOffset, 
							currentFrame.color.blueOffset, 
							currentFrame.color.alphaMultiplier, 
							currentFrame.color.redMultiplier, 
							currentFrame.color.greenMultiplier, 
							currentFrame.color.blueMultiplier,
							true
						);
					}
					else if(_slot._isColorChanged)
					{
						_slot.updateDisplayColor(0, 0, 0, 0, 1, 1, 1, 1, false);
					}
				}
			}
		}
		
		
	}
}
