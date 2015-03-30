package citrus.utils {

	import citrus.core.CitrusEngine;
	import flash.display.Stage;
	import flash.system.Capabilities;

	/**
	 * Last updated: March 27th 2015 by @SnkyGames
	 * This class provides platform information.
	 *
	 * Do not use Capabilities.os or Capabilities.manufacturer to determine a capability based on the operating system
	 * Different launch images can be displayed on an iPad and iPhone 6 plus, based on their orientation, at the time of application launch.
	 * There are over 11,000 unique Android devices, need more consts GUYS..
	 *
	 *
	 *
	 * Some interesting links?
	 *
	 * http://blogs.adobe.com/airodynamics/2015/03/09/launch-images-on-ios-with-adobe-air/
	 * http://forum.starling-framework.org/topic/iphone-6-question
	 * http://qz.com/109657/here-are-the-11868-devices-and-counting-that-every-android-app-has-to-work-on/
	 * http://carl-topham.com/theblog/post/cross-platform-flash-as3-cd-rom-part-1/
	 * http://ivomynttinen.com/blog/the-ios-7-design-cheat-sheet/
	 * http://jacksondunstan.com/articles/2596#more-2596
	 * http://forum.starling-framework.org/topic/detect-device-modelperformance/page/2 ( sigh, so many.. different ways )
	 *
	 */

	public class Platform {

		static private const _PLAYER_VERSION:String = Capabilities.version.substr( 0 , 3 );
		static private const _PLAYER_TYPE:String = Capabilities.playerType; // "Desktop" == air-runtime? , "StandAlone" == ? , "PlugIn" == browser, "ActiveX" == browser

		//TIP: ( iOS Status Bar ) Height
		static private const _IOS_LEGACY_STATUSBAR_HEIGHT:uint = 20;
		static private const _IOS_RETINA_STATUSBAR_HEIGHT:uint = 40;

		//TIP: ( 2G , 3G , 3GS ) Portrait: Default~iphone.png 
		static private const _IPHONE_LEGACY_WIDTH:uint = 320;
		static private const _IPHONE_LEGACY_HEIGHT:uint = 480;

		//TIP: ( 4 / 4S ) Portrait: Default@2x~iphone.png 
		static private const _IPHONE_RETINA_FOUR_WIDTH:uint = 640;
		static private const _IPHONE_RETINA_FOUR_HEIGHT:uint = 960;

		//TIP: ( 5 , 5C , 5S , iPOD Touch 5g ) Portrait: Default-568h@2x~iphone.png 
		static private const _IPHONE_RETINA_FIVE_WIDTH:uint = 640;
		static private const _IPHONE_RETINA_FIVE_HEIGHT:uint = 1136;

		//TIP: ( 6 , 6 zoom ) Portrait: Default-375w-667h@2x~iphone.png 
		static private const _IPHONE_RETINA_SIX_WIDTH:uint = 750;
		static private const _IPHONE_RETINA_SIX_HEIGHT:uint = 1334;

		//TIP: ( 6+ , 6+ zoom ) Portrait: Default-414w-736h@3x~iphone.png | Landscape: Default-Landscape-414w-736h@3x~iphone.png 
		static private const _IPHONE_RETINA_SIX_PLUS_WIDTH:uint = 1242;
		static private const _IPHONE_RETINA_SIX_PLUS_HEIGHT:uint = 2208;

		//TIP: ( 1 / 2 / mini ) Portrait: Default-Portrait~ipad.png | Upside down Portrait: Default-PortraitUpsideDown~ipad.png | Left Landscape: Default-Landscape~ipad.png | Right Landscape: Default-LandscapeRight~ipad.png 
		static private const _IPAD_LEGACY_WIDTH:uint = 768;
		static private const _IPAD_LEGACY_HEIGHT:uint = 1024;

		//TIP: ( 3 / 4 / mini 2 / mini 3 / air / air 2 ) Portrait: Default-Portrait@2x~ipad.png | Upside down Portrait: Default-PortraitUpsideDown@2x~ipad.png | Left Landscape: Default-LandscapeLeft@2x~ipad.png | Right Landscape: Default-LandscapeRight@2x~ipad.png
		static private const _IPAD_RETINA_WIDTH:uint = 1536;
		static private const _IPAD_RETINA_HEIGHT:uint = 2048;

		static private var _STAGE:Stage;
		static private var _PLATFORM_IS_BROWSER:uint = 2;
		static private var _PLATFORM_IS_DESKTOP:uint = 2;
		static private var _PLATFORM_IS_IOS:uint = 2;
		static private var _PLATFORM_IS_AND:uint = 2;

		static private var _PLATFORM_SPECIFICS_IS_IPAD:uint = 2;
		static private var _PLATFORM_SPECIFICS_IS_IPAD_LEGACY:uint = 2;
		static private var _PLATFORM_SPECIFICS_IS_IPAD_RETINA:uint = 2;
		static private var _PLATFORM_SPECIFICS_IS_IPHONE:uint = 2;
		static private var _PLATFORM_SPECIFICS_IS_IPHONE_LEGACY:uint = 2;
		static private var _PLATFORM_SPECIFICS_IS_IPHONE_FOUR:uint = 2;
		static private var _PLATFORM_SPECIFICS_IS_IPHONE_FIVE:uint = 2;
		static private var _PLATFORM_SPECIFICS_IS_IPHONE_SIX:uint = 2;
		static private var _PLATFORM_SPECIFICS_IS_IPHONE_SIX_PLUS:uint = 2;
		static private var _PLATFORM_SPECIFICS_IS_WIN:uint = 2;
		static private var _PLATFORM_SPECIFICS_IS_MAC:uint = 2;
		static private var _PLATFORM_SPECIFICS_IS_LNX:uint = 2;

		static private var _PLATFORM_SPECIFICS_IS_RETINA:uint = 2;
		static private var _PLATFORM_SPECIFICS_IS_LANDSCAPE:Boolean = false; //I used a bool.. oh noes >:
		//static private var _PLATFORM_SPECIFICS_IS_IPHONE_ZOOMED:uint = 2; //I know, I know, I've gone overboard, gg apple, not sure if needed. :D

		
		
		
		public function Platform(){ /*...*/	}

		///PUBLIC FINISHED - these should be called outside of this class. - e.g. if ( Platform.isIphoneSixPlus() ) { .. } --------- 0 = false / 1 = true / 2 = not queried ( only queries once, tis why no bools, they take up the same memory space anyway )
		static public function isBrowser():uint {
			return _PLATFORM_IS_BROWSER != 2 ? _PLATFORM_IS_BROWSER : queryBrowser();
		}

		static public function isDesktop():uint {
			return _PLATFORM_IS_DESKTOP != 2 ? _PLATFORM_IS_DESKTOP : queryDesktop();
		}

		static public function isIOS():uint {
			return _PLATFORM_IS_IOS != 2 ? _PLATFORM_IS_IOS : queryIOS();
		}

		static public function isAndroid():uint {
			return _PLATFORM_IS_AND != 2 ? _PLATFORM_IS_AND : queryAndroid();
		}

		//more specific..
		static public function isWindows():uint {
			return _PLATFORM_SPECIFICS_IS_WIN != 2 ? _PLATFORM_SPECIFICS_IS_WIN : queryWindows();
		}

		static public function isMac():uint {
			return _PLATFORM_SPECIFICS_IS_MAC != 2 ? _PLATFORM_SPECIFICS_IS_MAC : queryMac();
		}

		static public function isLinux():uint {
			return _PLATFORM_SPECIFICS_IS_LNX != 2 ? _PLATFORM_SPECIFICS_IS_LNX : queryLinux();
		}

		static public function isIphoneLegacy():uint {
			return _PLATFORM_SPECIFICS_IS_IPHONE_LEGACY != 2 ? _PLATFORM_SPECIFICS_IS_IPHONE_LEGACY : queryIphoneLegacy();
		}

		static public function isIphoneFour():uint {
			return _PLATFORM_SPECIFICS_IS_IPHONE_FOUR != 2 ? _PLATFORM_SPECIFICS_IS_IPHONE_FOUR : queryIphoneFour();
		}

		static public function isIphoneFive():uint {
			return _PLATFORM_SPECIFICS_IS_IPHONE_FIVE != 2 ? _PLATFORM_SPECIFICS_IS_IPHONE_FIVE : queryIphoneFive();
		}

		static public function isIphoneSix():uint {
			return _PLATFORM_SPECIFICS_IS_IPHONE_SIX != 2 ? _PLATFORM_SPECIFICS_IS_IPHONE_SIX : queryIphoneSix();
		}

		static public function isIphoneSixPlus():uint {
			return _PLATFORM_SPECIFICS_IS_IPHONE_SIX_PLUS != 2 ? _PLATFORM_SPECIFICS_IS_IPHONE_SIX_PLUS : queryIphoneSixPlus();
		}

		static public function isIpadLegacy():uint {
			return _PLATFORM_SPECIFICS_IS_IPAD_LEGACY != 2 ? _PLATFORM_SPECIFICS_IS_IPAD_LEGACY : queryIpadLegacy();
		}

		static public function isIpadRetina():uint {
			return _PLATFORM_SPECIFICS_IS_IPAD_RETINA != 2 ? _PLATFORM_SPECIFICS_IS_IPAD_RETINA : queryIpadRetina();
		}

		static public function isIpad():uint {
			return _PLATFORM_SPECIFICS_IS_IPAD != 2 ? _PLATFORM_SPECIFICS_IS_IPAD : ( isIpadLegacy() || isIpadRetina() );
		}

		static public function isIphone():uint {
			return _PLATFORM_SPECIFICS_IS_IPHONE != 2 ? _PLATFORM_SPECIFICS_IS_IPHONE : ( isIOS() && uint( !isIpad() ) );
		}

		//extras
		static public function isRetina():uint {
			return _PLATFORM_SPECIFICS_IS_RETINA != 2 ? _PLATFORM_SPECIFICS_IS_RETINA : ( isIOS() && uint( !queryIphoneLegacy() ) && uint( !queryIpadLegacy() ) );
		}

		static private function isLandscape():Boolean {
			//skipping the query way.. as this can't just be checked once, as the value could change.

			//stageValidate() - maybe a bit expensive/useless? here's why..
			//I could see isLandscape() being called in an update, this cannot be stored of course, as the value may change depending on the application being developed,
			//although.. maybe it can be stored.. maybe CE / Starling has a 'handleOrientationChanged' function, that could modify isLandscape variable in this class,
			//removing the need to: call 2 extra imports / call stageValidate() / even compare the width and the height ( at least in this class ).
			stageValidate();
			_PLATFORM_SPECIFICS_IS_LANDSCAPE = ( _STAGE.fullScreenWidth > _STAGE.fullScreenHeight );
			return _PLATFORM_SPECIFICS_IS_LANDSCAPE;
		}

		
		static public function get iOS_STATUSBAR_HEIGHT():uint {
			if ( !isIOS() )
				throw Error( "Not an iOS device!" );
			if ( isIpadLegacy() || isIphoneLegacy() ){
				return _IOS_LEGACY_STATUSBAR_HEIGHT;
			} else if ( isIphone() || isIpad() ){
				return _IOS_RETINA_STATUSBAR_HEIGHT;
			} else
				throw Error( "Unknown / New iOS device, please update Platform.as" );
		}

		static public function get iPHONE_WIDTH():uint {
			if ( !isIOS() )
				throw Error( "Not an iOS device!" );

			if ( isIphoneLegacy() )
				return _IPHONE_LEGACY_WIDTH;
			else if ( isIphoneFour() )
				return _IPHONE_RETINA_FOUR_WIDTH;
			else if ( isIphoneFive() )
				return _IPHONE_RETINA_FIVE_WIDTH;
			else if ( isIphoneSix() )
				return _IPHONE_RETINA_SIX_WIDTH;
			else if ( isIphoneSixPlus() )
				return _IPHONE_RETINA_SIX_PLUS_WIDTH;

			throw Error( "Unknown / New iOS device, please update Platform.as" );
		}

		static public function get iPHONE_HEIGHT():uint {
			if ( !isIOS() )
				throw Error( "Not an iOS device!" );

			if ( isIphoneLegacy() )
				return _IPHONE_LEGACY_HEIGHT;
			else if ( isIphoneFour() )
				return _IPHONE_RETINA_FOUR_HEIGHT;
			else if ( isIphoneFive() )
				return _IPHONE_RETINA_FIVE_HEIGHT;
			else if ( isIphoneSix() )
				return _IPHONE_RETINA_SIX_HEIGHT;
			else if ( isIphoneSixPlus() )
				return _IPHONE_RETINA_SIX_PLUS_HEIGHT;
			
			throw Error( "Unknown / New iOS device, please update Platform.as" );
		}

		static public function get iPAD_WIDTH():uint {
			if ( !isIOS() )
				throw Error( "Not an iOS device!" );

			if ( isIpadLegacy() )
				return _IPAD_LEGACY_WIDTH;
			else if ( isIpadRetina() )
				return _IPAD_RETINA_WIDTH;
			else
				throw Error( "Unknown / New iOS device, please update Platform.as" );
		}

		static public function get iPAD_HEIGHT():uint {
			if ( !isIOS() )
				throw Error( "Not an iOS device!" );

			if ( isIpadLegacy() )
				return _IPAD_LEGACY_HEIGHT;
			else if ( isIpadRetina() )
				return _IPAD_RETINA_HEIGHT;
			else
				throw Error( "Unknown / New iOS device, please update Platform.as" );
		}

		///PRIVATE FINISHED FUNCTIONS - unused publically, only ever called once, then stores results in the static vars.
		static private function stageValidate():void {
			var _ce:CitrusEngine = CitrusEngine.getInstance();
			if ( !_ce )
				throw Error( "Citrus Engine is null" );

			_STAGE = _ce.stage;
			if ( !_STAGE )
				throw Error( "Flash Stage is null.. uhm... guys? help.." );
		}

		static private function queryDesktop():uint {
			_PLATFORM_SPECIFICS_IS_WIN = uint( _PLAYER_VERSION == "WIN" );
			_PLATFORM_SPECIFICS_IS_MAC = uint( _PLAYER_VERSION == "MAC" );
			_PLATFORM_SPECIFICS_IS_LNX = uint( _PLAYER_VERSION == "LNX" );
			return ( _PLATFORM_SPECIFICS_IS_WIN || _PLATFORM_SPECIFICS_IS_MAC || _PLATFORM_SPECIFICS_IS_LNX );
		}

		//specifics..
		static private function queryWindows():uint {
			_PLATFORM_SPECIFICS_IS_WIN = uint( _PLAYER_VERSION == "WIN" );
			return _PLATFORM_SPECIFICS_IS_WIN;
		}

		static private function queryMac():uint {
			_PLATFORM_SPECIFICS_IS_MAC = uint( _PLAYER_VERSION == "MAC" );
			return _PLATFORM_SPECIFICS_IS_MAC;
		}

		static private function queryLinux():uint {
			_PLATFORM_SPECIFICS_IS_LNX = uint( _PLAYER_VERSION == "LNX" );
			return _PLATFORM_SPECIFICS_IS_LNX;
		}

		static private function queryIphoneLegacy():uint {
			if ( queryIOS() ){
				stageValidate();
				if ( isLandscape() )
					return ( uint( _STAGE.fullScreenWidth == _IPHONE_LEGACY_HEIGHT ) || uint( _STAGE.fullScreenWidth == ( _IPHONE_LEGACY_HEIGHT - _IOS_LEGACY_STATUSBAR_HEIGHT ) ) );
				else
					return ( uint( _STAGE.fullScreenWidth == _IPHONE_LEGACY_WIDTH ) || uint( _STAGE.fullScreenWidth == ( _IPHONE_LEGACY_WIDTH - _IOS_LEGACY_STATUSBAR_HEIGHT ) ) );
			} else
				return 0;
		}

		static private function queryIphoneFour():uint {
			if ( queryIOS() ){
				stageValidate();
				if ( isLandscape() )
					return ( uint( _STAGE.fullScreenWidth == _IPHONE_RETINA_FOUR_HEIGHT ) || uint( _STAGE.fullScreenWidth == ( _IPHONE_RETINA_FOUR_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT ) ) );
				else
					return ( uint( _STAGE.fullScreenWidth == _IPHONE_RETINA_FOUR_WIDTH ) || uint( _STAGE.fullScreenWidth == ( _IPHONE_RETINA_FOUR_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT ) ) );
			} else
				return 0;
		}

		static private function queryIphoneFive():uint {
			if ( queryIOS() ){
				stageValidate();
				if ( isLandscape() )
					return ( uint( _STAGE.fullScreenWidth == _IPHONE_RETINA_FIVE_HEIGHT ) || uint( _STAGE.fullScreenWidth == ( _IPHONE_RETINA_FIVE_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT ) ) );
				else
					return ( uint( _STAGE.fullScreenWidth == _IPHONE_RETINA_FIVE_WIDTH ) || uint( _STAGE.fullScreenWidth == ( _IPHONE_RETINA_FIVE_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT ) ) );
			} else
				return 0;
		}

		static private function queryIphoneSix():uint {
			if ( queryIOS() ){
				stageValidate();
				if ( isLandscape() )
					return ( uint( _STAGE.fullScreenWidth == _IPHONE_RETINA_SIX_HEIGHT ) || uint( _STAGE.fullScreenWidth == ( _IPHONE_RETINA_SIX_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT ) ) );
				else
					return ( uint( _STAGE.fullScreenWidth == _IPHONE_RETINA_SIX_WIDTH ) || uint( _STAGE.fullScreenWidth == ( _IPHONE_RETINA_SIX_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT ) ) );
			} else
				return 0;
		}

		static private function queryIphoneSixPlus():uint {
			if ( queryIOS() ){
				stageValidate();
				if ( isLandscape() )
					return ( uint( _STAGE.fullScreenWidth == _IPHONE_RETINA_SIX_PLUS_HEIGHT ) || uint( _STAGE.fullScreenWidth == ( _IPHONE_RETINA_SIX_PLUS_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT ) ) );
				else
					return ( uint( _STAGE.fullScreenWidth == _IPHONE_RETINA_SIX_PLUS_WIDTH ) || uint( _STAGE.fullScreenWidth == ( _IPHONE_RETINA_SIX_PLUS_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT ) ) );
			} else
				return 0;
		}

		static private function queryIpadLegacy():uint {
			if ( queryIOS() ){
				if ( isLandscape() )
					return ( uint( _STAGE.fullScreenWidth == _IPAD_LEGACY_HEIGHT ) || uint( _STAGE.fullScreenWidth == ( _IPAD_LEGACY_HEIGHT - _IOS_LEGACY_STATUSBAR_HEIGHT ) ) );
				else
					return ( uint( _STAGE.fullScreenWidth == _IPAD_LEGACY_WIDTH ) || uint( _STAGE.fullScreenWidth == ( _IPAD_LEGACY_WIDTH - _IOS_LEGACY_STATUSBAR_HEIGHT ) ) );
			} else
				return 0;
		}

		static private function queryIpadRetina():uint {
			if ( queryIOS() ){
				if ( isLandscape() )
					return ( uint( _STAGE.fullScreenWidth == _IPAD_RETINA_HEIGHT ) || uint( _STAGE.fullScreenWidth == ( _IPAD_RETINA_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT ) ) );
				else
					return ( uint( _STAGE.fullScreenWidth == _IPAD_RETINA_WIDTH ) || uint( _STAGE.fullScreenWidth == ( _IPAD_RETINA_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT ) ) );
			} else
				return 0;
		}
		
		///maybe can be updated further
		static private function queryIOS():uint {
			_PLATFORM_IS_IOS = uint( _PLAYER_VERSION == "IOS" );
			return _PLATFORM_IS_IOS;
		}

		static private function queryAndroid():uint {
			_PLATFORM_IS_AND = uint( _PLAYER_VERSION == "AND" );
			if ( 1 == _PLATFORM_IS_AND ){
				//*...query everything Android

					//*/
			}
			return _PLATFORM_IS_AND;
		}

		static private function queryBrowser():uint {
			//it is indeed possible to get a more specific browser.. ( but I don't think that it is a very accurate result )
			_PLATFORM_IS_BROWSER = ( uint( _PLAYER_TYPE == "PlugIn" ) || uint( _PLAYER_TYPE == "ActiveX" ) );
			return _PLATFORM_IS_BROWSER;
		}
	}
}