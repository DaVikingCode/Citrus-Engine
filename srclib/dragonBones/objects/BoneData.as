package dragonBones.objects
{
	final public class BoneData
	{
		public var name:String;
		public var parent:String;
		public var length:Number;
		
		public var global:DBTransform;
		public var transform:DBTransform;
		
		public var inheritScale:Boolean;
		public var inheritRotation:Boolean;
		
		public function BoneData()
		{
			length = 0;
			global = new DBTransform();
			transform = new DBTransform();
			inheritRotation = true;
			inheritScale = false;
		}
		
		public function dispose():void
		{
			global = null;
			transform = null;
		}
	}
}