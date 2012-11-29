package dragonBones.utils {
	import flash.utils.ByteArray;
	
	/** @private */
	public class BytesType{
		public static const SWF:String = "swf";
		public static const PNG:String = "png";
		public static const JPG:String = "jpg";
		
		public static const ATF:String = "atf";
		
		public static const ZIP:String = "zip";
		
		public static function getType(_byteArray:ByteArray):String {
			var _type:String;
			var _b1:uint = _byteArray[0];
			var _b2:uint = _byteArray[1];
			var _b3:uint = _byteArray[2];
			var _b4:uint = _byteArray[3];
			
			if((_b1 == 0x46 || _b1 == 0x43 || _b1 == 0x5A) && _b2 == 0x57 && _b3 == 0x53){
				//CWS FWS ZWS
				_type = SWF;
			}else if(_b1 == 0x89 && _b2 == 0x50 && _b3 == 0x4E && _b4 == 0x47){
				//89 50 4e 47 0d 0a 1a 0a
				_type = PNG;
			}else if(_b1 == 0xFF){
				_type = JPG;
			}else if(_b1 == 0x41 && _b2 == 0x54 && _b3 == 0x46){
				_type = ATF;
			}else if(_b1 == 0x50 && _b2 == 0x4B){
				_type = ZIP;
			}
			
			return _type;
		}
	}
}