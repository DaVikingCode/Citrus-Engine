package com.citrusengine.view.blittingview
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	/**
	 * Animation Sequence represents a single animation sprite sheet. You will create one animation sequence per animation that your
	 * character has. Your animation sequences will be added to a <code>BlittingArt</code> object, which is the primary art object that
	 * represents your character in a Blitting view.
	 */
	public class AnimationSequence
	{
		public var loop:Boolean;
		public var currFrame:Number = 0;
		
		public var bitmapData:BitmapData;
		public var invertedBitmapData:BitmapData;
		public var name:String;
		
		private var _frameWidth:Number;
		private var _frameHeight:Number;
		private var _numFrames:Number;
		private var _numRows:Number;
		private var _numColumns:Number;
		
		/**
		 * Creates a new AnimationSequence, to be added to your character's BlittinArt.
		 * @param	bitmap A Bitmap class, BitmapData class, or Bitmap object that creates a BitmapData sprite sheet. This is usually an embedded graphic class.
		 * @param	name A name representing what the animation sequence is, such as "walk", "jump", or "die".
		 * @param	frameWidth The width of a single frame in your sprite sheet animation.
		 * @param	frameHeight The height of a single frame in your sprite sheet animation.
		 * @param	loop When your animation reaches the last frame, does it start over (true) or just stay at the end (false)?
		 * @param	willInvert Should we generate an inverted copy of your bitmap? (useful for things that walk left and right).
		 */
		public function AnimationSequence(bitmap:*, name:String = "", frameWidth:Number = 0, frameHeight:Number = 0, loop:Boolean = true, willInvert:Boolean = false ) 
		{
			this.name = name;
			
			var bitmapObject:Bitmap;
			if (bitmap is Class)
			{
				bitmapObject = new bitmap() as Bitmap;
				if (!bitmapObject)
					bitmapData = new bitmap() as BitmapData;
			}
			else
			{
				bitmapObject = bitmap;
			}
			
			if (!bitmapData)
				bitmapData = bitmapObject.bitmapData;
			
			if (willInvert)
			{
				var matrix:Matrix = new Matrix();
				matrix.scale( -1, 1);
				matrix.translate(bitmapData.width, 0);
				invertedBitmapData = new BitmapData(bitmapData.width, bitmapData.height, true, 0x00000000);
				invertedBitmapData.draw(bitmapData, matrix);
			}
			
			_frameWidth = frameWidth;
			if (_frameWidth == 0)
				_frameWidth = bitmapData.width;
				
			_frameHeight = frameHeight;
			if (_frameHeight == 0)
				_frameHeight = bitmapData.height;
			
			if (bitmapData.width % _frameWidth != 0)
			{
				trace("Warning: You did not specify a valid frame width in animation " + name + ". The frame width is not evenly divisible by the bitmap width.");
			}
			
			if (bitmapData.height % _frameHeight != 0)
			{
				trace("Warning: You did not specify a valid frame height in animation " + name + ". The frame height is not evenly divisible by the bitmap height.");
			}
			
			_numRows = Math.round(bitmapData.height  / _frameHeight);
			_numColumns = Math.round(bitmapData.width / _frameWidth);
			_numFrames = _numRows * _numColumns;
			
			this.loop = loop;
		}
		
		public function get frameWidth():Number { return _frameWidth; }
		
		public function get frameHeight():Number { return _frameHeight; }
		
		public function get numRows():Number { return _numRows; }
		
		public function get numColumns():Number { return _numColumns; }
		
		public function get numFrames():Number { return _numFrames; }
	}

}