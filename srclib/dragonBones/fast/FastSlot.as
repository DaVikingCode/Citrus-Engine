package dragonBones.fast {

	import dragonBones.cache.SlotFrameCache;
	import dragonBones.core.IArmature;
	import dragonBones.core.ISlotCacheGenerator;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.fast.animation.FastAnimationState;
	import dragonBones.objects.DisplayData;
	import dragonBones.objects.Frame;
	import dragonBones.objects.SlotData;
	import dragonBones.objects.SlotFrame;
	import dragonBones.utils.ColorTransformUtil;
	import dragonBones.utils.TransformUtil;

	import flash.errors.IllegalOperationError;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;

	use namespace dragonBones_internal;

	public class FastSlot extends FastDBObject implements ISlotCacheGenerator
	{
		/** @private Need to keep the reference of DisplayData. When slot switch displayObject, it need to restore the display obect's origional pivot. */
		dragonBones_internal var _displayDataList:Vector.<DisplayData>;
		/** @private */
		dragonBones_internal var _originZOrder:Number;
		/** @private */
		dragonBones_internal var _tweenZOrder:Number;
		/** @private */
		protected var _offsetZOrder:Number;
		
		protected var _displayList:Array;
		protected var _currentDisplayIndex:int;
		dragonBones_internal var _colorTransform:ColorTransform;
		dragonBones_internal var _isColorChanged:Boolean;
		protected var _currentDisplay:Object;
		
		protected var _blendMode:String;
		
		public var hasChildArmature:Boolean;
		public function FastSlot(self:FastSlot)
		{
			super();
			
			if(self != this)
			{
				throw new IllegalOperationError("Abstract class can not be instantiated!");
			}
			hasChildArmature = false;
			_currentDisplayIndex = -1;
			
			_originZOrder = 0;
			_tweenZOrder = 0;
			_offsetZOrder = 0;
			_colorTransform = new ColorTransform();
			_isColorChanged = false;
			_displayDataList = null;
			_currentDisplay = null;
			
			this.inheritRotation = true;
			this.inheritScale = true;
		}
		
		public function initWithSlotData(slotData:SlotData):void
		{
			name = slotData.name;
			blendMode = slotData.blendMode;
			_originZOrder = slotData.zOrder;
			_displayDataList = slotData.displayDataList;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			if(!_displayList)
			{
				return;
			}
			
			super.dispose();
			
			_displayDataList = null;
			_displayList = null;
			_currentDisplay = null;
		}
		
		//动画
		/** @private */
		override dragonBones_internal function updateByCache():void
		{
			super.updateByCache();
			updateTransform();
		//颜色
			var cacheColor:ColorTransform = (this._frameCache as SlotFrameCache).colorTransform;
			var cacheColorChanged:Boolean = cacheColor != null;
			if(	this.colorChanged != cacheColorChanged ||
				(this.colorChanged && cacheColorChanged && !ColorTransformUtil.isEqual(_colorTransform, cacheColor)))
			{
				cacheColor = cacheColor || ColorTransformUtil.originalColor;
				updateDisplayColor(	cacheColor.alphaOffset, 
									cacheColor.redOffset, 
									cacheColor.greenOffset, 
									cacheColor.blueOffset,
									cacheColor.alphaMultiplier, 
									cacheColor.redMultiplier, 
									cacheColor.greenMultiplier, 
									cacheColor.blueMultiplier,
									cacheColorChanged);
			}
			
		//displayIndex
			changeDisplayIndex((this._frameCache as SlotFrameCache).displayIndex);
		}
		
		/** @private */
		dragonBones_internal function update():void
		{
			if(this._parent._needUpdate <= 0)
			{
				return;
			}
			
			updateGlobal();
			updateTransform();
		}
		
		override protected function calculateRelativeParentTransform():void
		{
			_global.copy(this._origin);
		}
		
		dragonBones_internal function initDisplayList(newDisplayList:Array):void
		{
			this._displayList = newDisplayList;
		}
		
		private function clearCurrentDisplay():int
		{
			if(hasChildArmature)
			{
				var targetArmature:IArmature = this.childArmature as IArmature;
				if(targetArmature)
				{
					targetArmature.resetAnimation()
				}
			}
			if (_isColorChanged)
			{
				updateDisplayColor(0, 0, 0, 0, 1, 1, 1, 1, true);
			}
			var slotIndex:int = getDisplayIndex();
			removeDisplayFromContainer();
			return slotIndex;
		}
		
		/** @private */
		dragonBones_internal function changeDisplayIndex(displayIndex:int):void
		{
			if(_currentDisplayIndex == displayIndex)
			{
				return;
			}
			
			var slotIndex:int = -1;

			if(_currentDisplayIndex >=0)
			{
				slotIndex = clearCurrentDisplay();
			}
			
			_currentDisplayIndex = displayIndex;
			
			if(_currentDisplayIndex >=0)
			{
				this._origin.copy(_displayDataList[_currentDisplayIndex].transform);
				this.initCurrentDisplay(slotIndex);
			}
		}
		
		//currentDisplayIndex不变，改变内容，必须currentDisplayIndex >=0
		private function changeSlotDisplay(value:Object):void
		{
			var slotIndex:int = clearCurrentDisplay();
			_displayList[_currentDisplayIndex] = value;
			this.initCurrentDisplay(slotIndex);
		}
		
		private function initCurrentDisplay(slotIndex:int):void
		{
			var display:Object = _displayList[_currentDisplayIndex];
			if (display)
			{
				if(display is FastArmature)
				{
					_currentDisplay = (display as FastArmature).display;
				}
				else
				{
					_currentDisplay = display;
				}
			}
			else
			{
				_currentDisplay = null;
			}
			
			updateDisplay(_currentDisplay);
			if(_currentDisplay)
			{
				if(slotIndex != -1)
				{
					addDisplayToContainer(this.armature.display, slotIndex);
				}
				else
				{
					this.armature._slotsZOrderChanged = true;
					addDisplayToContainer(this.armature.display);
				}
				
				if(_blendMode)
				{
					updateDisplayBlendMode(_blendMode);
				}
				if(_isColorChanged)
				{
					updateDisplayColor(	_colorTransform.alphaOffset, 
						_colorTransform.redOffset, 
						_colorTransform.greenOffset, 
						_colorTransform.blueOffset,
						_colorTransform.alphaMultiplier, 
						_colorTransform.redMultiplier, 
						_colorTransform.greenMultiplier, 
						_colorTransform.blueMultiplier,
						true);
				}
				updateTransform();
				
				if(display is FastArmature)
				{
					var targetArmature:FastArmature = display as FastArmature;
					
					if(	this.armature &&
						this.armature.animation.animationState &&
						targetArmature.animation.hasAnimation(this.armature.animation.animationState.name))
					{
						targetArmature.animation.gotoAndPlay(this.armature.animation.animationState.name);
					}
					else
					{
						targetArmature.animation.play();
					}
				}
			}
		}
		
		/** @private */
		override public function set visible(value:Boolean):void
		{
			if(this._visible != value)
			{
				this._visible = value;
				updateDisplayVisible(this._visible);
			}
		}
		
		/**
		 * The DisplayObject list belonging to this Slot instance (display or armature). Replace it to implement switch texture.
		 */
		public function get displayList():Array
		{
			return _displayList;
		}
		public function set displayList(value:Array):void
		{
			//todo: 考虑子骨架变化的各种情况
			if(!value)
			{
				throw new ArgumentError();
			}
			
			var newDisplay:Object = value[_currentDisplayIndex];
			var displayChanged:Boolean = _currentDisplayIndex >= 0 && _displayList[_currentDisplayIndex] != newDisplay;
			
			_displayList = value;
			
			if(displayChanged)
			{
				changeSlotDisplay(newDisplay);
			}
		}
		
		/**
		 * The DisplayObject belonging to this Slot instance. Instance type of this object varies from flash.display.DisplayObject to startling.display.DisplayObject and subclasses.
		 */
		public function get display():Object
		{
			return _currentDisplay;
		}
		public function set display(value:Object):void
		{
			//todo: 考虑子骨架变化的各种情况进行进一步测试
			if (_currentDisplayIndex < 0)
			{
				_currentDisplayIndex = 0;
			}
			if(_displayList[_currentDisplayIndex] == value)
			{
				return;
			}
			
			changeSlotDisplay(value);
		}
		
		/**
		 * The sub-armature of this Slot instance.
		 */
		public function get childArmature():Object
		{
			return _displayList[_currentDisplayIndex] is IArmature ? _displayList[_currentDisplayIndex] : null;
		}
		
		public function set childArmature(value:Object):void
		{
			display = value;
		}
		/**
		 * zOrder. Support decimal for ensure dynamically added slot work toghther with animation controled slot.  
		 * @return zOrder.
		 */
		public function get zOrder():Number
		{
			return _originZOrder + _tweenZOrder + _offsetZOrder;
		}
		public function set zOrder(value:Number):void
		{
			if(zOrder != value)
			{
				_offsetZOrder = value - _originZOrder - _tweenZOrder;
				if(this.armature)
				{
					this.armature._slotsZOrderChanged = true;
				}
			}
		}
		
		/**
		 * blendMode
		 * @return blendMode.
		 */
		public function get blendMode():String
		{
			return _blendMode;
		}
		public function set blendMode(value:String):void
		{
			if(_blendMode != value)
			{
				_blendMode = value;
				updateDisplayBlendMode(_blendMode);
			}
		}
		
		/**
		 * Indicates the Bone instance that directly contains this DBObject instance if any.
		 */
		public function get colorTransform():ColorTransform
		{
			return _colorTransform;
		}
		
		public function get displayIndex():int
		{
			return _currentDisplayIndex;
		}
		
		public function get colorChanged():Boolean
		{
			return _isColorChanged;
		}
		
	//Abstract method
		/**
		 * @private
		 */
		dragonBones_internal function updateDisplay(value:Object):void
		{
			throw new IllegalOperationError("Abstract method needs to be implemented in subclass!");
		}
		
		/**
		 * @private
		 */
		dragonBones_internal function getDisplayIndex():int
		{
			throw new IllegalOperationError("Abstract method needs to be implemented in subclass!");
		}
		
		/**
		 * @private
		 * Adds the original display object to another display object.
		 * @param container
		 * @param index
		 */
		dragonBones_internal function addDisplayToContainer(container:Object, index:int = -1):void
		{
			throw new IllegalOperationError("Abstract method needs to be implemented in subclass!");
		}
		
		/**
		 * @private
		 * remove the original display object from its parent.
		 */
		dragonBones_internal function removeDisplayFromContainer():void
		{
			throw new IllegalOperationError("Abstract method needs to be implemented in subclass!");
		}
		
		/**
		 * @private
		 * Updates the transform of the slot.
		 */
		dragonBones_internal function updateTransform():void
		{
			throw new IllegalOperationError("Abstract method needs to be implemented in subclass!");
		}
		
		/**
		 * @private
		 */
		dragonBones_internal function updateDisplayVisible(value:Boolean):void
		{
			/**
			 * bone.visible && slot.visible && updateVisible
			 * this._parent.visible && this._visible && value;
			 */
			throw new IllegalOperationError("Abstract method needs to be implemented in subclass!");
		}
		
		/**
		 * @private
		 * Updates the color of the display object.
		 * @param a
		 * @param r
		 * @param g
		 * @param b
		 * @param aM
		 * @param rM
		 * @param gM
		 * @param bM
		 */
		dragonBones_internal function updateDisplayColor(
			aOffset:Number, 
			rOffset:Number, 
			gOffset:Number, 
			bOffset:Number, 
			aMultiplier:Number, 
			rMultiplier:Number, 
			gMultiplier:Number, 
			bMultiplier:Number,
			colorChanged:Boolean = false
		):void
		{
			_colorTransform.alphaOffset = aOffset;
			_colorTransform.redOffset = rOffset;
			_colorTransform.greenOffset = gOffset;
			_colorTransform.blueOffset = bOffset;
			_colorTransform.alphaMultiplier = aMultiplier;
			_colorTransform.redMultiplier = rMultiplier;
			_colorTransform.greenMultiplier = gMultiplier;
			_colorTransform.blueMultiplier = bMultiplier;
			_isColorChanged = colorChanged;
		}
		
		/**
		 * @private
		 * Update the blend mode of the display object.
		 * @param value The blend mode to use. 
		 */
		dragonBones_internal function updateDisplayBlendMode(value:String):void
		{
			throw new IllegalOperationError("Abstract method needs to be implemented in subclass!");
		}
		
		/** @private When slot timeline enter a key frame, call this func*/
		dragonBones_internal function arriveAtFrame(frame:Frame, animationState:FastAnimationState):void
		{
			var slotFrame:SlotFrame = frame as SlotFrame;
			var displayIndex:int = slotFrame.displayIndex;
			changeDisplayIndex(displayIndex);
			updateDisplayVisible(slotFrame.visible);
			if(displayIndex >= 0)
			{
				if(!isNaN(slotFrame.zOrder) && slotFrame.zOrder != _tweenZOrder)
				{
					_tweenZOrder = slotFrame.zOrder;
					this.armature._slotsZOrderChanged = true;
				}
			}
			//[TODO]currently there is only gotoAndPlay belongs to frame action. In future, there will be more.  
			//后续会扩展更多的action，目前只有gotoAndPlay的含义
			if(frame.action) 
			{
				var targetArmature:IArmature = childArmature as IArmature;
				if (targetArmature)
				{
					targetArmature.getAnimation().gotoAndPlay(frame.action);
				}
			}
		}
		
				/** @private */
		dragonBones_internal function hideSlots():void
		{
			changeDisplayIndex( -1);
			removeDisplayFromContainer();
			if (_frameCache)
			{
				this._frameCache.clear();
			}
		}
		
		override protected function updateGlobal():Object 
		{
			calculateRelativeParentTransform();
			TransformUtil.transformToMatrix(_global, _globalTransformMatrix);
			var output:Object = calculateParentTransform();
			if(output != null)
			{
				//计算父骨头绝对坐标
				var parentMatrix:Matrix = output.parentGlobalTransformMatrix;
				_globalTransformMatrix.concat(parentMatrix);
			}
			TransformUtil.matrixToTransform(_globalTransformMatrix,_global,true,true);
			return output;
		}
	}
}