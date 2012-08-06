package com.citrusengine.utils {

	import starling.display.Sprite;

	import org.osflash.signals.Signal;

	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.Dictionary;

	/**
	 * The load manager keeps track of the loading status of Loader objects, returning an overall value for all graphics
	 * that are being loaded. This class is necessary when loading level graphics at runtime and finding out when all the graphics
	 * are finished loading. The LoadManager instance can be accessed via the state's CitrusView object.
	 * There is a LoadManager for each view state. 
	 */
	public class LoadManager {

		public var onLoadComplete:Signal;

		private var _bytesLoaded:Dictionary = new Dictionary();
		private var _bytesTotal:Dictionary = new Dictionary();
		private var _numLoadersLoading:Number = 0;

		/**
		 * Creates a new LoadManager instance. The CitrusView does this for you. You can access the created LoadManager view the 
		 * CitrusView object. 
		 */
		public function LoadManager() {
			
			onLoadComplete = new Signal();
		}

		public function destroy():void {
			
			onLoadComplete.removeAll();
		}

		/**
		 * Returns the sum of all the bytes that have been loaded by the current view. 
		 */
		public function get bytesLoaded():Number {
			
			var bytesLoaded:Number = 0;
			for each (var bytes:Number in _bytesLoaded) {
				bytesLoaded += bytes;
			}
			
			return bytesLoaded;
		}

		/**
		 * Returns the sum of all the bytes that will need to be loaded by the current view. 
		 */
		public function get bytesTotal():Number {
			
			var bytesTotal:Number = 1;
			for each (var bytes:Number in _bytesTotal) {
				bytesTotal += bytes;
			}
			
			return bytesTotal;
		}

		/**
		 * The CitrusView calls this method on all graphics objects that it creates to monitor its load progress.
		 * It passes any object into the add() method, and it will recurse through it and search for any loaders on the object.
		 * If/when it finds a loader (or if it IS a loader), it will add it to the list of Loaders that it is monitoring.
		 * If you use Starling view, it can't be recursive, so we check if the StarlingArt's loader is defined.
		 * @param potentialLoader The object that needs load monitoring.
		 * @param recursionDepth How many child objects the add() method should recurse through before giving up searching for a Loader object.
		 * @return Whether or not it found a loader object.
		 */
		public function add(potentialLoader:*, recursionDepth:Number = 1):Boolean {
			
			var loader:Loader;

			if (potentialLoader is Loader || (potentialLoader is Sprite && potentialLoader.loader)) {
				
				// We found our first loader, so reset the bytesLoaded/Total dictionaries to get a fresh count.
				if (_numLoadersLoading == 0) {
					_bytesLoaded = new Dictionary();
					_bytesTotal = new Dictionary();
				}

				_numLoadersLoading++;
				loader = (potentialLoader is Loader) ? potentialLoader as Loader : potentialLoader.loader as Loader;
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, handleLoaderProgress);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoaderComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleLoaderError);
				_bytesLoaded[loader] = 0;
				_bytesTotal[loader] = 0;
				
				return true;
				
			} else if (potentialLoader is flash.display.Sprite) {
				
				var searchDepth:Number = searchDepth - 1;
				var n:Number = flash.display.Sprite(potentialLoader).numChildren;
				
				for (var i:int = 0; i < n; i++) {
					var found:Boolean = add(flash.display.Sprite(potentialLoader).getChildAt(i), searchDepth);
					if (found)
						return true;
				}
				
				return false;
				
			}

			return false;
		}

		private function handleLoaderProgress(e:ProgressEvent):void {
			_bytesLoaded[e.target.loader] = e.bytesLoaded;
			_bytesTotal[e.target.loader] = e.bytesTotal;
		}

		private function handleLoaderComplete(e:Event):void {
			e.target.loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, handleLoaderProgress);
			e.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, handleLoaderComplete);
			e.target.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, handleLoaderError);
			_bytesLoaded[e.target.loader] = _bytesTotal[e.target.loader];
			_numLoadersLoading--;
			if (_numLoadersLoading == 0)
				onLoadComplete.dispatch();
		}

		private function handleLoaderError(e:IOErrorEvent):void {
			e.target.loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, handleLoaderProgress);
			e.target.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, handleLoaderComplete);
			e.target.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, handleLoaderError);
			_numLoadersLoading--;
			if (_numLoadersLoading == 0)
				onLoadComplete.dispatch();
			// TODO Make this error more robust.
			trace("Warning: Art loading error in current state: " + e.text);
		}
	}
}