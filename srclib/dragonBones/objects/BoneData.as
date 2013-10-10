package dragonBones.objects
{
	import flash.geom.Point;

	final public class BoneData
	{
		public var name:String;
		public var parent:String;
		public var length:Number;
		
		public var global:DBTransform;
		public var transform:DBTransform;
		
		public var scaleMode:int;
		public var fixedRotation:Boolean;
		
		public function BoneData()
		{
			length = 0;
			global = new DBTransform();
			transform = new DBTransform();
			scaleMode = 1;
			fixedRotation = false;
		}
		
		public function dispose():void
		{
			global = null;
			transform = null;
		}
	}
}