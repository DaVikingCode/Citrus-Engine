package dragonBones.display
{
	import dragonBones.objects.Node;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	
	/**
	 * A display bridge for tranditional DisplayList
	 *
	 */
	public class NativeDisplayBridge implements IDisplayBridge
	{
		protected var _display:DisplayObject;
		
		/**
		 * @inheritDoc
		 */
		public function get display():Object
		{
			return _display;
		}
		
		public function set display(value:Object):void
		{
			if(_display == value){
				return;
			}
			if(_display)
			{
				var parent:DisplayObjectContainer = _display.parent;
				if(parent)
				{
					var index:int = _display.parent.getChildIndex(_display);
				}
				removeDisplay();
			}
			_display = value as DisplayObject;
			addDisplay(parent, index);
		}
		/**
		 * Creates a new <code>NativeDisplayBridge</code> object
		 */
		public function NativeDisplayBridge()
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function update(matrix:Matrix, node:Node, colorTransform:ColorTransform, visible:Boolean):void
		{
			var pivotX:Number = node.pivotX;
			var pivotY:Number = node.pivotY;
			matrix.tx -= matrix.a * pivotX + matrix.c * pivotY;
			matrix.ty -= matrix.b * pivotX + matrix.d * pivotY;
			
			_display.transform.matrix = matrix;
			if(colorTransform)
			{
				_display.transform.colorTransform = colorTransform;
			}
			_display.visible = visible;
		}
		/**
		 * @inheritDoc
		 */
		public function addDisplay(container:Object, index:int = -1):void
		{
			if(container && _display)
			{
				if(index < 0)
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
			if(_display && _display.parent)
			{
				_display.parent.removeChild(_display);
			}
		}
	}
}