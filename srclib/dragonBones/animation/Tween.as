package dragonBones.animation
{
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.events.FrameEvent;
	import dragonBones.events.SoundEvent;
	import dragonBones.events.SoundEventManager;
	import dragonBones.objects.BoneTransform;
	import dragonBones.objects.FrameData;
	import dragonBones.objects.MovementBoneData;
	import dragonBones.utils.TransformUtils;
	import dragonBones.utils.dragonBones_internal;
	
	import flash.geom.ColorTransform;
	
	use namespace dragonBones_internal;
	
	/** @private */
	final public class Tween
	{
		private static const HALF_PI:Number = Math.PI * 0.5;
		
		private static var _soundManager:SoundEventManager = SoundEventManager.getInstance();
		
		//NaN: no tweens;  -1: ease out; 0: linear; 1: ease in; 2: ease in&out
		public static function getEaseValue(value:Number, easing:Number):Number
		{
			var valueEase:Number = 0;
			if(isNaN(easing))
			{
				return valueEase;
			}
			else if (easing > 1)
			{
				valueEase = 0.5 * (1 - Math.cos(value * Math.PI )) - value;
				easing -= 1;
			}
			else if (easing > 0)
			{
				valueEase = Math.sin(value * HALF_PI) - value;
			}
			else if (easing < 0)
			{
				valueEase = 1 - Math.cos(value * HALF_PI) - value;
				easing *= -1;
			}
			return valueEase * easing + value;
		}
		
		private var _bone:Bone;
		
		private var _movementBoneData:MovementBoneData;
		
		private var _node:BoneTransform;
		private var _colorTransform:ColorTransform;
		
		private var _currentNode:BoneTransform;
		private var _currentColorTransform:ColorTransform;
		
		private var _offSetNode:BoneTransform;
		private var _offSetColorTransform:ColorTransform;
		
		private var _currentFrameData:FrameData;
		private var _tweenEasing:Number;
		private var _frameTweenEasing:Number;
		
		private var _isPause:Boolean;
		private var _rawDuration:Number;
		private var _nextFrameDataTimeEdge:Number;
		private var _frameDuration:Number;
		private var _nextFrameDataID:int;
		private var _loop:int;
		
		dragonBones_internal var _differentColorTransform:Boolean;
		
		/**
		 * Creates a new <code>Tween</code>
		 * @param	bone
		 */
		public function Tween(bone:Bone)
		{
			super();
			
			_bone = bone;
			_node = _bone._tweenNode;
			_colorTransform = _bone._tweenColorTransform;
			
			_currentNode = new BoneTransform();
			_currentColorTransform = new ColorTransform();
			
			_offSetNode = new BoneTransform();
			_offSetColorTransform = new ColorTransform();
		}
		
		/** @private */
		internal function gotoAndPlay(movementBoneData:MovementBoneData, rawDuration:Number, loop:Boolean, tweenEasing:Number):void
		{
			if(!movementBoneData)
			{
				return;
			}
			_movementBoneData = movementBoneData;
			var totalFrames:uint = _movementBoneData._frameList.length;
			if(totalFrames == 0)
			{
				_bone.changeDisplay(-1);
				stop();
				return;
			}
			
			_node.skewX %= Math.PI * 2;
			_node.skewY %= Math.PI * 2;
			_isPause = false;
			_currentFrameData = null;
			_loop = loop?0:-1;
			
			_nextFrameDataTimeEdge = 0;
			_nextFrameDataID = 0;
			_rawDuration = rawDuration;
			_tweenEasing = tweenEasing;
			
			var nextFrameData:FrameData;
			if (totalFrames == 1)
			{
				_frameTweenEasing = 1;
				_rawDuration = 0;
				nextFrameData = _movementBoneData._frameList[0];
				setOffset(_bone._isOnStage?_node:nextFrameData.node, _colorTransform, nextFrameData.node, nextFrameData.colorTransform);
			}
			else if (loop && _movementBoneData.delay != 0)
			{
				getLoopListNode();
				setOffset(_bone._isOnStage?_node:_offSetNode, _colorTransform, _offSetNode, _offSetColorTransform);
				//nextFrameData = _movementBoneData._frameList[0];
			}
			else
			{
				_frameTweenEasing = 1;
				nextFrameData = _movementBoneData._frameList[0];
				setOffset(_bone._isOnStage?_node:nextFrameData.node, _colorTransform, nextFrameData.node, nextFrameData.colorTransform);
			}
			
			if(nextFrameData)
			{
				updateBoneDisplayIndex(nextFrameData);
			}
		}
		
		private function getLoopListNode():void
		{
			var playedTime:Number = _rawDuration * _movementBoneData.delay;
			var length:int = _movementBoneData._frameList.length;
			var nextFrameDataID:int = 0;
			var nextFrameDataTimeEdge:Number = 0;
			do 
			{
				var currentFrameDataID:int = nextFrameDataID;
				var frameDuration:Number = _movementBoneData._frameList[currentFrameDataID].duration;
				nextFrameDataTimeEdge += frameDuration;
				if (++ nextFrameDataID >= length)
				{
					nextFrameDataID = 0;
				}
			}
			while (playedTime >= nextFrameDataTimeEdge);
			
			var currentFrameData:FrameData = _movementBoneData._frameList[currentFrameDataID];
			var nextFrameData:FrameData = _movementBoneData._frameList[nextFrameDataID];
			
			
			if(nextFrameData.displayIndex >= 0 && _bone.armature.animation.tweenEnabled)
			{
				_frameTweenEasing = currentFrameData.tweenEasing;
			}
			else
			{
				_frameTweenEasing = NaN;
			}
			
			setOffset(currentFrameData.node, currentFrameData.colorTransform, nextFrameData.node, nextFrameData.colorTransform);
		
			var progress:Number = 1 - (nextFrameDataTimeEdge - playedTime) / frameDuration;
			
			var tweenEasing:Number = isNaN(_tweenEasing)?currentFrameData.tweenEasing:_tweenEasing;
			if (tweenEasing)
			{
				progress = getEaseValue(progress, tweenEasing);
			}
			
			TransformUtils.setOffSetNode(currentFrameData.node, nextFrameData.node, _offSetNode);
			TransformUtils.setTweenNode(_currentNode, _offSetNode, _offSetNode, progress);
			
			TransformUtils.setOffSetColorTransform(currentFrameData.colorTransform, nextFrameData.colorTransform, _offSetColorTransform);
			TransformUtils.setTweenColorTransform(_currentColorTransform, _offSetColorTransform, _offSetColorTransform, progress);

		}
		
		/** @private */
		internal function stop():void
		{
			_isPause = true;
		}
		
		/** @private */
		internal function advanceTime(progress:Number, playType:int):void
		{
			if(_isPause || !_movementBoneData)
			{
				return;
			}
			
			if(_rawDuration == 0)
			{
				playType = Animation.SINGLE;
				if(progress == 0)
				{
					progress = 1;
				}
			}
			
			if(playType == Animation.LOOP)
			{
				progress /= _movementBoneData.scale;
				progress += _movementBoneData.delay;
				var loop:int = progress;
				if(_loop != loop)
				{
					_nextFrameDataTimeEdge = 0;
					_nextFrameDataID = 0;
					_loop = loop;
				}
				progress -= loop;
				progress = updateFrameData(progress);
			}
			else if (playType == Animation.LIST)
			{
				progress = updateFrameData(progress, true);
			}
			else if (playType == Animation.SINGLE && progress == 1)
			{
				_currentFrameData = _movementBoneData._frameList[0];
				_isPause = true;
			}
			else
			{
				progress = Math.sin(progress * HALF_PI);
			}
			
			
			if (!isNaN(_frameTweenEasing) || _currentFrameData)
			{
				TransformUtils.setTweenNode(_currentNode, _offSetNode, _node, progress);
				
				if(_differentColorTransform)
				{
					TransformUtils.setTweenColorTransform(_currentColorTransform, _offSetColorTransform, _colorTransform, progress);
				}
			}
			
			if(_currentFrameData)
			{
				arriveFrameData(_currentFrameData);
				_currentFrameData = null;
			}
		}
		
		private function setOffset(currentNode:BoneTransform, currentColorTransform:ColorTransform, nextNode:BoneTransform, nextColorTransform:ColorTransform, tweenRotate:int = 0):void
		{
			_currentNode.copy(currentNode);
			TransformUtils.setOffSetNode(_currentNode, nextNode, _offSetNode, tweenRotate);
			
			_currentColorTransform.alphaOffset = currentColorTransform.alphaOffset;
			_currentColorTransform.redOffset = currentColorTransform.redOffset;
			_currentColorTransform.greenOffset = currentColorTransform.greenOffset;
			_currentColorTransform.blueOffset = currentColorTransform.blueOffset;
			_currentColorTransform.alphaMultiplier = currentColorTransform.alphaMultiplier;
			_currentColorTransform.redMultiplier = currentColorTransform.redMultiplier;
			_currentColorTransform.greenMultiplier = currentColorTransform.greenMultiplier;
			_currentColorTransform.blueMultiplier = currentColorTransform.blueMultiplier;
			
			TransformUtils.setOffSetColorTransform(_currentColorTransform, nextColorTransform, _offSetColorTransform);
			
			if(
				_offSetColorTransform.alphaOffset != 0 ||
				_offSetColorTransform.redOffset != 0 ||
				_offSetColorTransform.greenOffset != 0 ||
				_offSetColorTransform.blueOffset != 0 ||
				_offSetColorTransform.alphaMultiplier != 0 ||
				_offSetColorTransform.redMultiplier != 0 ||
				_offSetColorTransform.greenMultiplier != 0 ||
				_offSetColorTransform.blueMultiplier != 0
			)
			{
				_differentColorTransform = true;
			}
			else
			{
				_differentColorTransform = false;
			}
		}
		
		private function updateBoneDisplayIndex(frameData:FrameData):void
		{
			var displayIndex:int = frameData.displayIndex;
			if(displayIndex >= 0)
			{
				if(_node.z != frameData.node.z)
				{
					_node.z = frameData.node.z;
					if(_bone.armature)
					{
						_bone.armature._bonesIndexChanged = true;
					}
				}
			}
			_bone.changeDisplay(displayIndex);
		}
		
		private function arriveFrameData(frameData:FrameData):void
		{
			updateBoneDisplayIndex(frameData);
			_bone._visible = frameData.visible;
			
			if(frameData.event && _bone._armature.hasEventListener(FrameEvent.BONE_FRAME_EVENT))
			{
				var frameEvent:FrameEvent = new FrameEvent(FrameEvent.BONE_FRAME_EVENT, false, _bone);
				frameEvent.movementID = _bone._armature.animation.movementID;
				frameEvent.frameLabel = frameData.event;
				_bone._armature.dispatchEvent(frameEvent);
			}
			if(frameData.sound && _soundManager.hasEventListener(SoundEvent.SOUND))
			{
				var soundEvent:SoundEvent = new SoundEvent(SoundEvent.SOUND);
				soundEvent.movementID = _bone._armature.animation.movementID;
				soundEvent.sound = frameData.sound;
				soundEvent._armature = _bone._armature;
				soundEvent._bone = _bone;
				_soundManager.dispatchEvent(soundEvent);
			}
			if(frameData.movement)
			{
				var childArmature:Armature = _bone.childArmature;
				if(childArmature)
				{
					childArmature.animation.gotoAndPlay(frameData.movement);
				}
			}
		}
		
		private function updateFrameData(progress:Number, isList:Boolean= false):Number
		{
			var playedTime:Number = _rawDuration * progress;
			if (playedTime >= _nextFrameDataTimeEdge)
			{
				var length:int = _movementBoneData._frameList.length;
				do 
				{
					var currentFrameDataID:int = _nextFrameDataID;
					_frameDuration = _movementBoneData._frameList[currentFrameDataID].duration;
					_nextFrameDataTimeEdge += _frameDuration;
					if (++ _nextFrameDataID >= length)
					{
						_nextFrameDataID = 0;
					}
				}
				while (playedTime >= _nextFrameDataTimeEdge);
				
				var currentFrameData:FrameData = _movementBoneData._frameList[currentFrameDataID];
				var nextFrameData:FrameData = _movementBoneData._frameList[_nextFrameDataID];
				
				if(nextFrameData.displayIndex >= 0 && _bone.armature.animation.tweenEnabled)
				{
					_frameTweenEasing = currentFrameData.tweenEasing;
				}
				else
				{
					_frameTweenEasing = NaN;
				}
				
				setOffset(currentFrameData.node, currentFrameData.colorTransform, nextFrameData.node, nextFrameData.colorTransform, nextFrameData.tweenRotate);
				
				_currentFrameData = currentFrameData;
				
				if(isList && _nextFrameDataID == 0)
				{
					_isPause = true;
					return 0;
				}
			}
			
			progress = 1 - (_nextFrameDataTimeEdge - playedTime) / _frameDuration;
			
			var tweenEasing:Number = isNaN(_tweenEasing)?_frameTweenEasing:_tweenEasing;
			if (isNaN(tweenEasing))
			{
				return 0;
			}
			else if(tweenEasing)
			{
				return getEaseValue(progress, tweenEasing);
			}
			
			return progress;
		}
	}
}