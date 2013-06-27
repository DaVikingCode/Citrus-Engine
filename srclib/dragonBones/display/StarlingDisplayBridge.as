package dragonBones.display
{
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0
	* @langversion 3.0
	* @version 2.0
	*/

	
	import dragonBones.objects.BoneTransform;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.display.Image;
	
	/**
	 * The StarlingDisplayBridge class is an implementation of the IDisplayBridge interface for starling.display.DisplayObject.
	 *
	 */
	public class StarlingDisplayBridge implements IDisplayBridge
	{
		/**
		 * @private
		 */
		protected var _display:Object;
		/**
		 * @inheritDoc
		 */
		public function get display():Object
		{
			return _display;
		}
		/**
		 * @private
		 */
		public function set display(value:Object):void
		{
			if (_display == value)
			{
				return;
			}
			
			//Thanks Jian
			//bug replace image.texture will lost displayList[0].texture
			/*if (_display is Image && value is Image)
			{
				var from:Image = _display as Image;
				var to:Image = value as Image;
				if (from.texture == to.texture)
				{
					return;
				}
				
				from.texture = to.texture;
				//update pivot
				from.pivotX = to.pivotX;
				from.pivotY = to.pivotY;
				from.readjustSize();
				return;
			}*/
			
			if (_display)
			{
				var parent:* = _display.parent;
				if (parent)
				{
					var index:int = _display.parent.getChildIndex(_display);
				}
				removeDisplay();
			}
			_display = value;
			addDisplay(parent, index);
		}
		
		/**
		 * Creates a new StarlingDisplayBridge instance.
		 */
		public function StarlingDisplayBridge()
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function update(matrix:Matrix, node:BoneTransform, colorTransform:ColorTransform, visible:Boolean):void
		{
			var pivotX:Number = node.pivotX + _display.pivotX;
			var pivotY:Number = node.pivotY + _display.pivotY;
			matrix.tx -= matrix.a * pivotX + matrix.c * pivotY;
			matrix.ty -= matrix.b * pivotX + matrix.d * pivotY;
			
			//if(updateStarlingDisplay)
			//{
			//_display.transformationMatrix = matrix;
			//}
			//else
			//{
			_display.transformationMatrix.copyFrom(matrix);
			//}
			
			if (colorTransform && _display is Quad)
			{
				(_display as Quad).alpha = colorTransform.alphaMultiplier;
				(_display as Quad).color = (uint(colorTransform.redMultiplier * 0xff) << 16) + (uint(colorTransform.greenMultiplier * 0xff) << 8) + uint(colorTransform.blueMultiplier * 0xff);
			}
			//
			_display.visible = visible;
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
