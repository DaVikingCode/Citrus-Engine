package dragonBones.objects
{
	import flash.geom.Point;
	
	/** @private */
	final public class DisplayData
	{
		public static const ARMATURE:String = "armature";
		public static const IMAGE:String = "image";
		
		public var name:String;
		public var type:String;
		public var transform:DBTransform;
		public var pivot:Point;
		
		public function DisplayData()
		{
			transform = new DBTransform();
		}
		
		public function dispose():void
		{
			transform = null;
			pivot = null;
		}
	}
}