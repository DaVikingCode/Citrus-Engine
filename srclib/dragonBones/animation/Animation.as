package dragonBones.animation
{
	/**
	 * Copyright 2012-2013. DragonBones. All Rights Reserved.
	 * @playerversion Flash 10.0
	 * @langversion 3.0
	 * @version 2.0
	 */
	import flash.geom.Point;
	
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.Slot;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.objects.AnimationData;
	import dragonBones.objects.DBTransform;
	
	use namespace dragonBones_internal;
	
	/**
	 * An Animation instance is used to control the animation state of an Armature.
	 * @example
	 * <p>Download the example files <a href='http://dragonbones.github.com/downloads/DragonBones_Tutorial_Assets.zip'>here</a>: </p>
	 * <listing>	
	 *	package  
	 *	{
	 *		import dragonBones.Armature;
	 *		import dragonBones.factorys.NativeFactory;
	 *  	import flash.display.Sprite;
	 *		import flash.events.Event;	
	 *
	 *		public class DragonAnimation extends Sprite 
	 *		{		
	 *			[Embed(source = "Dragon1.swf", mimeType = "application/octet-stream")]  
	 *			private static const ResourcesData:Class;
	 *			
	 *			private var factory:NativeFactory;
	 *			private var armature:Armature;		
	 *			
	 *			public function DragonAnimation() 
	 *			{				
	 *				factory = new NativeFactory();
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
	 *				armature.advanceTime(stage.frameRate / 1000);
	 *			}		
	 *		}
	 *	}
	 * </listing>
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
		 * Whether animation tweening is enabled or not.
		 */
		public var tweenEnabled:Boolean;
		
		/** @private */
		dragonBones_internal var _animationLayer:Vector.<Vector.<AnimationState>>;
		
		private var _armature:Armature;
		private var _isActive:Boolean;
		
		/**
		 * An vector containing all AnimationData names the Animation can play.
		 * @see dragonBones.objects.AnimationData.
		 */
		public function get movementList():Vector.<String>
		{
			return _animationList;
		}
		
		/**
		 * The name of the last AnimationData played.
		 * @see dragonBones.objects.AnimationData.
		 */
		public function get movementID():String
		{
			return _lastAnimationState?_lastAnimationState.name:null;
		}
		
		dragonBones_internal var _lastAnimationState:AnimationState;
		/**
		 * The last AnimationData this Animation played.
		 * @see dragonBones.objects.AnimationData.
		 */
		public function get lastAnimationState():AnimationState
		{
			return _lastAnimationState;
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
		public function get isPlaying():Boolean
		{
			return _isPlaying && _isActive;
		}
		
		public function get isComplete():Boolean
		{
			if(_lastAnimationState)
			{
				if(!_lastAnimationState.isComplete)
				{
					return false;
				}
				var j:int = _animationLayer.length;
				while(j --)
				{
					var animationStateList:Vector.<AnimationState> = _animationLayer[j];
					var i:int = animationStateList.length;
					while(i --)
					{
						if(!animationStateList[i].isComplete)
						{
							return false;
						}
					}
				}
				return true;
			}
			return false;
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
		
		private var _timeScale:Number = 1;
		/**
		 * The amount by which passed time should be scaled. Used to slow down or speed up animations. Defaults to 1.
		 */
		public function get timeScale():Number
		{
			return _timeScale;
		}
		public function set timeScale(value:Number):void
		{
			if (value < 0)
			{
				value = 0;
			}
			_timeScale = value;
		}
		
		/**
		 * Creates a new Animation instance and attaches it to the passed Armature.
		 * @param	An Armature to attach this Animation instance to.
		 */
		public function Animation(armature:Armature)
		{
			_armature = armature;
			_animationLayer = new Vector.<Vector.<AnimationState>>;
			_animationList = new Vector.<String>;
			
			_isPlaying = false;
			_isActive = false;
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
			stop();
			var i:int = _animationLayer.length;
			while(i --)
			{
				var animationStateList:Vector.<AnimationState> = _animationLayer[i];
				var j:int = animationStateList.length;
				while(j --)
				{
					AnimationState.returnObject(animationStateList[j]);
				}
				animationStateList.length = 0;
			}
			_animationLayer.length = 0;
			_animationList.length = 0;
			
			_armature = null;
			_animationLayer = null;
			_animationDataList = null;
			_animationList = null;
		}
		
		/**
		 * Move the playhead to that AnimationData
		 * @param animationName The name of the AnimationData to play.
		 * @param fadeInTime A fade time to apply (> 0)
		 * @param duration The duration of that AnimationData.
		 * @param loop Loop(0:loop forever, 1~+∞:loop times, -1~-∞:will fade animation after loop complete).
		 * @param layer The layer of the animation.
		 * @param group The group of the animation.
		 * @param fadeOutMode Fade out mode.
		 * @param displayControl Display control.
		 * @param pauseFadeOut Pause other animation playing.
		 * @param pauseFadeIn Pause this animation playing before fade in complete.
		 * @see dragonBones.objects.AnimationData.
		 * @see dragonBones.animation.AnimationState.
		 */
		public function gotoAndPlay(
			animationName:String, 
			fadeInTime:Number = -1, 
			duration:Number = -1, 
			loop:Number = NaN, 
			layer:uint = 0, 
			group:String = null,
			fadeOutMode:String = SAME_LAYER_AND_GROUP,
			displayControl:Boolean = true,
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
			
			//
			fadeInTime = fadeInTime < 0?(animationData.fadeInTime < 0?0.3:animationData.fadeInTime):fadeInTime;
			
			var durationScale:Number;
			if(duration < 0)
			{
				durationScale = animationData.scale < 0?1:animationData.scale;
			}
			else
			{
				durationScale = duration / animationData.duration;
			}
			
			loop = isNaN(loop)?animationData.loop:loop;
			layer = addLayer(layer);
			
			//autoSync = autoSync && !pauseFadeOut && !pauseFadeIn;
			var animationState:AnimationState;
			var animationStateList:Vector.<AnimationState>;
			switch(fadeOutMode)
			{
				case NONE:
					break;
				case SAME_LAYER:
					animationStateList = _animationLayer[layer];
					i = animationStateList.length;
					while(i --)
					{
						animationState = animationStateList[i];
						animationState.fadeOut(fadeInTime, pauseFadeOut);
					}
					break;
				case SAME_GROUP:
					j = _animationLayer.length;
					while(j --)
					{
						animationStateList = _animationLayer[j];
						i = animationStateList.length;
						while(i --)
						{
							animationState = animationStateList[i];
							if(animationState.group == group)
							{
								animationState.fadeOut(fadeInTime, pauseFadeOut);
							}
						}
					}
					break;
				case ALL:
					var j:int = _animationLayer.length;
					while(j --)
					{
						animationStateList = _animationLayer[j];
						i = animationStateList.length;
						while(i --)
						{
							animationState = animationStateList[i];
							animationState.fadeOut(fadeInTime, pauseFadeOut);
						}
					}
					break;
				case SAME_LAYER_AND_GROUP:
				default:
					animationStateList = _animationLayer[layer];
					i = animationStateList.length;
					while(i --)
					{
						animationState = animationStateList[i];
						if(animationState.group == group)
						{
							animationState.fadeOut(fadeInTime, pauseFadeOut);
						}
					}
					break;
			}
			
			_lastAnimationState = AnimationState.borrowObject();
			_lastAnimationState.group = group;
			_lastAnimationState.tweenEnabled = tweenEnabled;
			_lastAnimationState.fadeIn(_armature, animationData, fadeInTime, 1 / durationScale, loop, layer, displayControl, pauseFadeIn);
			
			addState(_lastAnimationState);
			
			var slotList:Vector.<Slot> = _armature._slotList;
			var slot:Slot;
			i = slotList.length;
			while(i --)
			{
				slot = slotList[i];
				if(slot.childArmature)
				{
					slot.childArmature.animation.gotoAndPlay(animationName, fadeInTime);
				}
			}
			
			_lastAnimationState.advanceTime(0);
			
			return _lastAnimationState;
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
		public function getState(name:String, layer:uint = 0):AnimationState
		{
			var l:int = _animationLayer.length;
			if(l == 0)
			{
				return null;
			}
			else if(layer >= l)
			{
				layer = l - 1;
			}
			
			var animationStateList:Vector.<AnimationState> = _animationLayer[layer];
			if(!animationStateList)
			{
				return null;
			}
			var i:int = animationStateList.length;
			while(i --)
			{
				if(animationStateList[i].name == name)
				{
					return animationStateList[i];
				}
			}
			
			return null;
		}
		
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
		
		public function advanceTime(passedTime:Number):void
		{
			/*
			if(!_isPlaying || !_isActive)
			{
				return;
			}
			*/
			passedTime *= _timeScale;
			
			var l:int = _armature._boneList.length;
			var i:int;
			var j:int;
			var k:int = l;
			var stateListLength:uint;
			var bone:Bone;
			var boneName:String;
			var weigthLeft:Number;
			
			var x:Number;
			var y:Number;
			var skewX:Number;
			var skewY:Number;
			var scaleX:Number;
			var scaleY:Number;
			var pivotX:Number;
			var pivotY:Number;
			
			var layerTotalWeight:Number;
			var animationStateList:Vector.<AnimationState>;
			var animationState:AnimationState;
			var timelineState:TimelineState;
			var weight:Number;
			var transform:DBTransform;
			var pivot:Point;
			
			l --;
			while(k --)
			{
				bone = _armature._boneList[k];
				boneName = bone.name;
				weigthLeft = 1;
				
				x = 0;
				y = 0;
				skewX = 0;
				skewY = 0;
				scaleX = 0;
				scaleY = 0;
				pivotX = 0;
				pivotY = 0;
				
				i = _animationLayer.length;
				while(i --)
				{
					layerTotalWeight = 0;
					animationStateList = _animationLayer[i];
					stateListLength = animationStateList.length;
					for(j = 0;j < stateListLength;j ++)
					{
						animationState = animationStateList[j];
						if(k == l)
						{
							if(animationState.advanceTime(passedTime))
							{
								removeState(animationState);
								j --;
								stateListLength --;
								continue;
							}
						}
						
						timelineState = animationState._timelineStates[boneName];
						
						if(timelineState && timelineState.tweenActive)
						{
							weight = animationState._fadeWeight * animationState.weight * weigthLeft;
							transform = timelineState.transform;
							pivot = timelineState.pivot;
							x += transform.x * weight;
							y += transform.y * weight;
							skewX += transform.skewX * weight;
							skewY += transform.skewY * weight;
							scaleX += transform.scaleX * weight;
							scaleY += transform.scaleY * weight;
							pivotX += pivot.x * weight;
							pivotY += pivot.y * weight;
							
							layerTotalWeight += weight;
						}
					}
					
					if(layerTotalWeight >= weigthLeft)
					{
						break;
					}
					else
					{
						weigthLeft -= layerTotalWeight;
					}
				}
				transform = bone._tween;
				pivot = bone._tweenPivot;
				
				transform.x = x;
				transform.y = y;
				transform.skewX = skewX;
				transform.skewY = skewY;
				transform.scaleX = scaleX;
				transform.scaleY = scaleY;
				pivot.x = pivotX;
				pivot.y = pivotY;
			}
		}
		
		/** @private */
		dragonBones_internal function setActive(animationState:AnimationState, active:Boolean):void
		{
			if(active)
			{
				_isActive = true;
			}
			else
			{
				var i:int = _animationLayer.length;
				var j:int;
				var animationStateList:Vector.<AnimationState>;
				while(i --)
				{
					animationStateList = _animationLayer[i];
					j = animationStateList.length;
					while(j --)
					{
						if(animationStateList[j].isPlaying)
						{
							return;
						}
					}
				}
				_isActive = false;
			}
		}
		
		private function addLayer(layer:uint):uint
		{
			if(layer >= _animationLayer.length)
			{
				layer = _animationLayer.length;
				_animationLayer[layer] = new Vector.<AnimationState>;
			}
			return layer;
		}
		
		private function addState(animationState:AnimationState):void
		{
			var animationStateList:Vector.<AnimationState> = _animationLayer[animationState.layer];
			animationStateList.push(animationState);
		}
		
		private function removeState(animationState:AnimationState):void
		{
			var layer:int = animationState.layer;
			var animationStateList:Vector.<AnimationState> = _animationLayer[layer];
			animationStateList.splice(animationStateList.indexOf(animationState), 1);
			
			AnimationState.returnObject(animationState);
			
			if(animationStateList.length == 0 && layer == _animationLayer.length - 1)
			{
				_animationLayer.length --;
			}
		}
	}
	
}