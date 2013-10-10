package dragonBones.display
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0
	* @langversion 3.0
	* @version 2.0
	*/

	
	import dragonBones.objects.DBTransform;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	/**
	 * The NativeDisplayBridge class is an implementation of the IDisplayBridge interface for traditional flash.display.DisplayObject.
	 *
	 */
	public class NativeDisplayBridge implements IDisplayBridge
	{
		private var _display:DisplayObject;
		private var _colorTransform:ColorTransform;
		
		/**
		 * @inheritDoc
		 */
		public function get display():Object
		{
			return _display;
		}
		public function set display(value:Object):void
		{
			if (_display == value)
			{
				return;
			}
			if (_display)
			{
				var parent:DisplayObjectContainer = _display.parent;
				if (parent)
				{
					var index:int = _display.parent.getChildIndex(_display);
				}
				removeDisplay();
			}
			_display = value as DisplayObject;
			addDisplay(parent, index);
		}
		
		/**
		 * @inheritDoc
		 */
		public function get visible():Boolean
		{
			return _display?_display.visible:false;
		}
		public function set visible(value:Boolean):void
		{
			if(_display)
			{
				_display.visible = value;
			}
		}
		
		/**
		 * Creates a new NativeDisplayBridge instance.
		 */
		public function NativeDisplayBridge()
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function dispose():void
		{
			_display = null;
			_colorTransform = null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function updateTransform(matrix:Matrix, transform:DBTransform):void
		{
			_display.transform.matrix = matrix;
		}
		
		/**
		 * @inheritDoc
		 */
		public function updateColor(
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
			if(!_colorTransform)
			{
				_colorTransform = _display.transform.colorTransform;
			}
			_colorTransform.alphaOffset = aOffset;
			_colorTransform.redOffset = rOffset;
			_colorTransform.greenOffset = gOffset;
			_colorTransform.blueOffset = bOffset;
			
			_colorTransform.alphaMultiplier = aMultiplier;
			_colorTransform.redMultiplier = rMultiplier;
			_colorTransform.greenMultiplier = gMultiplier;
			_colorTransform.blueMultiplier = bMultiplier;
			
			_display.transform.colorTransform = _colorTransform;
		}
        
        /**
         * @inheritDoc
         */
        public function updateBlendMode(blendMode:String):void
        {
            _display.blendMode = blendMode;
        }
		
		/**
		 * @inheritDoc
		 */
		public function addDisplay(container:Object, index:int = -1):void
		{
			if (container && _display)
			{
				if (index < 0)
				{
					container.addChild(_display);
				}
				else
				{
					container.addChildAt(_display, Math.min(index, container.numChildren));
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeDisplay():void
		{
			if (_display && _display.parent)
			{
				_display.parent.removeChild(_display);
			}
		}
	}
}