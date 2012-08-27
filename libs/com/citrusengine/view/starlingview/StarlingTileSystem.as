package com.citrusengine.view.starlingview {
	// flash
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
		
		private static const TW:uint = 1024; // tile width
		private static const TH:uint = 1024; // tile height
		
		
		
		
		private var _followMe:ISpriteView; // the object that tracks
		
		private var _images:Array;
		private var _liveTiles:Array = new Array();
		private var _ltl:uint;
		
		
		private var _parallax:Number;
		
		
		// timer to call updates, every second should be fine
		private var _timer:Timer = new Timer(1000);
		
		
		// test for maximum memory use
		private var maxInRam:Number = 0;
		
		
		
		
		public function StarlingTileSystem(bodyToFollow:ISpriteView, images:Array, parallax:Number = 1) {
			_followMe = bodyToFollow;
			_images = images;
			_parallax = parallax;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// loop through tiles array
			// get rows
			var rl:uint = _images.length;
			for (var r:uint = 0; r < rl; r ++) {
				// get columns
				var row:Array = _images[r] as Array;
				var cl:uint = row.length;
				for (var c:uint = 0; c < cl; c ++) {
					// check to see if it's a 1 or 0
					if (row[c] != null) {
						var clz:Class = row[c] as Class;
						var bmp:Bitmap = new clz();
						if (bmp) {
							var tile:StarlingTile = new StarlingTile();
							tile.myBitmap = bmp;
							tile.isInRAM = false;
							tile.x = TW * c;
							tile.y = TH * r;
							_liveTiles.push(tile);
						} else {
							trace("error creating class ref");
						}
					}
				}
				// length of tile array for speed
				_ltl = _liveTiles.length;
			}
			
			// fire timer for the first time
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
			for (var t:uint = 0; t < _ltl; t ++) {
				// get a tile
				currentTile = _liveTiles[t] as StarlingTile;
				// check distance between tile and hero
				d = DistanceTwoPoints(currentTile.x + (TW >> 1), _followMe.x, currentTile.y + (TH >> 1), _followMe.y);
				// check if it is close enough to load in
				if (d < TW * (1.5 / _parallax)) {
					if (!currentTile.isInRAM) {
						//trace("adding it");
						currentTile.isInRAM = true;
						currentTile.myTexture = Texture.fromBitmap(currentTile.myBitmap);
						var img:Image = new Image(currentTile.myTexture);
						img.x = currentTile.x;
						img.y = currentTile.y;
						addChild(img);
						currentTile.myImage = img;
						
					}
					
					
				// otherwise, check if it is far enough to dispose
				} else if (d > TW * (1.7 / _parallax)) {
					if (currentTile.isInRAM) {
						//trace("removing it");
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
					//trace(this.name, "maximum tiles in ram:", numInRam, "memory in use:", (numInRam * 4), "MB");
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
			
			// reset vars
			_followMe = null;
			_images = new Array();
			_liveTiles = new Array();
		}
	}
}