package dragonBones.display
{
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.ColorTransform;
	
	import dragonBones.Slot;
	import dragonBones.core.dragonBones_internal;
	
	use namespace dragonBones_internal;
	
	public class NativeSlot extends Slot
	{
		private var _nativeDisplay:DisplayObject;
		private var _colorTransform:ColorTransform;
		
		public function NativeSlot()
		{
			super(this);
			_nativeDisplay = null;
			_colorTransform = null;
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			_nativeDisplay = null;
			_colorTransform = null;
		}
		
		
		//Abstract method
		
		/** @private */
		override dragonBones_internal function updateDisplay(value:Object):void
		{
			_nativeDisplay = value as DisplayObject;
		}
		
		/** @private */
		override dragonBones_internal function getDisplayIndex():int
		{
			if(_nativeDisplay && _nativeDisplay.parent)
			{
				return _nativeDisplay.parent.getChildIndex(_nativeDisplay);
			}
			return -1;
		}
		
		/** @private */
		override dragonBones_internal function addDisplayToContainer(container:Object, index:int = -1):void
		{
			var nativeContainer:DisplayObjectContainer = container as DisplayObjectContainer;
			if(_nativeDisplay && nativeContainer)
			{
				if (index < 0)
				{
					nativeContainer.addChild(_nativeDisplay);
				}
				else
				{
					nativeContainer.addChildAt(_nativeDisplay, Math.min(index, nativeContainer.numChildren));
				}
			}
		}
		
		/** @private */
		override dragonBones_internal function removeDisplayFromContainer():void
		{
			if(_nativeDisplay && _nativeDisplay.parent)
			{
				_nativeDisplay.parent.removeChild(_nativeDisplay);
			}
		}
		
		/** @private */
		override dragonBones_internal function updateTransform():void
		{
			if(_nativeDisplay)
			{
				_nativeDisplay.transform.matrix = this._globalTransformMatrix;
			}
		}
		
		/** @private */
		override dragonBones_internal function updateDisplayVisible(value:Boolean):void
		{
			if(_nativeDisplay)
			{
				_nativeDisplay.visible = this._parent.visible && this._visible && value;
			}
		}
		
		/** @private */
		override dragonBones_internal function updateDisplayColor(
			aOffset:Number, 
			rOffset:Number, 
			gOffset:Number, 
			bOffset:Number, 
			aMultiplier:Number, 
			rMultiplier:Number, 
			gMultiplier:Number, 
			bMultiplier:Number):void
		{
			if(_nativeDisplay)
			{
				if(!_colorTransform)
				{
					_colorTransform = new ColorTransform();
				}
				_colorTransform.alphaOffset = aOffset;
				_colorTransform.redOffset = rOffset;
				_colorTransform.greenOffset = gOffset;
				_colorTransform.blueOffset = bOffset;
				
				_colorTransform.alphaMultiplier = aMultiplier;
				_colorTransform.redMultiplier = rMultiplier;
				_colorTransform.greenMultiplier = gMultiplier;
				_colorTransform.blueMultiplier = bMultiplier;
				
				_nativeDisplay.transform.colorTransform = _colorTransform;
			}
		}
		
		/** @private */
		override dragonBones_internal function updateDisplayBlendMode(value:String):void
		{
			if(_nativeDisplay)
			{
				switch(blendMode)
				{
					case BlendMode.ADD:
					case BlendMode.ALPHA:
					case BlendMode.DARKEN:
					case BlendMode.DIFFERENCE:
					case BlendMode.ERASE:
					case BlendMode.HARDLIGHT:
					case BlendMode.INVERT:
					case BlendMode.LAYER:
					case BlendMode.LIGHTEN:
					case BlendMode.MULTIPLY:
					case BlendMode.NORMAL:
					case BlendMode.OVERLAY:
					case BlendMode.SCREEN:
					case BlendMode.SHADER:
					case BlendMode.SUBTRACT:
						_nativeDisplay.blendMode = blendMode;
						break;
					
					default:
						//_nativeDisplay.blendMode = BlendMode.NORMAL;
						break;
				}
			}
		}
	}
}