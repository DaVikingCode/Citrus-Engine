package dragonBones
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import dragonBones.animation.AnimationState;
	import dragonBones.animation.TimelineState;
	import dragonBones.core.DBObject;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.events.FrameEvent;
	import dragonBones.events.SoundEvent;
	import dragonBones.events.SoundEventManager;
	import dragonBones.objects.DBTransform;
	import dragonBones.objects.Frame;
	import dragonBones.objects.FrameCached;
	import dragonBones.objects.TimelineCached;
	import dragonBones.objects.TransformFrame;
	
	use namespace dragonBones_internal;
	
	public class Bone extends DBObject
	{
		/**
		 * The instance dispatch sound event.
		 */
		private static const _soundManager:SoundEventManager = SoundEventManager.getInstance();
		
		
		/**
		 * Unrecommended API. Recommend use slot.childArmature.
		 */
		public function get childArmature():Armature
		{
			var slot:Slot = this.slot;
			if(slot)
			{
				return slot.childArmature;
			}
			return null;
		}
		
		/**
		 * Unrecommended API. Recommend use slot.display.
		 */
		public function get display():Object
		{
			var slot:Slot = this.slot;
			if(slot)
			{
				return slot.display;
			}
			return null;
		}
		public function set display(value:Object):void
		{
			var slot:Slot = this.slot;
			if(slot)
			{
				slot.display = value;
			}
		}
		
		/**
		 * Unrecommended API. Recommend use offset.
		 */
		public function get node():DBTransform
		{
			return _offset;
		}
		
		/**
		 * AnimationState that slots belong to the bone will be controlled by.
		 * Sometimes, we want slots controlled by a spedific animation state when animation is doing mix or addition.
		 */
		public var displayController:String;
		
		/** @private */
		dragonBones_internal var _tween:DBTransform;
		
		/** @private */
		dragonBones_internal var _tweenPivot:Point;
		
		/** @private */
		dragonBones_internal var _needUpdate:int;
		
		/** @private */
		dragonBones_internal var _isColorChanged:Boolean;
		
		/** @private */
		dragonBones_internal var _frameCachedPosition:int;
		
		/** @private */
		dragonBones_internal var _frameCachedDuration:int;
		
		/** @private */
		dragonBones_internal var _timelineCached:TimelineCached;
		
		/** @private */
		protected var _boneList:Vector.<Bone>;
		
		/** @private */
		protected var _slotList:Vector.<Slot>;
		
		/** @private */
		protected var _timelineStateList:Vector.<TimelineState>;
		
		/** @private */
		override public function set visible(value:Boolean):void
		{
			if(this._visible != value)
			{
				this._visible = value;
				for each(var slot:Slot in _slotList)
				{
					slot.updateDisplayVisible(this._visible);
				}
			}
		}
		
		/** @private */
		override dragonBones_internal function setArmature(value:Armature):void
		{
			super.setArmature(value);
			
			var i:int = _boneList.length;
			while(i --)
			{
				_boneList[i].setArmature(this._armature);
			}
			
			i = _slotList.length;
			while(i --)
			{
				_slotList[i].setArmature(this._armature);
			}
		}
		
		public function get slot():Slot
		{
			return _slotList.length > 0?_slotList[0]:null;
		}
		
		/**
		 * Creates a Bone blank instance.
		 */
		public function Bone()
		{
			super();
			
			_tween = new DBTransform();
			_tweenPivot = new Point();
			_tween.scaleX = _tween.scaleY = 0;
			
			_boneList = new Vector.<Bone>;
			_boneList.fixed = true;
			_slotList = new Vector.<Slot>;
			_slotList.fixed = true;
			_timelineStateList = new Vector.<TimelineState>;
			
			_needUpdate = 2;
			_isColorChanged = false;
			_frameCachedPosition = -1;
			_frameCachedDuration = -1;
			
			this.inheritRotation = true;
			this.inheritScale = false;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			if(!_boneList)
			{
				return;
			}
			
			super.dispose();
			var i:int = _boneList.length;
			while(i --)
			{
				_boneList[i].dispose();
			}
			
			i = _slotList.length;
			while(i --)
			{
				_slotList[i].dispose();
			}
			
			_boneList.fixed = false;
			_boneList.length = 0;
			_slotList.fixed = false;
			_slotList.length = 0;
			_timelineStateList.length = 0;
			
			_tween = null;
			_tweenPivot = null;
			_boneList = null;
			_slotList = null;
			_timelineStateList = null;
			_timelineCached = null;
		}
		
		/**
		 * Force update the bone in next frame even if the bone is not moving.
		 */
		public function invalidUpdate():void
		{
			_needUpdate = 2;
		}
		
		/**
		 * If contains some bone or slot
		 * @param Slot or Bone instance
		 * @return Boolean
		 * @see dragonBones.core.DBObject
		 */
		public function contains(child:DBObject):Boolean
		{
			if(!child)
			{
				throw new ArgumentError();
			}
			if(child == this)
			{
				return false;
			}
			var ancestor:DBObject = child;
			while(!(ancestor == this || ancestor == null))
			{
				ancestor = ancestor.parent;
			}
			return ancestor == this;
		}
		
		/**
		 * Get all Bone instance associated with this bone.
		 * @return A Vector.&lt;Slot&gt; instance.
		 * @see dragonBones.Slot
		 */
		public function getBones(returnCopy:Boolean = true):Vector.<Bone>
		{
			return returnCopy?_boneList.concat():_boneList;
		}
		
		/**
		 * Get all Slot instance associated with this bone.
		 * @return A Vector.&lt;Slot&gt; instance.
		 * @see dragonBones.Slot
		 */
		public function getSlots(returnCopy:Boolean = true):Vector.<Slot>
		{
			return returnCopy?_slotList.concat():_slotList;
		}
		
		/**
		 * Add a bone or slot as child
		 * @param a Slot or Bone instance
		 * @see dragonBones.core.DBObject
		 */
		public function addChild(child:DBObject):void
		{
			if(!child)
			{
				throw new ArgumentError();
			}
			var bone:Bone = child as Bone;
			if(bone == this || (bone && bone.contains(this)))
			{
				throw new ArgumentError("An Bone cannot be added as a child to itself or one of its children (or children's children, etc.)");
			}
			
			if(child.parent)
			{
				child.parent.removeChild(child);
			}
			
			if(bone)
			{
				_boneList.fixed = false;
				_boneList[_boneList.length] = bone;
				_boneList.fixed = true;
				bone.setParent(this);
				bone.setArmature(this._armature);
			}
			else if(child is Slot)
			{
				var slot:Slot = child as Slot;
				_slotList.fixed = false;
				_slotList[_slotList.length] = slot;
				_slotList.fixed = true;
				slot.setParent(this);
				slot.setArmature(this._armature);
			}
		}
		
		/**
		 * remove a child bone or slot
		 * @param a Slot or Bone instance
		 * @see dragonBones.core.DBObject
		 */
		public function removeChild(child:DBObject):void
		{
			if(!child)
			{
				throw new ArgumentError();
			}
			
			var index:int;
			if(child is Bone)
			{
				var bone:Bone = child as Bone;
				index = _boneList.indexOf(bone);
				if(index >= 0)
				{
					_boneList.fixed = false;
					_boneList.splice(index, 1);
					_boneList.fixed = true;
					bone.setParent(null);
					bone.setArmature(null);
				}
				else
				{
					throw new ArgumentError();
				}
			}
			else if(child is Slot)
			{
				var slot:Slot = child as Slot;
				index = _slotList.indexOf(slot);
				if(index >= 0)
				{
					_slotList.fixed = false;
					_slotList.splice(index, 1);
					_slotList.fixed = true;
					slot.setParent(null);
					slot.setArmature(null);
				}
				else
				{
					throw new ArgumentError();
				}
			}
		}
		
		/** @private */
		dragonBones_internal function update(needUpdate:Boolean = false):void
		{
			_needUpdate --;
			if(needUpdate || _needUpdate > 0 || (this._parent && this._parent._needUpdate > 0))
			{
				_needUpdate = 1;
			}
			else
			{
				return;
			}
			
			if(_frameCachedPosition >= 0 && _frameCachedDuration <= 0)
			{
				var frameCached:FrameCached = _timelineCached.timeline[_frameCachedPosition];
				var transform:DBTransform = frameCached.transform;
				this._global.x = transform.x;
				this._global.y = transform.x;
				this._global.skewX = transform.skewX;
				this._global.skewY = transform.skewY;
				this._global.scaleX = transform.scaleX;
				this._global.scaleY = transform.scaleY;
				//this._global.copy(_frameCached.transform);
				
				var matrix:Matrix = frameCached.matrix;
				this._globalTransformMatrix.a = matrix.a;
				this._globalTransformMatrix.b = matrix.b;
				this._globalTransformMatrix.c = matrix.c;
				this._globalTransformMatrix.d = matrix.d;
				this._globalTransformMatrix.tx = matrix.tx;
				this._globalTransformMatrix.ty = matrix.ty;
				//this._globalTransformMatrix.copyFrom(_frameCached.matrix);
				return;
			}
			
			blendingTimeline();
			
			this._global.scaleX = (this._origin.scaleX + _tween.scaleX) * this._offset.scaleX;
			this._global.scaleY = (this._origin.scaleY + _tween.scaleY) * this._offset.scaleY;
			
			if(this._parent)
			{
				var x:Number = this._origin.x + this._offset.x + _tween.x;
				var y:Number = this._origin.y + this._offset.y + _tween.y;
				var parentMatrix:Matrix = this._parent._globalTransformMatrix;
				
				this._globalTransformMatrix.tx = this._global.x = parentMatrix.a * x + parentMatrix.c * y + parentMatrix.tx;
				this._globalTransformMatrix.ty = this._global.y = parentMatrix.d * y + parentMatrix.b * x + parentMatrix.ty;
				
				if(this.inheritRotation)
				{
					this._global.skewX = this._origin.skewX + this._offset.skewX + _tween.skewX + this._parent._global.skewX;
					this._global.skewY = this._origin.skewY + this._offset.skewY + _tween.skewY + this._parent._global.skewY;
				}
				else
				{
					this._global.skewX = this._origin.skewX + this._offset.skewX + _tween.skewX;
					this._global.skewY = this._origin.skewY + this._offset.skewY + _tween.skewY;
				}
				
				if(this.inheritScale)
				{
					this._global.scaleX *= this._parent._global.scaleX;
					this._global.scaleY *= this._parent._global.scaleY;
				}
			}
			else
			{
				this._globalTransformMatrix.tx = this._global.x = this._origin.x + this._offset.x + _tween.x;
				this._globalTransformMatrix.ty = this._global.y = this._origin.y + this._offset.y + _tween.y;
				
				this._global.skewX = this._origin.skewX + this._offset.skewX + _tween.skewX;
				this._global.skewY = this._origin.skewY + this._offset.skewY + _tween.skewY;
			}
			
			/*
			this._globalTransformMatrix.a = this._global.scaleX * Math.cos(this._global.skewY);
			this._globalTransformMatrix.b = this._global.scaleX * Math.sin(this._global.skewY);
			this._globalTransformMatrix.c = -this._global.scaleY * Math.sin(this._global.skewX);
			this._globalTransformMatrix.d = this._global.scaleY * Math.cos(this._global.skewX);
			*/
			
			this._globalTransformMatrix.a = this._offset.scaleX * Math.cos(this._global.skewY);
			this._globalTransformMatrix.b = this._offset.scaleX * Math.sin(this._global.skewY);
			this._globalTransformMatrix.c = -this._offset.scaleY * Math.sin(this._global.skewX);
			this._globalTransformMatrix.d = this._offset.scaleY * Math.cos(this._global.skewX);
			
			if(_frameCachedDuration > 0)    // && _frameCachedPosition >= 0
			{
				_timelineCached.addFrame(this._global, this._globalTransformMatrix, _frameCachedPosition, _frameCachedDuration);
			}
		}
		
		/** @private When bone timeline enter a key frame, call this func*/
		dragonBones_internal function arriveAtFrame(frame:Frame, timelineState:TimelineState, animationState:AnimationState, isCross:Boolean):void
		{
			var displayControl:Boolean = 
				animationState.displayControl &&
				(!displayController || displayController == animationState.name) &&
				animationState.getMixingTransform(name) == 0
			
			if(displayControl)
			{
				var slot:Slot;
				
				if(frame)
				{
					var tansformFrame:TransformFrame = frame as TransformFrame;
					var displayIndex:int = tansformFrame.displayIndex;
					for each(slot in _slotList)
					{
						slot.changeDisplay(displayIndex);
						slot.updateDisplayVisible(tansformFrame.visible);
						if(displayIndex >= 0)
						{
							if(!isNaN(tansformFrame.zOrder) && tansformFrame.zOrder != slot._tweenZOrder)
							{
								slot._tweenZOrder = tansformFrame.zOrder;
								this._armature._slotsZOrderChanged = true;
							}
						}
					}
					
					if(frame.event && this._armature.hasEventListener(FrameEvent.BONE_FRAME_EVENT))
					{
						var frameEvent:FrameEvent = new FrameEvent(FrameEvent.BONE_FRAME_EVENT);
						frameEvent.bone = this;
						frameEvent.animationState = animationState;
						frameEvent.frameLabel = frame.event;
						this._armature._eventList.push(frameEvent);
					}
					
					if(frame.sound && _soundManager.hasEventListener(SoundEvent.SOUND))
					{
						var soundEvent:SoundEvent = new SoundEvent(SoundEvent.SOUND);
						soundEvent.armature = this._armature;
						soundEvent.animationState = animationState;
						soundEvent.sound = frame.sound;
						_soundManager.dispatchEvent(soundEvent);
					}
					
					//[TODO]currently there is only gotoAndPlay belongs to frame action. In future, there will be more.  
					//后续会扩展更多的action，目前只有gotoAndPlay的含义
					if(frame.action) 
					{
						for each(slot in _slotList)
						{
							var childArmature:Armature = slot.childArmature;
							if(childArmature)
							{
								childArmature.animation.gotoAndPlay(frame.action);
							}
						}
					}
				}
				else
				{
					for each(slot in _slotList)
					{
						slot.changeDisplay(-1);
					}
				}
			}
		}
		
		/** @private */
		dragonBones_internal function addState(timelineState:TimelineState):void
		{
			if(_timelineStateList.indexOf(timelineState) < 0)
			{
				_timelineStateList.push(timelineState);
				_timelineStateList.sort(sortState);
			}
		}
		
		/** @private */
		dragonBones_internal function removeState(timelineState:TimelineState):void
		{
			var index:int = _timelineStateList.indexOf(timelineState);
			if(index >= 0)
			{
				_timelineStateList.splice(index, 1);
			}
		}
		
		/** @private */
		dragonBones_internal function updateColor(
			aOffset:Number, 
			rOffset:Number, 
			gOffset:Number, 
			bOffset:Number, 
			aMultiplier:Number, 
			rMultiplier:Number, 
			gMultiplier:Number, 
			bMultiplier:Number,
			colorChanged:Boolean
		):void
		{
			for each(var slot:Slot in _slotList)
			{
				slot.updateDisplayColor(
					aOffset, rOffset, gOffset, bOffset, 
					aMultiplier, rMultiplier, gMultiplier, bMultiplier
				);
			}
			
			_isColorChanged = colorChanged;
		}
		
		private function blendingTimeline():void
		{
			var timelineState:TimelineState;
			var transform:DBTransform;
			var pivot:Point;
			var weight:Number;
			
			var i:int = _timelineStateList.length;
			if(i == 1)
			{
				timelineState = _timelineStateList[0];
				weight = timelineState.weight;
				transform = timelineState._transform;
				pivot = timelineState._pivot;
				
				_tween.x = transform.x * weight;
				_tween.y = transform.y * weight;
				_tween.skewX = transform.skewX * weight;
				_tween.skewY = transform.skewY * weight;
				_tween.scaleX = transform.scaleX * weight;
				_tween.scaleY = transform.scaleY * weight;
				//_tween.copy(transform);
				
				_tweenPivot.x = pivot.x * weight;
				_tweenPivot.y = pivot.y * weight;
				//_tweenPivot.copyFrom(pivot);
			}
			else if(i > 1)
			{
				var x:Number = 0;
				var y:Number = 0;
				var skewX:Number = 0;
				var skewY:Number = 0;
				var scaleX:Number = 0;
				var scaleY:Number = 0;
				var pivotX:Number = 0;
				var pivotY:Number = 0;
				
				var weigthLeft:Number = 1;
				var layerTotalWeight:Number = 0;
				var exLayer:int = _timelineStateList[i - 1].layer;
				var currentLayer:int;
				
				//Traversal the layer from up to down
				//layer由高到低依次遍历

				while(i --)
				{
					timelineState = _timelineStateList[i];
					
					currentLayer = timelineState.layer;
					if(exLayer != currentLayer)
					{
						if(layerTotalWeight >= weigthLeft)
						{
							break;
						}
						else
						{
							weigthLeft -= layerTotalWeight;
						}
					}
					exLayer = currentLayer;
					
					weight = timelineState.weight * weigthLeft;
					if(weight && timelineState._blendEnabled)
					{
						transform = timelineState._transform;
						pivot = timelineState._pivot;
						
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
				
				_tween.x = x;
				_tween.y = y;
				_tween.skewX = skewX;
				_tween.skewY = skewY;
				_tween.scaleX = scaleX;
				_tween.scaleY = scaleY;
				_tweenPivot.x = pivotX;
				_tweenPivot.y = pivotY;
			}
		}
		
		private function sortState(state1:TimelineState, state2:TimelineState):int
		{
			return state1.layer < state2.layer?-1:1;
		}
	}
}