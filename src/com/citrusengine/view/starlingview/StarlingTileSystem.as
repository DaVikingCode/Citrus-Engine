package com.citrusengine.view.starlingview {
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.view.ISpriteView;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	/**
	 * @author Nick Pinkham
	 */
	public class StarlingTileSystem extends Sprite {
		
		private var _ce:CitrusEngine;
		
		private var _followMe:ISpriteView; // the object that is tracked
		
		private var _imagesMC:MovieClip;
		private var _imagesArray:Array;
		private var _liveTiles:Array = new Array();
		
		public var parallax:Number = 1;
		
		// determine whether to use dynamic loading to preserve gpu ram, or not and preserve loading times during play
		public var dynamicLoading:Boolean = false;
		
		// tile sizes
		public var tileWidth:uint = 2048;
		public var tileHeight:uint = 2048;
		
		// load in and out distances
		public var loadInDistance:Number = 1.8;
		public var unloadDistance:Number = 2.0;
		
		// timer to call updates, every second should be fine
		private var _timer:Timer = new Timer(1000);
		
		// test for maximum memory use
		private var maxInRam:Number = 0;
		
		
		public function StarlingTileSystem(images:*, bodyToFollow:ISpriteView = null) {
			
			_ce = CitrusEngine.getInstance();
			
			_followMe = bodyToFollow;
			
			if (images is MovieClip) {
				_imagesMC = images;
			} else if (images is Array) {
				_imagesArray = images;
			} else {
				trace("StarlingTileSystem images source error!");
			}
		}
		
		public function init():void {
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		public function onAdded(e:Event = null):void {
			
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			if (_imagesMC) {
				tilesFromMovieclip(_imagesMC);
			} else if (_imagesArray) {
				tilesFromArray(_imagesArray);
			}
			
			if (dynamicLoading) {
				// gather nearby to player
				onTimer();
				
				// start up the timer
				_timer.addEventListener(TimerEvent.TIMER, onTimer);
				_timer.start();
			} else {
				loadAll();
			}
		}
		
		/*
		 * gathers tiles from MovieClip via BitmapData. Remember the MovieClip must not have any graphics "bleeding" over the edge of the viewable region
		 * 
		 */
		private function tilesFromMovieclip(mc:MovieClip):void {
			
			//trace("getting from movieclip");
			var mcBitmapData:BitmapData = new BitmapData(mc.width, mc.height, true, 0x000000);
			mcBitmapData.draw(mc);
			
			var numColumns:uint = Math.ceil(mc.width / tileWidth);
			var numRows:uint = Math.ceil(mc.height / tileHeight);
			
			var pWidth:Number = (numColumns * tileWidth) / numColumns;
			var pHeight:Number = (numRows * tileHeight) / numRows;
			
			//trace("mc:", mc.width, "x", mc.height);
			//trace("rows:", numRows);
			//trace("columns:", numColumns);
			
			var bitmapData:BitmapData;
			var bitmap:Bitmap;
			var rect:Rectangle;
			var array:Array = new Array();
			
			for (var ri:uint = 0; ri < numRows; ri ++) {
				
				array[ri] = new Array();
				
				for (var ci:uint = 0; ci < numColumns; ci ++) {
					bitmapData = new BitmapData(pWidth, pHeight, true);
					rect = new Rectangle(ci * pWidth, ri * pHeight, pWidth, pHeight);
					bitmapData.copyPixels(mcBitmapData, rect, new Point(0, 0));
					bitmap = new Bitmap(bitmapData);
					array[ri][ci] = bitmap;
				}
			}
			
			_imagesArray = array;
			
			tilesFromArray(_imagesArray);
		}
		
		private function tilesFromArray(images:Array):void {
			
			// loop through tiles array
			// get rows
			var rl:uint = images.length;
			for (var r:uint = 0; r < rl; r ++) {
				// get columns
				var row:Array = images[r] as Array;
				var cl:uint = row.length;
				for (var c:uint = 0; c < cl; c ++) {
					// check to see if it's a 1 or 0
					if (row[c] != null) {
						var bmp:Bitmap = row[c] as Bitmap;
						if (!bmp) {
							var clz:Class = row[c] as Class;
							bmp = new clz();
						}
						
						
						if (bmp) {
							//trace("bitmap:", bmp.width, "x", bmp.height);
							var tile:StarlingTile = new StarlingTile();
							tile.myBitmap = bmp;
							tile.isInRAM = false;
							tile.x = bmp.width * c;
							tile.y = bmp.height * r;
							tile.width = bmp.width;
							tile.height = bmp.height;
							_liveTiles.push(tile);
						}
					}
				}
			}
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
				d = DistanceTwoPoints(currentTile.x + (-viewRootX * (1 - parallax)) + (currentTile.width >> 1), _followMe.x, currentTile.y + (-viewRootY * (1 - parallax)) + (currentTile.height >> 1), _followMe.y);
				// check if it is close enough to load in
				if (d < (Math.max(currentTile.width, currentTile.height)) * (loadInDistance / parallax)) {
					if (!currentTile.isInRAM) {
						if (isFlattened) {
							unflatten();
						}
						currentTile.isInRAM = true;
						currentTile.myTexture = Texture.fromBitmap(currentTile.myBitmap, false);
						var img:Image = new Image(currentTile.myTexture);
						img.x = currentTile.x;
						img.y = currentTile.y;
						addChild(img);
						currentTile.myImage = img;
					}
					
					
				// otherwise, check if it is far enough to dispose
				} else if (d > (Math.max(currentTile.width, currentTile.height)) * (unloadDistance / parallax)) {
					if (currentTile.isInRAM) {
						if (isFlattened) {
							unflatten();
						}
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
					//trace(this.name, "max tiles in ram:", numInRam, "memory:", (numInRam * 16), "MB");
				}
			}
			
			if (!isFlattened) {
				flatten();
			}
		}
		
		private function DistanceTwoPoints(x1:Number, x2:Number,  y1:Number, y2:Number):Number {
			
			var dx:Number = x1 - x2;
			var dy:Number = y1 - y2;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		// loops through all tiles and loads into memory
		public function loadAll():void {
			
			for each (var tile:StarlingTile in _liveTiles) {
				tile.isInRAM = true;
				tile.myTexture = Texture.fromBitmap(tile.myBitmap, false);
				var img:Image = new Image(tile.myTexture);
				img.x = tile.x;
				img.y = tile.y;
				addChild(img);
				tile.myImage = img;
			}
			
			flatten();
			
			//trace(this.name, "all shown, max tiles in ram:", _liveTiles.length);
		}
		
		// loops through all tiles and removes from memory
		public function removeAll():void {
			
			for each (var tile:StarlingTile in _liveTiles) {
				tile.isInRAM = false;
				removeChild(tile.myImage);
				
				tile.myImage.dispose();
				tile.myTexture.dispose();
				
				tile.myImage = null;
				tile.myTexture = null;
			}
		}
		
		public function destroy():void {
			
			_timer.removeEventListener(TimerEvent.TIMER, onTimer);
			_timer.reset();
			removeEventListeners();
			removeAll();
			removeChildren(0, -1, true);
			
			// reset
			_followMe = null;
			if (_imagesArray) {
				_imagesArray.length = 0;
				_imagesArray = null;
			}
			_imagesMC = null;
			_liveTiles.length = 0;
			_liveTiles = null;
		}
		
	}
}