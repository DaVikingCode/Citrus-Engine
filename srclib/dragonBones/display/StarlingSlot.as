package dragonBones.display
{
	import flash.display.BlendMode;
	import flash.geom.Matrix;
	
	import dragonBones.Armature;
	import dragonBones.Slot;
	import dragonBones.core.dragonBones_internal;
	
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	
	use namespace dragonBones_internal;
	
	public class StarlingSlot extends Slot
	{
		private var _starlingDisplay:DisplayObject;
		
		public var updateMatrix:Boolean;
		
		public function StarlingSlot()
		{
			super(this);
			
			_starlingDisplay = null;
			
			updateMatrix = false;
		}
		
		override public function dispose():void
		{
			for each(var content:Object in this._displayList)
			{
				if(content is Armature)
				{
					(content as Armature).dispose();
				}
				else if(content is DisplayObject)
				{
					(content as DisplayObject).dispose();
				}
			}
			super.dispose();
			
			_starlingDisplay = null;
		}
		
		/** @private */
		override dragonBones_internal function updateDisplay(value:Object):void
		{
			_starlingDisplay = value as DisplayObject;
		}
		
		
		//Abstract method
		
		/** @private */
		override dragonBones_internal function getDisplayIndex():int
		{
			if(_starlingDisplay && _starlingDisplay.parent)
			{
				return _starlingDisplay.parent.getChildIndex(_starlingDisplay);
			}
			return -1;
		}
		
		/** @private */
		override dragonBones_internal function addDisplayToContainer(container:Object, index:int = -1):void
		{
			var starlingContainer:DisplayObjectContainer = container as DisplayObjectContainer;
			if(_starlingDisplay && starlingContainer)
			{
				if (index < 0)
				{
					starlingContainer.addChild(_starlingDisplay);
				}
				else
				{
					starlingContainer.addChildAt(_starlingDisplay, Math.min(index, starlingContainer.numChildren));
				}
			}
		}
		
		/** @private */
		override dragonBones_internal function removeDisplayFromContainer():void
		{
			if(_starlingDisplay && _starlingDisplay.parent)
			{
				_starlingDisplay.parent.removeChild(_starlingDisplay);
			}
		}
		
		/** @private */
		override dragonBones_internal function updateTransform():void
		{
			if(_starlingDisplay)
			{
				var pivotX:Number = _starlingDisplay.pivotX;
				var pivotY:Number = _starlingDisplay.pivotY;
				
				
				if(updateMatrix)
				{
					//_starlingDisplay.transformationMatrix setter 比较慢暂时走下面
					_starlingDisplay.transformationMatrix = _globalTransformMatrix;
					if(pivotX || pivotY)
					{
						_starlingDisplay.pivotX = pivotX;
						_starlingDisplay.pivotY = pivotY;
					}
				}
				else
				{
					var displayMatrix:Matrix = _starlingDisplay.transformationMatrix;
					displayMatrix.a = _globalTransformMatrix.a;
					displayMatrix.b = _globalTransformMatrix.b;
					displayMatrix.c = _globalTransformMatrix.c;
					displayMatrix.d = _globalTransformMatrix.d;
					//displayMatrix.copyFrom(_globalTransformMatrix);
					if(pivotX || pivotY)
					{
						displayMatrix.tx = _globalTransformMatrix.tx - (displayMatrix.a * pivotX + displayMatrix.c * pivotY);
						displayMatrix.ty = _globalTransformMatrix.ty - (displayMatrix.b * pivotX + displayMatrix.d * pivotY);
					}
					else
					{
						displayMatrix.tx = _globalTransformMatrix.tx;
						displayMatrix.ty = _globalTransformMatrix.ty;
					}
				}
			}
		}
		
		/** @private */
		override dragonBones_internal function updateDisplayVisible(value:Boolean):void
		{
			if(_starlingDisplay && this._parent)
			{
				_starlingDisplay.visible = this._parent.visible && this._visible && value;
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
			bMultiplier:Number,
			colorChanged:Boolean = false):void
		{
			if(_starlingDisplay)
			{
				super.updateDisplayColor(aOffset, rOffset, gOffset, bOffset, aMultiplier, rMultiplier, gMultiplier, bMultiplier,colorChanged);
				_starlingDisplay.alpha = aMultiplier;
				if (_starlingDisplay is Quad)
				{
					(_starlingDisplay as Quad).color = (uint(rMultiplier * 0xff) << 16) + (uint(gMultiplier * 0xff) << 8) + uint(bMultiplier * 0xff);
				}
			}
		}
		
		/** @private */
		override dragonBones_internal function updateDisplayBlendMode(value:String):void
		{
			if(_starlingDisplay)
			{
				switch(blendMode)
				{
					case starling.display.BlendMode.NONE:
					case starling.display.BlendMode.AUTO:
					case starling.display.BlendMode.ADD:
					case starling.display.BlendMode.ERASE:
					case starling.display.BlendMode.MULTIPLY:
					case starling.display.BlendMode.NORMAL:
					case starling.display.BlendMode.SCREEN:
						_starlingDisplay.blendMode = blendMode;
						break;
					
					case flash.display.BlendMode.ADD:
						_starlingDisplay.blendMode = starling.display.BlendMode.ADD;
						break;
					
					case flash.display.BlendMode.ERASE:
						_starlingDisplay.blendMode = starling.display.BlendMode.ERASE;
						break;
					
					case flash.display.BlendMode.MULTIPLY:
						_starlingDisplay.blendMode = starling.display.BlendMode.MULTIPLY;
						break;
					
					case flash.display.BlendMode.NORMAL:
						_starlingDisplay.blendMode = starling.display.BlendMode.NORMAL;
						break;
					
					case flash.display.BlendMode.SCREEN:
						_starlingDisplay.blendMode = starling.display.BlendMode.SCREEN;
						break;
					
					case flash.display.BlendMode.ALPHA:
					case flash.display.BlendMode.DARKEN:
					case flash.display.BlendMode.DIFFERENCE:
					case flash.display.BlendMode.HARDLIGHT:
					case flash.display.BlendMode.INVERT:
					case flash.display.BlendMode.LAYER:
					case flash.display.BlendMode.LIGHTEN:
					case flash.display.BlendMode.OVERLAY:
					case flash.display.BlendMode.SHADER:
					case flash.display.BlendMode.SUBTRACT:
						break;
					
					default:
						break;
				}
			}
		}
	}
}