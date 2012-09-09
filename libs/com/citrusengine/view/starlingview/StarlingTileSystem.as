package com.citrusengine.view.starlingview {
	// flash
	import com.citrusengine.core.CitrusEngine;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.display.Bitmap;
	
	// starling
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	
	// citrus
	import com.citrusengine.view.ISpriteView;
	import com.citrusengine.view.starlingview.StarlingTile;
	
	/**
	 * ...
	 * @author Nick Pinkham
	 */
	
	
	
	
	public class StarlingTileSystem extends Sprite {
		
		
		
		
		private var _ce:CitrusEngine;
		
		private var _followMe:ISpriteView; // the object that tracks
		
		private var _images:MovieClip;
		private var _liveTiles:Array = new Array();
		
		
		private var _parallax:Number;
		
		
		// timer to call updates, every second should be fine
		private var _timer:Timer = new Timer(1000);
		
		
		// test for maximum memory use
		private var maxInRam:Number = 0;
		
		
		
		
		public function StarlingTileSystem(bodyToFollow:ISpriteView, images:MovieClip, parallax:Number = 1) {
			
			_ce = CitrusEngine.getInstance();
			
			_followMe = bodyToFollow;
			_images = images;
			_parallax = parallax;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			
			// loop through children of _images movieclip
			// get all bitmaps
			// gather the bitmap's size and position
			// ?
			// profit
			
			var bitmap:Bitmap;
			var tile:StarlingTile;
			
			var nc:uint = _images.numChildren;
			for (var c:uint = 0; c < nc; c ++) {
				bitmap = _images.getChildAt(c) as Bitmap;
				// if it's a bitmap, make a tile out of it
				if (bitmap) {
					tile = new StarlingTile();
					tile.myBitmap = bitmap;
					tile.x = bitmap.x;
					tile.y = bitmap.y;
					tile.width = bitmap.width;
					tile.height = bitmap.height;
					_liveTiles.push(tile);
				} else {
					trace("other object in tile movieclip:", _images.getChildAt(c));
				}
				
			}
			
			
			// gather nearby to player
			onTimer();
			
			// start up the timer
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();
		}
		
		private function onTimer(e:TimerEvent = null):void {
			// loop through tiles
			var currentTile:StarlingTile;
			var d:Number;
			var numInRam:uint = 0;
			var viewRootX:Number = StarlingView(_ce.state.view).viewRoot.x;
			var viewRootY:Number = StarlingView(_ce.state.view).viewRoot.y;
			
			var ll:uint = _liveTiles.length;
			for (var t:uint = 0; t < ll; t ++) {
				// get a tile
				currentTile = _liveTiles[t] as StarlingTile;
				// check distance between tile and hero
				d = DistanceTwoPoints(currentTile.x + (-viewRootX * (1 - _parallax)) + (currentTile.width >> 1), _followMe.x, currentTile.y + (-viewRootY * (1 - _parallax)) + (currentTile.height >> 1), _followMe.y);
				// check if it is close enough to load in
				if (d < (Math.max(currentTile.width, currentTile.height)) * (1.7 / _parallax)) {
					if (!currentTile.isInRAM) {
						currentTile.isInRAM = true;
						currentTile.myTexture = Texture.fromBitmap(currentTile.myBitmap, false);
						var img:Image = new Image(currentTile.myTexture);
						img.x = currentTile.x;
						img.y = currentTile.y;
						addChild(img);
						currentTile.myImage = img;
						
					}
					
					
				// otherwise, check if it is far enough to dispose
				} else if (d > (Math.max(currentTile.width, currentTile.height)) * (1.8 / _parallax)) {
					if (currentTile.isInRAM) {
						currentTile.isInRAM = false;
						removeChild(currentTile.myImage);
						
						currentTile.myImage.dispose();
						currentTile.myTexture.dispose();
						
						currentTile.myImage = null;
						currentTile.myTexture = null;
					}
				}
				
				if (currentTile.isInRAM) {
					numInRam ++;
				}
				if (numInRam > maxInRam) {
					maxInRam = numInRam;
					// shows the maximum number of tiles used
					//trace(this.name, "max tiles in ram:", numInRam, "memory:", (numInRam * 4), "MB");
				}
			}
		}
		
		private function DistanceTwoPoints(x1:Number, x2:Number,  y1:Number, y2:Number):Number {
			var dx:Number = x1 - x2;
			var dy:Number = y1 - y2;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		public function destroy():void {
			_timer.removeEventListener(TimerEvent.TIMER, onTimer);
			_timer.reset();
			removeEventListeners();
			removeChildren(0, -1, true);
			
			// reset
			_followMe = null;
			_images = null;
			_liveTiles.length = 0;
			_liveTiles = null;
		}
	}
}