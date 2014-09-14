package dragonBones
{
	import flash.errors.IllegalOperationError;
	import flash.geom.Matrix;
	
	import dragonBones.core.DBObject;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.objects.DisplayData;
	import dragonBones.objects.FrameCached;
	import dragonBones.objects.TimelineCached;
	
	use namespace dragonBones_internal;
	
	public class Slot extends DBObject
	{
		/** @private Need to keep the reference of DisplayData. When slot switch displayObject, it need to restore the display obect's origional pivot. */
		dragonBones_internal var _displayDataList:Vector.<DisplayData>;
		
		/** @private */
		dragonBones_internal var _originZOrder:Number;
		
		/** @private */
		dragonBones_internal var _tweenZOrder:Number;
		
		/** @private */
		dragonBones_internal var _isShowDisplay:Boolean;
		
		/** @private */
		dragonBones_internal var _timelineCached:TimelineCached;
		
		/** @private */
		protected var _offsetZOrder:Number;
		
		/** @private */
		protected var _displayIndex:int;
		
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
				if(this._armature)
				{
					this._armature._slotsZOrderChanged = true;
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
		
		protected var _blendMode:String;
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
		
		protected var _display:Object;
		/**
		 * The DisplayObject belonging to this Slot instance. Instance type of this object varies from flash.display.DisplayObject to startling.display.DisplayObject and subclasses.
		 */
		public function get display():Object
		{
			return _display;
		}
		public function set display(value:Object):void
		{
			var displayIndex:int = _displayIndex < 0?0:_displayIndex;
			if(_displayList[displayIndex] == value)
			{
				return;
			}
			_displayList[displayIndex] = value;
			_childArmature = null;
			updateSlotDisplay(value);
			updateChildArmatureAnimation();
			updateTransform();
		}
		
		protected var _childArmature:Armature;
		/**
		 * The sub-armature of this Slot instance.
		 */
		public function get childArmature():Armature
		{
			return _childArmature;
		}
		public function set childArmature(value:Armature):void
		{
			var displayIndex:int = _displayIndex < 0?0:_displayIndex;
			if(_displayList[displayIndex] == value)
			{
				return;
			}
			_displayList[displayIndex] = _childArmature;
			_childArmature = value;
			if(_childArmature)
			{
				updateSlotDisplay(_childArmature.display);
			}
			else
			{
				updateSlotDisplay(null);
			}
			updateChildArmatureAnimation();
			updateTransform();
		}

		//
		protected var _displayList:Array;
		/**
		 * The DisplayObject list belonging to this Slot instance (display or armature). Replace it to implement switch texture.
		 */
		public function get displayList():Array
		{
			return _displayList;
		}
		public function set displayList(value:Array):void
		{
			if(!value)
			{
				throw new ArgumentError();
			}
			var i:int = _displayList.length = value.length;
			while(i --)
			{
				_displayList[i] = value[i];
			}
			
			if(_displayIndex >= 0)
			{
				var displayIndexBackup:int = _displayIndex;
				_displayIndex = -1;
				changeDisplay(displayIndexBackup);
				updateTransform();
			}
		}
		
		/** @private */
		override dragonBones_internal function setArmature(value:Armature):void
		{
			super.setArmature(value);
			if(this._armature)
			{
				this._armature._slotsZOrderChanged = true;
				addDisplayToContainer(this._armature.display);
			}
			else
			{
				removeDisplayFromContainer();
			}
		}
		
		/**
		 * Creates a Slot blank instance.
		 */
		public function Slot(self:Slot)
		{
			super();
			
			if(self != this)
			{
				throw new IllegalOperationError("Abstract class can not be instantiated!");
			}
			
			_displayList = [];
			_displayIndex = -1;
			
			_originZOrder = 0;
			_tweenZOrder = 0;
			_offsetZOrder = 0;
			_displayDataList = null;
			_isShowDisplay = false;
			
			_childArmature = null;
			_display = null;
			
			this.inheritRotation = true;
			this.inheritScale = true;
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
			
			_displayList.length = 0;
			
			_displayDataList = null;
			_displayList = null;
			_display = null;
			_childArmature = null;
			
			_timelineCached = null;
		}
		
		/** @private */
		dragonBones_internal function update():void
		{
			if(this._parent._needUpdate <= 0)
			{
				return;
			}
			
			var frameCachedPosition:int = this._parent._frameCachedPosition;
			var frameCachedDuration:int = this._parent._frameCachedDuration;
			
			if(frameCachedPosition >= 0 && frameCachedDuration <= 0)
			{
				var frameCached:FrameCached = _timelineCached.timeline[frameCachedPosition];
				
				var matrix:Matrix = frameCached.matrix;
				this._globalTransformMatrix.a = matrix.a;
				this._globalTransformMatrix.b = matrix.b;
				this._globalTransformMatrix.c = matrix.c;
				this._globalTransformMatrix.d = matrix.d;
				this._globalTransformMatrix.tx = matrix.tx;
				this._globalTransformMatrix.ty = matrix.ty;
				//this._globalTransformMatrix.copyFrom(_frameCached.matrix);
				
				updateTransform();
				return;
			}
			
			var x:Number = this._origin.x + this._offset.x + this._parent._tweenPivot.x;
			var y:Number = this._origin.y + this._offset.y + this._parent._tweenPivot.y;
			
			var parentMatrix:Matrix = this._parent._globalTransformMatrix;
			
			//this._globalTransformMatrix.tx = this._global.x = parentMatrix.a * x + parentMatrix.c * y + parentMatrix.tx;
			//this._globalTransformMatrix.ty = this._global.y = parentMatrix.d * y + parentMatrix.b * x + parentMatrix.ty;
			
			this._globalTransformMatrix.tx = this._global.x = parentMatrix.a * x * this._parent._global.scaleX + parentMatrix.c * y * this._parent._global.scaleY + parentMatrix.tx;
			this._globalTransformMatrix.ty = this._global.y = parentMatrix.d * y * this._parent._global.scaleY + parentMatrix.b * x * this._parent._global.scaleX + parentMatrix.ty;
			
			if(inheritRotation)
			{
				this._global.skewX = this._origin.skewX + this._offset.skewX + this._parent._global.skewX;
				this._global.skewY = this._origin.skewY + this._offset.skewY + this._parent._global.skewY;
			}
			else
			{
				this._global.skewX = this._origin.skewX + this._offset.skewX;
				this._global.skewY = this._origin.skewY + this._offset.skewY;
			}
			
			if(inheritScale)
			{
				this._global.scaleX = this._origin.scaleX * this._offset.scaleX * this._parent._global.scaleX;
				this._global.scaleY = this._origin.scaleY * this._offset.scaleY * this._parent._global.scaleY;
			}
			else
			{
				this._global.scaleX = this._origin.scaleX * this._offset.scaleX;
				this._global.scaleY = this._origin.scaleY * this._offset.scaleY;
			}
			
			this._globalTransformMatrix.a = this._global.scaleX * Math.cos(this._global.skewY);
			this._globalTransformMatrix.b = this._global.scaleX * Math.sin(this._global.skewY);
			this._globalTransformMatrix.c = -this._global.scaleY * Math.sin(this._global.skewX);
			this._globalTransformMatrix.d = this._global.scaleY * Math.cos(this._global.skewX);
			
			if(frameCachedDuration > 0)    // && frameCachedPosition >= 0
			{
				_timelineCached.addFrame(null, this._globalTransformMatrix, frameCachedPosition, frameCachedDuration);
			}
			
			updateTransform();
		}
		
		private function updateChildArmatureAnimation():void
		{
			if(_childArmature)
			{
				if(_isShowDisplay)
				{
					if(
						this._armature &&
						this._armature.animation.lastAnimationState &&
						_childArmature.animation.hasAnimation(this._armature.animation.lastAnimationState.name)
					)
					{
						_childArmature.animation.gotoAndPlay(this._armature.animation.lastAnimationState.name);
					}
					else
					{
						_childArmature.animation.play();
					}
				}
				else
				{
					_childArmature.animation.stop();
					_childArmature.animation._lastAnimationState = null;
				}
			}
		}
		
		/** @private */
		dragonBones_internal function changeDisplay(displayIndex:int):void
		{
			if(displayIndex < 0)
			{
				if(_isShowDisplay)
				{
					_isShowDisplay = false;
					removeDisplayFromContainer();
					updateChildArmatureAnimation();
				}
			}
			else
			{
				var length:uint = _displayList.length;
				if(displayIndex >= length)
				{
					displayIndex = length - 1;
					if(displayIndex < 0)
					{
						displayIndex = 0;
					}
				}
				
				if(_displayIndex != displayIndex)
				{
					_isShowDisplay = true;
					_displayIndex = displayIndex;
					
					var content:Object = _displayList[_displayIndex];
					if(content is Armature)
					{
						_childArmature = content as Armature;
						updateSlotDisplay(_childArmature.display);
					}
					else
					{
						_childArmature = null;
						updateSlotDisplay(content);
					}
					updateChildArmatureAnimation();
					
					if(
						_displayDataList && 
						_displayDataList.length > 0 && 
						_displayIndex < _displayDataList.length
					)
					{
						this._origin.copy(_displayDataList[_displayIndex].transform);
					}
				}
				else if(!_isShowDisplay)
				{
					_isShowDisplay = true;
					if(this._armature)
					{
						this._armature._slotsZOrderChanged = true;
						addDisplayToContainer(this._armature.display);
					}
					updateChildArmatureAnimation();
				}
				
			}
		}
		
		/** @private 
		 * Updates the display of the slot.
		 */
		dragonBones_internal function updateSlotDisplay(value:Object):void
		{
			var exIndex:int = -1;
			if(_display)
			{
				exIndex = getDisplayIndex();
				removeDisplayFromContainer();
			}
			_display = value;
			updateDisplay(_display);
			if(_display)
			{
				if(this._armature && _isShowDisplay)
				{
					if(exIndex < 0)
					{
						this._armature._slotsZOrderChanged = true;
						addDisplayToContainer(this._armature.display);
					}
					else
					{
						addDisplayToContainer(this._armature.display, exIndex);
					}
				}
				updateDisplayBlendMode(_blendMode);
			}
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
			bMultiplier:Number
		):void
		{
			throw new IllegalOperationError("Abstract method needs to be implemented in subclass!");
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
	}
}