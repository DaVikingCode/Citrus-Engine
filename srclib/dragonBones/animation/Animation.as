package dragonBones.animation
{
	import dragonBones.Armature;
	import dragonBones.Slot;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.objects.AnimationData;
	
	use namespace dragonBones_internal;
	
	/**
	 * An Animation instance is used to control the animation state of an Armature.
	 * @see dragonBones.Armature
	 * @see dragonBones.animation.Animation
	 * @see dragonBones.animation.AnimationState
	 */
	public class Animation
	{
		public static const NONE:String = "none";
		public static const SAME_LAYER:String = "sameLayer";
		public static const SAME_GROUP:String = "sameGroup";
		public static const SAME_LAYER_AND_GROUP:String = "sameLayerAndGroup";
		public static const ALL:String = "all";
		
		/**
		* Unrecommended API. Recommend use animationList.
		*/
		public function get movementList():Vector.<String>
		{
			return _animationList;
		}
		
		/**
		* Unrecommended API. Recommend use lastAnimationName.
		*/
		public function get movementID():String
		{
			return lastAnimationName;
		}
		
		
		/**
		 * Whether animation tweening is enabled or not.
		 */
		public var tweenEnabled:Boolean;
		
		private var _armature:Armature;
		
		private var _animationStateList:Vector.<AnimationState>;
		
		/** @private */
		dragonBones_internal var _lastAnimationState:AnimationState;
		
		/** @private */
		dragonBones_internal var _isFading:Boolean
		
		/** @private */
		dragonBones_internal var _animationStateCount:int;
		
		/**
		 * The last AnimationState this Animation played.
		 * @see dragonBones.objects.AnimationData.
		 */
		public function get lastAnimationState():AnimationState
		{
			return _lastAnimationState;
		}
		/**
		 * The name of the last AnimationData played.
		 * @see dragonBones.objects.AnimationData.
		 */
		public function get lastAnimationName():String
		{
			return _lastAnimationState?_lastAnimationState.name:null;
		}
		
		private var _animationList:Vector.<String>;
		/**
		 * An vector containing all AnimationData names the Animation can play.
		 * @see dragonBones.objects.AnimationData.
		 */
		public function get animationList():Vector.<String>
		{
			return _animationList;
		}
		
		private var _isPlaying:Boolean;
		/**
		 * Is the animation playing.
		 * @see dragonBones.animation.AnimationState.
		 */
		public function get isPlaying():Boolean
		{
			return _isPlaying && !isComplete;
		}
		
		/**
		 * Is animation complete.
		 * @see dragonBones.animation.AnimationState.
		 */
		public function get isComplete():Boolean
		{
			if(_lastAnimationState)
			{
				if(!_lastAnimationState.isComplete)
				{
					return false;
				}
				var i:int = _animationStateList.length;
				while(i --)
				{
					if(!_animationStateList[i].isComplete)
					{
						return false;
					}
				}
				return true;
			}
			return true;
		}
		
		private var _timeScale:Number;
		/**
		 * The amount by which passed time should be scaled. Used to slow down or speed up animations. Defaults to 1.
		 */
		public function get timeScale():Number
		{
			return _timeScale;
		}
		public function set timeScale(value:Number):void
		{
			if(isNaN(value) || value < 0)
			{
				value = 1;
			}
			_timeScale = value;
		}
		
		private var _animationDataList:Vector.<AnimationData>;
		/**
		 * The AnimationData list associated with this Animation instance.
		 * @see dragonBones.objects.AnimationData.
		 */
		public function get animationDataList():Vector.<AnimationData>
		{
			return _animationDataList;
		}
		public function set animationDataList(value:Vector.<AnimationData>):void
		{
			_animationDataList = value;
			_animationList.length = 0;
			for each(var animationData:AnimationData in _animationDataList)
			{
				_animationList[_animationList.length] = animationData.name;
			}
		}
		
		/**
		 * Creates a new Animation instance and attaches it to the passed Armature.
		 * @param An Armature to attach this Animation instance to.
		 */
		public function Animation(armature:Armature)
		{
			_armature = armature;
			_animationList = new Vector.<String>;
			_animationStateList = new Vector.<AnimationState>;
			
			_timeScale = 1;
			_isPlaying = false;
			
			tweenEnabled = true;
		}
		
		/**
		 * Qualifies all resources used by this Animation instance for garbage collection.
		 */
		public function dispose():void
		{
			if(!_armature)
			{
				return;
			}
			var i:int = _animationStateList.length;
			while(i --)
			{
				AnimationState.returnObject(_animationStateList[i]);
			}
			_animationList.length = 0;
			_animationStateList.length = 0;
			
			_armature = null;
			_animationDataList = null;
			_animationList = null;
			_animationStateList = null;
		}
		
		/**
		 * Fades the animation with name animation in over a period of time seconds and fades other animations out.
		 * @param animationName The name of the AnimationData to play.
		 * @param fadeInTime A fade time to apply (>= 0), -1 means use xml data's fadeInTime. 
		 * @param duration The duration of that Animation. -1 means use xml data's duration.
		 * @param playTimes Play times(0:loop forever, >=1:play times, -1~-∞:will fade animation after play complete), 默认使用AnimationData.loop.
		 * @param layer The layer of the animation.
		 * @param group The group of the animation.
		 * @param fadeOutMode Fade out mode (none, sameLayer, sameGroup, sameLayerAndGroup, all).
		 * @param pauseFadeOut Pause other animation playing.
		 * @param pauseFadeIn Pause this animation playing before fade in complete.
		 * @return AnimationState.
		 * @see dragonBones.objects.AnimationData.
		 * @see dragonBones.animation.AnimationState.
		 */
		public function gotoAndPlay(
			animationName:String, 
			fadeInTime:Number = -1, 
			duration:Number = -1, 
			playTimes:Number = NaN, 
			layer:int = 0, 
			group:String = null,
			fadeOutMode:String = SAME_LAYER_AND_GROUP,
			pauseFadeOut:Boolean = true,
			pauseFadeIn:Boolean = true
		):AnimationState
		{
			if (!_animationDataList)
			{
				return null;
			}
			var i:int = _animationDataList.length;
			var animationData:AnimationData;
			while(i --)
			{
				if(_animationDataList[i].name == animationName)
				{
					animationData = _animationDataList[i];
					break;
				}
			}
			if (!animationData)
			{
				return null;
			}
			_isPlaying = true;
			_isFading = true;
			
			//
			fadeInTime = fadeInTime < 0?(animationData.fadeTime < 0?0.3:animationData.fadeTime):fadeInTime;
			var durationScale:Number;
			if(duration < 0)
			{
				durationScale = animationData.scale < 0?1:animationData.scale;
			}
			else
			{
				durationScale = duration * 0.001 / animationData.duration;
			}
			
			playTimes = isNaN(playTimes)?animationData.playTimes:playTimes;
			
			var animationState:AnimationState;
			switch(fadeOutMode)
			{
				case NONE:
					break;
				
				case SAME_LAYER:
					i = _animationStateList.length;
					while(i --)
					{
						animationState = _animationStateList[i];
						if(animationState.layer == layer)
						{
							animationState.fadeOut(fadeInTime, pauseFadeOut);
						}
					}
					break;
				
				case SAME_GROUP:
					i = _animationStateList.length;
					while(i --)
					{
						animationState = _animationStateList[i];
						if(animationState.group == group)
						{
							animationState.fadeOut(fadeInTime, pauseFadeOut);
						}
					}
					break;
				
				case ALL:
					i = _animationStateList.length;
					while(i --)
					{
						animationState = _animationStateList[i];
						animationState.fadeOut(fadeInTime, pauseFadeOut);
					}
					break;
				
				case SAME_LAYER_AND_GROUP:
				default:
					i = _animationStateList.length;
					while(i --)
					{
						animationState = _animationStateList[i];
						if(animationState.layer == layer && animationState.group == group )
						{
							animationState.fadeOut(fadeInTime, pauseFadeOut);
						}
					}
					break;
			}
			
			_lastAnimationState = AnimationState.borrowObject();
			_lastAnimationState._layer = layer;
			_lastAnimationState._group = group;
			_lastAnimationState.autoTween = tweenEnabled;
			_lastAnimationState.fadeIn(_armature, animationData, fadeInTime, 1 / durationScale, playTimes, pauseFadeIn);
			
			addState(_lastAnimationState);
			
			var slotList:Vector.<Slot> = _armature.getSlots(false);
			i = slotList.length;
			while(i --)
			{
				var slot:Slot = slotList[i];
				if(slot.childArmature)
				{
					slot.childArmature.animation.gotoAndPlay(animationName, fadeInTime);
				}
			}
			
			_lastAnimationState.advanceTime(0);
			
			return _lastAnimationState;
		}
		
		/**
		 * Control the animation to stop with a specified time. If related animationState haven't been created, then create a new animationState.
		 * @param animationName The name of the animationState.
		 * @param time 
		 * @param normalizedTime 
		 * @param fadeInTime A fade time to apply (>= 0), -1 means use xml data's fadeInTime. 
		 * @param duration The duration of that Animation. -1 means use xml data's duration.
		 * @param layer The layer of the animation.
		 * @param group The group of the animation.
		 * @param fadeOutMode Fade out mode (none, sameLayer, sameGroup, sameLayerAndGroup, all).
		 * @return AnimationState.
		 * @see dragonBones.objects.AnimationData.
		 * @see dragonBones.animation.AnimationState.
		 */
		public function gotoAndStop(
			animationName:String, 
			time:Number, 
			normalizedTime:Number = -1,
			fadeInTime:Number = 0, 
			duration:Number = -1, 
			layer:int = 0, 
			group:String = null, 
			fadeOutMode:String = ALL
		):AnimationState
		{
			var animationState:AnimationState = getState(animationName, layer);
			if(!animationState)
			{
				animationState = gotoAndPlay(animationName, fadeInTime, duration, NaN, layer, group, fadeOutMode);
			}
			
			if(normalizedTime >= 0)
			{
				animationState.setCurrentTime(animationState.totalTime * normalizedTime);
			}
			else
			{
				animationState.setCurrentTime(time);
			}
			
			animationState.stop();
			
			return animationState;
		}
		
		/**
		 * Play the animation from the current position.
		 */
		public function play():void
		{
			if (!_animationDataList || _animationDataList.length == 0)
			{
				return;
			}
			if(!_lastAnimationState)
			{
				gotoAndPlay(_animationDataList[0].name);
			}
			else if (!_isPlaying)
			{
				_isPlaying = true;
			}
			else
			{
				gotoAndPlay(_lastAnimationState.name);
			}
		}
		
		public function stop():void
		{
			_isPlaying = false;
		}
		
		/**
		 * Returns the AnimationState named name.
		 * @return A AnimationState instance.
		 * @see dragonBones.animation.AnimationState.
		 */
		public function getState(name:String, layer:int = 0):AnimationState
		{
			var i:int = _animationStateList.length;
			while(i --)
			{
				var animationState:AnimationState = _animationStateList[i];
				if(animationState.name == name && animationState.layer == layer)
				{
					return animationState;
				}
			}
			return null;
		}
		
		/**
		 * check if contains a AnimationData by name.
		 * @return Boolean.
		 * @see dragonBones.animation.AnimationData.
		 */
		public function hasAnimation(animationName:String):Boolean
		{
			var i:int = _animationDataList.length;
			while(i --)
			{
				if(_animationDataList[i].name == animationName)
				{
					return true;
				}
			}
			
			return false;
		}
		
		/** @private */
		dragonBones_internal function advanceTime(passedTime:Number):void
		{
			if(!_isPlaying)
			{
				return;
			}
			
			var isFading:Boolean = false;
			
			passedTime *= _timeScale;
			var i:int = _animationStateList.length;
			while(i --)
			{
				var animationState:AnimationState = _animationStateList[i];
				if(animationState.advanceTime(passedTime))
				{
					removeState(animationState);
				}
				else if(animationState.fadeState != 1)
				{
					isFading = true;
				}
			}
			
			_isFading = isFading;
		}
		
		/** @private */
		dragonBones_internal function updateAnimationStates():void
		{
			var i:int = _animationStateList.length;
			while(i --)
			{
				_animationStateList[i].updateTimelineStates();
			}
		}
		
		private function addState(animationState:AnimationState):void
		{
			if(_animationStateList.indexOf(animationState) < 0)
			{
				_animationStateList.unshift(animationState);
				
				_animationStateCount = _animationStateList.length;
			}
		}
		
		private function removeState(animationState:AnimationState):void
		{
			var index:int = _animationStateList.indexOf(animationState);
			if(index >= 0)
			{
				_animationStateList.splice(index, 1);
				AnimationState.returnObject(animationState);
				
				if(_lastAnimationState == animationState)
				{
					if(_animationStateList.length > 0)
					{
						_lastAnimationState = _animationStateList[0];
					}
					else
					{
						_lastAnimationState = null;
					}
				}
				
				_animationStateCount = _animationStateList.length;
			}
		}
	}
}
