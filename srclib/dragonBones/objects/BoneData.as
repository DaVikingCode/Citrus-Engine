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
		
		public function BoneData()
		{
			length = 0;
			global = new DBTransform();
			transform = new DBTransform();
		}
		
		public function dispose():void
		{
			global = null;
			transform = null;
		}
	}
}