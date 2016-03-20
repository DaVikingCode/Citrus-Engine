package citrus.utils {

	import org.osflash.signals.Signal;

	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;

	/**
	 * The LevelManager is a complex but powerful class, you can use simple states for levels with SWC/SWF/XML.
	 * 
	 * <p>Before using it, be sure that you have good OOP knowledge. For using it, you must use an Abstract state class 
	 * that you give as constructor parameter : <code>Alevel</code>.</p> 
	 * 
	 * <p>The six ways to set up your level : 
	 * <ul>
	 * <li><code>levelManager.levels = [Level1, Level2];</code></li>
	 * <li><code>levelManager.levels = [[Level1, "level1.swf"], [level2, "level2.swf"]];</code></li>
	 * <li><code>levelManager.levels = [[Level1, "level1.xml"], [level2, "level2.xml"]];</code></li>
	 * <li><code>levelManager.levels = [[Level1, level1XMLVar], [level2, level2XMLVar]];</code></li>
	 * <li><code>levelManager.levels = [[Level1, XML(new level1XMLEmbed())], [level2, XML(new level2XMLEmbed())]];</code></li>
	 * <li><code>levelManager.levels = [[Level1, Level1_SWC], [level2, Level2_SWC]];</code></li>
	 * </ul></p>
	 * 
	 * <p>An instantiation example in your Main class (you may also use the AGameData to store your levels) :
	 * <code>levelManager = new LevelManager(ALevel);
	 * levelManager.onLevelChanged.add(_onLevelChanged);
	 * levelManager.levels = [Level1, Level2];
	 * levelManager.gotoLevel();</code></p>
	 * 
	 * <p>The <code>_onLevelChanged</code> function gives in parameter the <code>Alevel</code> that you associate to your state : <code>state = lvl;</code>
	 * Then you can associate other functions :
	 * <ul>
	 * <li><code>lvl.lvlEnded.add(_nextLevel);</code></li>
	 * <li><code>lvl.restartLevel.add(_restartLevel);</code></li>
	 * </ul>
	 * And their respective actions :
	 * <ul>
	 * <li><code>_levelManager.nextLevel();</code></li>
	 * <li><code>state = _levelManager.currentLevel as IState;</code></li>
	 * </ul></p>
	 * 
	 * <p>The ALevel class must implement <code>public var lvlEnded</code> and <code>restartLevel</code> Signals in its constructor.
	 * If you have associated a SWF or SWC file to your level, you must add a flash MovieClip as a parameter into its constructor, 
	 * or a XML if it is one!</p>
	 */
	public class LevelManager {

		static private var _instance:LevelManager;

		public var onLevelChanged:Signal;
		
		public var checkPolicyFile:Boolean = false;
		
		/**
		 * If you want to load your SWF level on iOS, set it to ApplicationDomain.currentDomain.
		 */
		public var applicationDomain:ApplicationDomain = null;
		public var securityDomain:SecurityDomain = null;
		
		public var levels:Array;
		public var currentLevel:Object;
		
		/**
		 * If set to true, and the level comes from an SWF, the SWF is only loaded once, then cached.
		 * Enable this if you plan to deliver an IOS app, since IOS does not support SWF reloading
		 * in AOT (build) mode.
		 */
		public var enableSwfCaching:Boolean = false;
		
		private var _ALevel:Class;
		private var _currentIndex:uint;		
		private var _levelData:Array;

		public function LevelManager(ALevel:Class) {

			_instance = this;
			
			_ALevel = ALevel;
			_levelData = new Array();

			onLevelChanged = new Signal(_ALevel);
			_currentIndex = 0;
		}

		static public function getInstance():LevelManager {
			return _instance;
		}


		public function destroy():void {
			
			onLevelChanged.removeAll();
			
			currentLevel = null;
		}

		public function nextLevel():void {

			if (_currentIndex < levels.length - 1) {
				++_currentIndex;
			}

			gotoLevel();
		}

		public function prevLevel():void {

			if (_currentIndex > 0) {
				--_currentIndex;
			}

			gotoLevel();
		}

		/**
		 * Call the LevelManager instance's gotoLevel() function to launch your first level, or you may specify it.
		 * @param index the level index from 1 to ... ; different from the levels' array indexes.
		 */
		public function gotoLevel(index:uint = 0):void {

			if (index != 0)
				_currentIndex = index - 1;

			// Level SWF and SWC are undefined
			if (levels[_currentIndex][0] == undefined) {

				currentLevel = _ALevel(new levels[_currentIndex]);

				onLevelChanged.dispatch(currentLevel);
				
			// It's a SWC or a XML ?
			} else if (levels[_currentIndex][1] is Class || levels[_currentIndex][1] is XML) {
				
				currentLevel = (levels[_currentIndex][1] is Class) ? _ALevel(new levels[_currentIndex][0](new levels[_currentIndex][1]())) : _ALevel(new levels[_currentIndex][0](levels[_currentIndex][1]));
				
				onLevelChanged.dispatch(currentLevel);				
				
			// So it's an external SWF or XML, we load it 
			} else {
				
				var isXml:String = levels[_currentIndex][1].substring(levels[_currentIndex][1].length - 4).toLowerCase();
				if (isXml == ".xml" || isXml == ".lev" || isXml == ".tmx") {
					
					var urlLoader:URLLoader = new URLLoader();
					urlLoader.load(new URLRequest(levels[_currentIndex][1]));
					urlLoader.addEventListener(Event.COMPLETE, _levelLoaded);
					
				} else {
					
					if (enableSwfCaching && _levelData.length > _currentIndex && _levelData[_currentIndex] != null) {
						// Use already loaded (cached) SWF content:
						createLevelFromCache();
					} else {
						// load SWF from file:
						var loader:Loader = new Loader();
						var loaderContext:LoaderContext = new LoaderContext(checkPolicyFile, applicationDomain, securityDomain);
						loader.load(new URLRequest(levels[_currentIndex][1]), loaderContext);
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _levelLoaded);
						loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _handleLoaderError);
					}
				}
			}
		}

		private function _levelLoaded(evt:Event):void {
			if (evt.target is URLLoader) {
				currentLevel = _ALevel(new levels[_currentIndex][0](XML(evt.target.data)));
			} else {
				if (enableSwfCaching) {
					_levelData[_currentIndex] = evt.target.loader.content;
				}
			
				currentLevel = _ALevel(new levels[_currentIndex][0](evt.target.loader.content));
			}
			
			onLevelChanged.dispatch(currentLevel);
			
			if (evt.target is Loader) {
				
				evt.target.contentLoaderInfo.removeEventListener(Event.COMPLETE, _levelLoaded);
				evt.target.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _handleLoaderError);
				evt.target.loader.unloadAndStop();		
					
			} else if (evt.target is URLLoader) {
				evt.target.removeEventListener(Event.COMPLETE, _levelLoaded);
			}
		}
		
		/**
		 * Creates a level form a cached object. Used when enableSwfCache is set to true,
		 * to prevent SWF-reloading, which is not possible on IOS builds (AOT mode).
		 */
		private function createLevelFromCache():void {
			currentLevel = _ALevel(new levels[_currentIndex][0](_levelData[_currentIndex]));
			onLevelChanged.dispatch(currentLevel);
		}
		
		private function _handleLoaderError(evt:IOErrorEvent):void {
			trace(evt.type + " - " + evt.text);
		}

		public function get nameCurrentLevel():String {
			return currentLevel.nameLevel;
		}

		public function get currentIndex():uint
		{
			return _currentIndex;
		}
	}
}