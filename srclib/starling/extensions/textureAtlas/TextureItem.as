package starling.extensions.textureAtlas {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;	
	
	public class TextureItem extends Sprite{
		
		private var _graphic:BitmapData;
		private var _textureName:String = "";
		private var _frameName:String = "";
		private var _frameX:int = 0;
		private var _frameY:int = 0;
		private var _frameWidth:int = 0;
		private var _frameHeight:int = 0;
		
		
		public function TextureItem(graphic:BitmapData, textureName:String, frameName:String, frameX:int = 0, frameY:int=0, frameWidth:int=0, frameHeight:int=0){
			super();
			
			_graphic = graphic;
			_textureName = textureName;
			_frameName = frameName;
			
			_frameWidth = frameWidth;
			_frameHeight = frameHeight;
			_frameX = frameX;
			_frameY = frameY;
			
			var bm:Bitmap = new Bitmap(graphic, "auto", false);
			addChild(bm);
		}
		
		public function get textureName():String{
			return _textureName;
		}
		
		public function get frameName():String{
			return _frameName;
		}
		
		public function get graphic():BitmapData{
			return _graphic;
		}
		
		public function get frameX():int 
		{
			return _frameX;
		}
		
		public function get frameY():int 
		{
			return _frameY;
		}
		
		public function get frameWidth():int 
		{
			return _frameWidth;
		}
		
		public function get frameHeight():int 
		{
			return _frameHeight;
		}
	}
}