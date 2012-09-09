package com.citrusengine.view.starlingview {

	import starling.display.Image;
	import starling.textures.Texture;

	import flash.display.Bitmap;
	
	/**
	 * @author Nick Pinkham
	 */
	public class StarlingTile {
		
		public var isInRAM:Boolean = false;
		public var myBitmap:Bitmap;
		public var myTexture:Texture;
		public var myImage:Image;
		
		public var x:Number;
		public var y:Number;
		
		public var width:Number;
		public var height:Number;
		
		public function StarlingTile() {
			
		}
	}
	
}