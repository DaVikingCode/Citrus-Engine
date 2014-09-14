package dragonBones.utils
{
	import flash.utils.ByteArray;
	
	/** @private */
	public class BytesType
	{
		public static const SWF:String = "swf";
		public static const PNG:String = "png";
		public static const JPG:String = "jpg";
		public static const ATF:String = "atf";
		public static const ZIP:String = "zip";
		
		public static function getType(bytes:ByteArray):String
		{
			var type:String;
			var b1:uint = bytes[0];
			var b2:uint = bytes[1];
			var b3:uint = bytes[2];
			var b4:uint = bytes[3];
			if ((b1 == 0x46 || b1 == 0x43 || b1 == 0x5A) && b2 == 0x57 && b3 == 0x53)
			{
				//CWS FWS ZWS
				type = SWF;
			}
			else if (b1 == 0x89 && b2 == 0x50 && b3 == 0x4E && b4 == 0x47)
			{
				//89 50 4e 47 0d 0a 1a 0a
				type = PNG;
			}
			else if (b1 == 0xFF)
			{
				type = JPG;
			}
			else if (b1 == 0x41 && b2 == 0x54 && b3 == 0x46)
			{
				type = ATF;
			}
			else if (b1 == 0x50 && b2 == 0x4B)
			{
				type = ZIP;
			}
			return type;
		}
	}
}