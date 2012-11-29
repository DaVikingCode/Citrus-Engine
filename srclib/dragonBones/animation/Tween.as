package dragonBones.animation
{
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.events.FrameEvent;
	import dragonBones.events.SoundEvent;
	import dragonBones.events.SoundEventManager;
	import dragonBones.objects.FrameData;
	import dragonBones.objects.MovementBoneData;
	import dragonBones.objects.TweenNode;
	import dragonBones.objects.Node;
	import dragonBones.utils.dragonBones_internal;
	
	use namespace dragonBones_internal;
	
	/**
	 * A core object that can control the state of a bone
	 * @see dragonBones.Bone
	 */
	final public class Tween extends ProcessBase
	{
		private static const HALF_PI:Number = Math.PI * 0.5;
		
		private static var _soundManager:SoundEventManager = SoundEventManager.getInstance();
		
		private var _bone:Bone;
		
		/** @private */
		dragonBones_internal var _node:Node;
		
		private var _from:Node;
		private var _between:TweenNode;
		
		private var _movementBoneData:MovementBoneData;
		
		private var _currentKeyFrame:FrameData;
		private var _nextKeyFrame:FrameData;
		private var _isTweenKeyFrame:Boolean;
		private var _betweenDuration:int;
		private var _totalDuration:int;
		private var _frameTweenEasing:Number;
		
		/**
		 * @inheritDoc
		 */
		override public function set timeScale(value:Number):void
		{
			super.timeScale = value;
			
			var childArmature:Armature = _bone.childArmature;
			if(childArmature)
			{
				childArmature.animation.timeScale = value;
			}
		}
		
		/**
		 * Creates a new <code>Tween</code>
		 * @param	bone
		 */
		public function Tween(bone:Bone)
		{
			super();
			_bone = bone;
			_node = new Node();
			_from = new Node();
			_between = new TweenNode();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			super.dispose();
			_bone = null;
			_node = null;
			_from = null;
			_between = null;
			
			_movementBoneData = null;
			_currentKeyFrame = null;
			_nextKeyFrame = null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function gotoAndPlay(movementBoneData:Object, durationTo:int = 0, durationTween:int = 0, loop:* = false, tweenEasing:Number = NaN):void
		{
			_movementBoneData = movementBoneData as MovementBoneData;
			if(!_movementBoneData)
			{
				return;
			}
			_currentKeyFrame = null;
			_nextKeyFrame = null;
			_isTweenKeyFrame = false;
			super.gotoAndPlay(null, durationTo, durationTween, loop, tweenEasing);
			//
			_totalDuration = 0;
			_betweenDuration = 0;
			_toIndex = 0;
			_node.skewY %= 360;
			var frameData:FrameData;
			var length:uint = _movementBoneData._frameList.length;
			
			if (length == 1)
			{
				_loop = SINGLE;
				_nextKeyFrame = _movementBoneData._frameList[0];
				setBetween(_node, _nextKeyFrame);
				_isTweenKeyFrame = true;
				_frameTweenEasing = 1;
			}
			else if (length > 1)
			{
				if (loop) {
					_loop = LIST_LOOP_START;
					_duration = _movementBoneData.duration;
				}else {
					_loop = LIST_START;
					_duration = _movementBoneData.duration - 1;
				}
				_durationTween = durationTween * _movementBoneData.scale;
				if (loop && _movementBoneData.delay != 0)
				{
					setBetween(_node, tweenNodeTo(updateFrameData(1 -_movementBoneData.delay), _between));
				}
				else
				{
					_nextKeyFrame = _movementBoneData._frameList[0];
					setBetween(_node, _nextKeyFrame);
					_isTweenKeyFrame = true;
				}
			}
		}
		/**
		 * @inheritDoc
		 */
		override public function play():void
		{
			if (!_movementBoneData)
			{
				return;
			}
			
			if(_isPause)
			{
				super.play();
				var childArmature:Armature = _bone.childArmature;
				if(childArmature)
				{
					childArmature.animation.play();
				}
			}
			else if(_isComplete)
			{
				gotoAndPlay(_movementBoneData);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function stop():void
		{
			super.stop();
			var childArmature:Armature = _bone.childArmature;
			if(childArmature)
			{
				childArmature.animation.stop();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateHandler():void
		{
			if (_currentPrecent >= 1)
			{
				switch(_loop)
				{
					case SINGLE:
						_currentKeyFrame = _nextKeyFrame;
						_currentPrecent = 1;
						_isComplete = true;
						break;
					case LIST_START:
						_loop = LIST;
						if (_durationTween <= 0)
						{
							_currentPrecent = 1;
						}
						else
						{
							_currentPrecent = (_currentPrecent - 1) * _totalFrames / _durationTween;
						}
						
						if (_currentPrecent >= 1)
						{
							//the speed of playing is too fast or the durationTween is too short
							_currentPrecent = 1;
							_isComplete = true;
							break;
						}
						_totalFrames = _durationTween;
						_totalDuration = 0;
						break;
					case LIST:
						_currentPrecent = 1;
						_isComplete = true;
						break;
					case LIST_LOOP_START:
						_loop = 0;
						_totalFrames = _durationTween > 0?_durationTween:1;
						if (_movementBoneData.delay != 0)
						{
							//
							_currentFrame = (1 - _movementBoneData.delay) * _totalFrames;
							_currentPrecent += _currentFrame / _totalFrames;
						}
						_currentPrecent %= 1;
						break;
					default:
						//change the loop
						_loop += int(_currentPrecent);
						_currentPrecent %= 1;
						
						_totalDuration = 0;
						_betweenDuration = 0;
						_toIndex = 0;
						break;
				}
			}
			else if (_loop < -1)
			{
				_currentPrecent = Math.sin(_currentPrecent * HALF_PI);
			}
			
			if (_loop >= LIST)
			{
				//multiple key frame process
				_currentPrecent = updateFrameData(_currentPrecent, true);
			}
			
			if (!isNaN(_frameTweenEasing))
			{
				tweenNodeTo(_currentPrecent);
			}
			else if(_currentKeyFrame)
			{
				tweenNodeTo(0);
			}
			
			if(_currentKeyFrame)
			{
				//arrived
				var displayIndex:int = _currentKeyFrame.displayIndex;
				if(displayIndex >= 0)
				{
					if(_bone.global.z != _currentKeyFrame.z)
					{
						_bone.global.z = _currentKeyFrame.z;
						if(_bone.armature)
						{
							_bone.armature._bonesIndexChanged = true;
						}
					}
				}
				_bone.changeDisplay(displayIndex);
				
				if(_currentKeyFrame.event && _bone._armature.hasEventListener(FrameEvent.BONE_FRAME_EVENT))
				{
					
					var frameEvent:FrameEvent = new FrameEvent(FrameEvent.BONE_FRAME_EVENT);
					frameEvent.movementID = _bone._armature.animation.movementID;
					frameEvent.frameLabel = _currentKeyFrame.event;
					frameEvent._bone = _bone;
					_bone._armature.dispatchEvent(frameEvent);
				}
				if(_currentKeyFrame.sound && _soundManager.hasEventListener(SoundEvent.SOUND))
				{
					var soundEvent:SoundEvent = new SoundEvent(SoundEvent.SOUND);
					soundEvent.movementID = _bone._armature.animation.movementID;
					soundEvent.sound = _currentKeyFrame.sound;
					soundEvent._armature = _bone._armature;
					soundEvent._bone = _bone;
					_soundManager.dispatchEvent(soundEvent);
				}
				if(_currentKeyFrame.movement)
				{
					var childAramture:Armature = _bone.childArmature;
					if(childAramture)
					{
						childAramture.animation.gotoAndPlay(_currentKeyFrame.movement);
					}
				}
				_currentKeyFrame = null;
			}
			if(_isTweenKeyFrame)
			{
				//to
				/*if(nextKeyFrame.displayIndex < 0){
					//bone.changeDisplay(nextKeyFrame.displayIndex);
					if(bone.armature){
						//bone.armature.bonesIndexChanged = true;
					}
				}*/
				_isTweenKeyFrame = false;
			}
		}
		
		private function setBetween(from:Node, to:Node):void
		{
			_from.copy(from);
			if(to is FrameData)
			{
				if((to as FrameData).displayIndex < 0)
				{
					_between.subtract(from, from);
					return;
				}
			}
			_between.subtract(from, to);
		}
		
		private function tweenNodeTo(value:Number, node:Node = null):Node
		{
			node = node || _node;
			node.x = _from.x + value * _between.x;
			node.y = _from.y + value * _between.y;
			node.scaleX = _from.scaleX + value * _between.scaleX;
			node.scaleY = _from.scaleY + value * _between.scaleY;
			node.skewX = _from.skewX + value * _between.skewX;
			node.skewY = _from.skewY + value * _between.skewY;
			return node;
		}
		
		private function updateFrameData(currentPrecent:Number, activeFrame:Boolean = false):Number
		{
			var played:Number = _duration * currentPrecent;
			var from:FrameData;
			var to:FrameData;
			//refind the current frame
			if (played >= _totalDuration || played < _totalDuration - _betweenDuration)
			{
				var length:int = _movementBoneData._frameList.length;
				do {
					_betweenDuration = _movementBoneData._frameList[_toIndex].duration;
					_totalDuration += _betweenDuration;
					var fromIndex:int = _toIndex;
					if (++_toIndex >= length)
					{
						_toIndex = 0;
					}
				}while (played >= _totalDuration);
				var isListEnd:Boolean = _loop == LIST && _toIndex == 0;
				if(isListEnd)
				{
					to = from = _movementBoneData._frameList[fromIndex];
				}
				else
				{
					from = _movementBoneData._frameList[fromIndex];
					to = _movementBoneData._frameList[_toIndex];
				}
				
				_frameTweenEasing = from.tweenEasing;
				if (activeFrame)
				{
					_currentKeyFrame = _nextKeyFrame;
					if(!isListEnd)
					{
						_nextKeyFrame = to;
						_isTweenKeyFrame = true;
					}
				}
				setBetween(from, to);
			}
			currentPrecent = 1 - (_totalDuration - played) / _betweenDuration;
			
			//NaN: no tweens;  -1: ease out; 0: linear; 1: ease in; 2: ease in&out
			var tweenEasing:Number;
			if (!isNaN(_frameTweenEasing))
			{
				tweenEasing = isNaN(_tweenEasing)?_frameTweenEasing:_tweenEasing;
				if (tweenEasing)
				{
					currentPrecent = getEaseValue(currentPrecent, tweenEasing);
				}
			}
			if(currentPrecent < 0)
			{
				currentPrecent %= 1;
				currentPrecent += 1;
			}
			return currentPrecent;
		}
		
		private function getEaseValue(value:Number, easing:Number):Number
		{
			if (easing > 1)
			{
				value = 0.5 * (1 - Math.cos(value * Math.PI ));
				easing -= 1;
			}
			else if (easing > 0)
			{
				value = Math.sin(value * HALF_PI);
			}
			else
			{
				value = 1 - Math.cos(value * HALF_PI);
				easing = -easing;
			}
			return value * easing + (1 - easing);
		}
	}
}