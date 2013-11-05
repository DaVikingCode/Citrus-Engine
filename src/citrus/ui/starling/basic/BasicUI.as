package citrus.ui.starling.basic 
{
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	
	public class BasicUI extends BasicUILayout
	{
		public var container:DisplayObjectContainer;
		public static var defaultContentScale:Number = 1;
		
		public function BasicUI(parentContainer:DisplayObjectContainer,frame:Rectangle) 
		{
			container = new Sprite();
			parentContainer.addChild(container);
			super(this, frame);
		}
		
		override public function destroy():void
		{
			super.destroy();
			container.removeFromParent();
			container = null;
		}
		
	}

}