package com.citrusengine.view.starlingview {

	import starling.display.MovieClip;
	import starling.textures.Texture;

	import flash.media.Sound;

	/**
	 * DynamicMovieClip is a class which should be only use for quick prototyping.
	 * It allows the Citrus Engine to use .swf for animations thanks to DynamicAtlas class.
	 */
	public class DynamicMovieClip extends MovieClip {

		private var mTextures:Vector.<Texture>;
		private var mSounds:Vector.<Sound>;
		private var mDurations:Vector.<Number>;
		private var mStartTimes:Vector.<Number>;

		private var mDefaultFrameDuration:Number;
		private var mTotalTime:Number;
		private var mCurrentTime:Number;
		private var mCurrentFrame:int;
		private var mLoop:Boolean;
		private var mPlaying:Boolean;

		public function DynamicMovieClip(textures:Vector.<Texture>, fps:Number = 30) {
			super(textures, fps);
		}

		public function changeTextures(textures:Vector.<Texture>, loop:Boolean = true, fps:Number = 30):void {

			if (textures.length > 0) {
				
				mDefaultFrameDuration = 1.0 / fps;
				mLoop = loop;
				mPlaying = true;
				mTotalTime = 0.0;
				mCurrentTime = 0.0;
				mCurrentFrame = 0;
				mTextures = new <Texture>[];
				mSounds = new <Sound>[];
				mDurations = new <Number>[];
				mStartTimes = new <Number>[];

				for each (var texture:Texture in textures)
					addFrame(texture);
					
			} else {
				throw new ArgumentError("Empty texture array");
			}
		}

	}
}
