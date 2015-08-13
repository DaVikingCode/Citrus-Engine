package dragonBones.fast.animation
{
	import dragonBones.objects.CurveData;
	import flash.geom.Point;
	
	import dragonBones.core.dragonBones_internal;
	import dragonBones.fast.FastBone;
	import dragonBones.objects.DBTransform;
	import dragonBones.objects.Frame;
	import dragonBones.objects.TransformFrame;
	import dragonBones.objects.TransformTimeline;
	import dragonBones.utils.MathUtil;
	import dragonBones.utils.TransformUtil;

	use namespace dragonBones_internal;
	
	public class FastBoneTimelineState
	{
		private static var _pool:Vector.<FastBoneTimelineState> = new Vector.<FastBoneTimelineState>;
		
		/** @private */
		dragonBones_internal static function borrowObject():FastBoneTimelineState
		{
			if(_pool.length == 0)
			{
				return new FastBoneTimelineState();
			}
			return _pool.pop();
		}
		
		/** @private */
		dragonBones_internal static function returnObject(timeline:FastBoneTimelineState):void
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
		private var _totalTime:int; //duration
		private var _currentTime:int;
		private var _lastTime:int;
		private var _currentFrameIndex:int;
		private var _currentFramePosition:int;
		private var _currentFrameDuration:int;
		
		private var _bone:FastBone;
		private var _timelineData:TransformTimeline;
		private var _durationTransform:DBTransform;
		
		private var _tweenTransform:Boolean;
		private var _tweenEasing:Number;
		private var _tweenCurve:CurveData;
		
		private var _updateMode:int;
		private var _transformToFadein:DBTransform;
		/** @private */
		dragonBones_internal var _animationState:FastAnimationState;
		/** @private */
		dragonBones_internal var _isComplete:Boolean;
		/** @private */
		dragonBones_internal var _transform:DBTransform;

		
		public function FastBoneTimelineState()
		{
			_transform = new DBTransform();
			_durationTransform = new DBTransform();
			_transformToFadein = new DBTransform();
		}
		
		private function clear():void
		{
			if(_bone)
			{
				_bone._timelineState = null;
				_bone = null;
			}
			_animationState = null;
			_timelineData = null;
		}
		
		/** @private */
		dragonBones_internal function fadeIn(bone:FastBone, animationState:FastAnimationState, timelineData:TransformTimeline):void
		{
			_bone = bone;
			_animationState = animationState;
			_timelineData = timelineData;
			
			name = timelineData.name;
			
			_totalTime = _timelineData.duration;
			
			_isComplete = false;

			_tweenTransform = false;
			_currentFrameIndex = -1;
			_currentTime = -1;
			_tweenEasing = NaN;

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
			

			if(animationState._fadeTotalTime>0)
			{
				var pivotToFadein:Point;
				if(_bone._timelineState)
				{
					_transformToFadein.copy(_bone._timelineState._transform);
					
				}
				else
				{
					_transformToFadein = new DBTransform();
//					_pivotToFadein = new Point();
				}
				var firstFrame:TransformFrame = _timelineData.frameList[0] as TransformFrame;
				_durationTransform.copy(firstFrame.transform);
				_durationTransform.minus(this._transformToFadein);
//				_durationPivot.x = firstFrame.pivot.x - _pivotToFadein.x;
//				_durationPivot.y = firstFrame.pivot.y - _pivotToFadein.y;
			}
			
			_bone._timelineState = this;
		}
		
		/** @private */
		dragonBones_internal function updateFade(progress:Number):void
		{
			_transform.x = _transformToFadein.x + _durationTransform.x * progress;
			_transform.y = _transformToFadein.y + _durationTransform.y * progress;
			_transform.scaleX = _transformToFadein.scaleX * (1 + (_durationTransform.scaleX -1 ) * progress);
			_transform.scaleY = _transformToFadein.scaleX * (1 + (_durationTransform.scaleY -1 ) * progress);
			_transform.rotation = _transformToFadein.rotation + _durationTransform.rotation * progress;
			
			_bone.invalidUpdate();
		}
		
		/** @private */
		dragonBones_internal function update(progress:Number):void
		{
			if(_updateMode == 1)
			{
				_updateMode = 0;
				updateSingleFrame();
				
			}
			else if(_updateMode == -1)
			{
				updateMultipleFrame(progress);
			}
		}
		
		private function updateSingleFrame():void
		{
			var currentFrame:TransformFrame = _timelineData.frameList[0] as TransformFrame;
			_bone.arriveAtFrame(currentFrame, _animationState);
			_isComplete = true;
			_tweenEasing = NaN;
			_tweenTransform = false;

			_transform.copy(currentFrame.transform);
			
			_bone.invalidUpdate();
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
				_lastTime = _currentTime;
				_currentTime = currentTime;
				
				var frameList:Vector.<Frame> = _timelineData.frameList;
				var prevFrame:TransformFrame;
				var currentFrame:TransformFrame;
				
				for (var i:int = 0, l:int = _timelineData.frameList.length; i < l; ++i)
				{
					if(_currentFrameIndex < 0)
					{
						_currentFrameIndex = 0;
					}
					else if(_currentTime < _currentFramePosition || _currentTime >= _currentFramePosition + _currentFrameDuration || _currentTime < _lastTime)
					{
						_currentFrameIndex ++;
						_lastTime = _currentTime;
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
					currentFrame = frameList[_currentFrameIndex] as TransformFrame;
					
					if(prevFrame)
					{
						_bone.arriveAtFrame(prevFrame, _animationState);
					}
					
					_currentFrameDuration = currentFrame.duration;
					_currentFramePosition = currentFrame.position;
					prevFrame = currentFrame;
				}
				
				if(currentFrame)
				{
					_bone.arriveAtFrame(currentFrame, _animationState);
					updateToNextFrame(currentPlayTimes);
				}
				
				if(_tweenTransform)
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
			var currentFrame:TransformFrame = _timelineData.frameList[_currentFrameIndex] as TransformFrame;
			var nextFrame:TransformFrame = _timelineData.frameList[nextFrameIndex] as TransformFrame;
			var tweenEnabled:Boolean = false;
			if(nextFrameIndex == 0 &&( _animationState.playTimes &&
										_animationState.currentPlayTimes >= _animationState.playTimes && 
										((_currentFramePosition + _currentFrameDuration) / _totalTime + currentPlayTimes - _timelineData.offset)* _timelineData.scale > 0.999999
				))
			{
				_tweenEasing = NaN;
				tweenEnabled = false;
			}
			else if(_animationState.autoTween)
			{
				_tweenEasing = _animationState.animationData.tweenEasing;
				if(isNaN(_tweenEasing))
				{
					_tweenEasing = currentFrame.tweenEasing;
					_tweenCurve = currentFrame.curve;
					if(isNaN(_tweenEasing))    //frame no tween
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
				if(isNaN(_tweenEasing) || _tweenEasing == 10)    //frame no tween
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
				//transform
				_durationTransform.x = nextFrame.transform.x - currentFrame.transform.x;
				_durationTransform.y = nextFrame.transform.y - currentFrame.transform.y;
				_durationTransform.skewX = nextFrame.transform.skewX - currentFrame.transform.skewX;
				_durationTransform.skewY = nextFrame.transform.skewY - currentFrame.transform.skewY;
				
				_durationTransform.scaleX = nextFrame.transform.scaleX - currentFrame.transform.scaleX + nextFrame.scaleOffset.x;
				_durationTransform.scaleY = nextFrame.transform.scaleY - currentFrame.transform.scaleY + nextFrame.scaleOffset.y;
				_durationTransform.normalizeRotation();
				if(nextFrameIndex == 0)
				{
					_durationTransform.skewX = TransformUtil.formatRadian(_durationTransform.skewX);
					_durationTransform.skewY = TransformUtil.formatRadian(_durationTransform.skewY);
				}
				
				if(
					_durationTransform.x ||
					_durationTransform.y ||
					_durationTransform.skewX ||
					_durationTransform.skewY ||
					_durationTransform.scaleX != 1 ||
					_durationTransform.scaleY != 1 //||
				)
				{
					_tweenTransform = true;
				}
				else
				{
					_tweenTransform = false;
				}
				
			}
			else
			{
				_tweenTransform = false;
			}
			
			if(!_tweenTransform)
			{
				_transform.copy(currentFrame.transform);
				
				_bone.invalidUpdate();
			}
		}
		
		private function updateTween():void
		{
			var progress:Number = (_currentTime - _currentFramePosition) / _currentFrameDuration;
			if (_tweenCurve)
			{
				progress = _tweenCurve.getValueByProgress(progress);
			}
			if(_tweenEasing)
			{
				progress = MathUtil.getEaseValue(progress, _tweenEasing);
			}
			
			var currentFrame:TransformFrame = _timelineData.frameList[_currentFrameIndex] as TransformFrame;
			
			var currentTransform:DBTransform = currentFrame.transform;
			var currentPivot:Point = currentFrame.pivot;
			//normal blending
			_transform.x = currentTransform.x + _durationTransform.x * progress;
			_transform.y = currentTransform.y + _durationTransform.y * progress;
			_transform.skewX = currentTransform.skewX + _durationTransform.skewX * progress;
			_transform.skewY = currentTransform.skewY + _durationTransform.skewY * progress;
			_transform.scaleX = currentTransform.scaleX + _durationTransform.scaleX * progress;
			_transform.scaleY = currentTransform.scaleY + _durationTransform.scaleY * progress;

			_bone.invalidUpdate();
		}
	}
}