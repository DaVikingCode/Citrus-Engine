package citrus.utils {
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.system.Capabilities;
	import citrus.core.CitrusEngine;
	
	/**
	 * Author(s): @SnkyGames ( Jas 'Snky' M. )
	 * Copyright (c) 2015-2017 SnkyGames
	 * Distributed under the terms of the MIT license. (https://opensource.org/licenses/MIT)
	 *
	 * The software is provided as is and has not been *thoroughly* tested, use at your own expense.
	 *
	 *
	 *
	 *
	 *
	 *
	 *
	 * Tailored for: CitrusEngine
	 *
	 * +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 * This class provides platform information.
	 * Last updated: 31/May/2017
	 *
	 *     TODO: Status Bar - On/Off? Affects Platform.as calculations? (iPhone)
	 *     TODO: Display Zoom - On/Off? Affects Platform.as calculations? (iPhone)
	 *     TODO: A way to determine display specification differences between 5/SE (iPhone)
	 *     TODO: A way to determine display specification differences between 6/6s/7 and 6+/6s+/7+ (iPhone)
	 *
	 * +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 *
	 *
	 *
	 * Notes:
	 *     +Method 'stageValidate()' determines the wrapper this class supports.
	 *
	 *     +Methods 'isLandscape()' and 'isFullscreen()' can return three different values(0,1 and 2).
	 *         Value '2' can be used to identify if using 'FULL_SCREEN_INTERACTIVE' or if the device's width is equal to the device's height.
	 *
	 *     +"Do not use Capabilities.os or Capabilities.manufacturer to determine a capability based on the operating system."
	 *     +"Different launch images can be displayed on an iPad and iPhone 6 plus, based on their orientation, at the time of application launch."
	 *
	 *     +If display zoom is used on iPhone models 'six' and beyond:
	 *         iPhone6+ uses iPhone6 Splash
	 *         iPhone6  uses iPhone5 Splash
	 *         TODO: N/A
	 *         ..
	 *         .
	 *
	 *     +Some links that may be useful and relevant.
	 *         http://blogs.adobe.com/airodynamics/2015/03/09/launch-images-on-ios-with-adobe-air/
	 * 	      http://forum.starling-framework.org/topic/iphone-6-question
	 *         http://qz.com/109657/here-are-the-11868-devices-and-counting-that-every-android-app-has-to-work-on/
	 *         http://carl-topham.com/theblog/post/cross-platform-flash-as3-cd-rom-part-1/
	 *         http://ivomynttinen.com/blog/the-ios-7-design-cheat-sheet/
	 *         http://jacksondunstan.com/articles/2596#more-2596
	 *         http://forum.starling-framework.org/topic/detect-device-modelperformance/page/2
	 */
	
	public class Platform {
		
		// ( iOS Status Bar ) Height
		static protected const _IOS_LEGACY_STATUSBAR_HEIGHT:uint = 20; //hard coded value in points
		static protected const _IOS_RETINA_STATUSBAR_HEIGHT:uint = 40; //hard coded value in points
		// ( 2G , 3G , 3GS ) Portrait: Default~iphone.png
		static protected const _IPHONE_LEGACY_WIDTH:uint = 320;
		static protected const _IPHONE_LEGACY_HEIGHT:uint = 480;
		// ( 4 / 4S ) Portrait: Default@2x~iphone.png
		static protected const _IPHONE_RETINA_FOUR_WIDTH:uint = 640;
		static protected const _IPHONE_RETINA_FOUR_HEIGHT:uint = 960;
		// ( 5 , 5C , 5S , SE, iPOD Touch 5g ) Portrait: Default-568h@2x~iphone.png
		static protected const _IPHONE_RETINA_FIVESE_WIDTH:uint = 640;
		static protected const _IPHONE_RETINA_FIVESE_HEIGHT:uint = 1136;
		// ( 6 , 7 ) Portrait: Default-375w-667h@2x~iphone.png
		static protected const _IPHONE_RETINA_SIXSEVEN_WIDTH:uint = 750;
		static protected const _IPHONE_RETINA_SIXSEVEN_HEIGHT:uint = 1334;
		// ( 6+ , 7+ ) Portrait: Default-414w-736h@3x~iphone.png | Landscape: Default-Landscape-414w-736h@3x~iphone.png
		static protected const _IPHONE_RETINA_SIXSEVEN_PLUS_WIDTH:uint = 1242;
		static protected const _IPHONE_RETINA_SIXSEVEN_PLUS_HEIGHT:uint = 2208;
		// ( 1 / 2 / mini ) Portrait: Default-Portrait~ipad.png | Upside down Portrait: Default-PortraitUpsideDown~ipad.png | Left Landscape: Default-Landscape~ipad.png | Right Landscape: Default-LandscapeRight~ipad.png
		static protected const _IPAD_LEGACY_WIDTH:uint = 768;
		static protected const _IPAD_LEGACY_HEIGHT:uint = 1024;
		// ( 3 / 4 / mini 2 / mini 3 / air / air 2 ) Portrait: Default-Portrait@2x~ipad.png | Upside down Portrait: Default-PortraitUpsideDown@2x~ipad.png | Left Landscape: Default-LandscapeLeft@2x~ipad.png | Right Landscape: Default-LandscapeRight@2x~ipad.png
		static protected const _IPAD_RETINA_LEGACY_WIDTH:uint = 1536;
		static protected const _IPAD_RETINA_LEGACY_HEIGHT:uint = 2048;
		// ( N/A ) Portrait: N/A | Landscape: N/A
		static protected const _IPAD_RETINA_PRO_WIDTH:uint = 2048;
		static protected const _IPAD_RETINA_PRO_HEIGHT:uint = 2732;
		
		static protected var _PLAYER_VERSION:String = Capabilities.version.substr(0, 3);
		static protected var _PLAYER_TYPE:String = Capabilities.playerType;
		
		static protected var _PLATFORM_IS_BROWSER:uint = 2;
		static protected var _PLATFORM_IS_DESKTOP:uint = 2;
		static protected var _PLATFORM_IS_MOBILE:uint = 2;
		
		static protected var _PLATFORM_SPECIFICS_IS_IOS:uint = 2;
		static protected var _PLATFORM_SPECIFICS_IS_AND:uint = 2;
		static protected var _PLATFORM_SPECIFICS_IS_QNX:uint = 2;
		static protected var _PLATFORM_SPECIFICS_IS_WIN:uint = 2;
		static protected var _PLATFORM_SPECIFICS_IS_MAC:uint = 2;
		static protected var _PLATFORM_SPECIFICS_IS_LNX:uint = 2;
		
		static protected var _PLATFORM_SPECIFICS_IS_IPAD:uint = 2;
		static protected var _PLATFORM_SPECIFICS_IS_IPAD_LEGACY:uint = 2;
		static protected var _PLATFORM_SPECIFICS_IS_IPAD_RETINA_LEGACY:uint = 2;
		static protected var _PLATFORM_SPECIFICS_IS_IPAD_RETINA_PRO:uint = 2;
		static protected var _PLATFORM_SPECIFICS_IS_IPHONE:uint = 2;
		static protected var _PLATFORM_SPECIFICS_IS_IPHONE_LEGACY:uint = 2;
		static protected var _PLATFORM_SPECIFICS_IS_IPHONE_FOUR:uint = 2;
		static protected var _PLATFORM_SPECIFICS_IS_IPHONE_FIVESE:uint = 2;
		static protected var _PLATFORM_SPECIFICS_IS_IPHONE_SIXSEVEN:uint = 2;
		static protected var _PLATFORM_SPECIFICS_IS_IPHONE_SIXSEVEN_PLUS:uint = 2;
		static protected var _PLATFORM_SPECIFICS_IS_RETINA:uint = 2;
		static protected var _PLATFORM_SPECIFICS_IS_LANDSCAPE:uint;
		static protected var _PLATFORM_SPECIFICS_IS_FULLSCREEN:uint;
		static protected var _FLASH_STAGE:Stage;
		
		public function Platform() { /*...*/ }
		
		// PUBLIC FINISHED SECTION
		//     These methods should be called externally.
		//     'return value' explained: 0 = false, 1 = true, 2 = has not been queried(cached).
		static public function isBrowser():uint {
			return _PLATFORM_IS_BROWSER != 2 ? _PLATFORM_IS_BROWSER : queryBrowser();
		}
		
		static public function isDesktop():uint {
			return _PLATFORM_IS_DESKTOP != 2 ? _PLATFORM_IS_DESKTOP : queryDesktop();
		}
		
		static public function isMobile():uint {
			return _PLATFORM_IS_MOBILE != 2 ? _PLATFORM_IS_MOBILE : queryMobile();
		}
		
		static public function isIOS():uint {
			return _PLATFORM_SPECIFICS_IS_IOS != 2 ? _PLATFORM_SPECIFICS_IS_IOS : queryIOS();
		}
		
		static public function isAndroid():uint {
			return _PLATFORM_SPECIFICS_IS_AND != 2 ? _PLATFORM_SPECIFICS_IS_AND : queryAndroid();
		}
		
		static public function isBlackberry():uint {
			return _PLATFORM_SPECIFICS_IS_QNX != 2 ? _PLATFORM_SPECIFICS_IS_QNX : queryBlackberry();
		}
		
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
		
		static public function isIphoneFiveSE():uint {
			return _PLATFORM_SPECIFICS_IS_IPHONE_FIVESE != 2 ? _PLATFORM_SPECIFICS_IS_IPHONE_FIVESE : queryIphoneFiveSE();
		}
		
		static public function isIphoneSixSeven():uint {
			return _PLATFORM_SPECIFICS_IS_IPHONE_SIXSEVEN != 2 ? _PLATFORM_SPECIFICS_IS_IPHONE_SIXSEVEN : queryIphoneSixSeven();
		}
		
		static public function isIphoneSixSevenPlus():uint {
			return _PLATFORM_SPECIFICS_IS_IPHONE_SIXSEVEN_PLUS != 2 ? _PLATFORM_SPECIFICS_IS_IPHONE_SIXSEVEN_PLUS : queryIphoneSixSevenPlus();
		}
		
		static public function isIpadLegacy():uint {
			return _PLATFORM_SPECIFICS_IS_IPAD_LEGACY != 2 ? _PLATFORM_SPECIFICS_IS_IPAD_LEGACY : queryIpadLegacy();
		}
		
		static public function isIpadRetinaLegacy():uint {
			return _PLATFORM_SPECIFICS_IS_IPAD_RETINA_LEGACY != 2 ? _PLATFORM_SPECIFICS_IS_IPAD_RETINA_LEGACY : queryIpadRetinaLegacy();
		}
		
		static public function isIpadRetinaPro():uint {
			return _PLATFORM_SPECIFICS_IS_IPAD_RETINA_PRO != 2 ? _PLATFORM_SPECIFICS_IS_IPAD_RETINA_PRO : queryIpadRetinaPro();
		}
		
		static public function isIpad():uint {
			return _PLATFORM_SPECIFICS_IS_IPAD != 2 ? _PLATFORM_SPECIFICS_IS_IPAD : (isIpadLegacy() || isIpadRetinaLegacy() || isIpadRetinaPro());
		}
		
		static public function isIphone():uint {
			return _PLATFORM_SPECIFICS_IS_IPHONE != 2 ? _PLATFORM_SPECIFICS_IS_IPHONE : (isIOS() && uint(!isIpad()));
		}
		
		static public function isRetina():uint {
			return _PLATFORM_SPECIFICS_IS_RETINA != 2 ? _PLATFORM_SPECIFICS_IS_RETINA : (isIOS() && uint(!queryIphoneLegacy()) && uint(!queryIpadLegacy()));
		}
		
		static public function isLandscape():uint {
			// Not using the query(cache) method.. this cannot be checked only once, the value can change at run-time.
			stageValidate();
			(_FLASH_STAGE.stageWidth == _FLASH_STAGE.stageHeight) ? _PLATFORM_SPECIFICS_IS_LANDSCAPE = 2 : (_PLATFORM_SPECIFICS_IS_LANDSCAPE = uint(_FLASH_STAGE.stageWidth >= _FLASH_STAGE.stageHeight) ? 1 : 0);
			return _PLATFORM_SPECIFICS_IS_LANDSCAPE;
		}
		
		static public function isFullscreen():uint {
			// Not using the query(cache) method.. this cannot be checked only once, the value can change at run-time.
			stageValidate();
			(_FLASH_STAGE.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) ? _PLATFORM_SPECIFICS_IS_FULLSCREEN = 2 : ((_FLASH_STAGE.displayState == StageDisplayState.FULL_SCREEN) ? _PLATFORM_SPECIFICS_IS_FULLSCREEN = 1 : _PLATFORM_SPECIFICS_IS_FULLSCREEN = 0);
			return _PLATFORM_SPECIFICS_IS_FULLSCREEN;
		}
		
		static public function get iOS_STATUSBAR_HEIGHT():uint {
			if (!isIOS())
				throw Error(" Not an iOS device!");
			if (isIpadLegacy() || isIphoneLegacy()) {
				return _IOS_LEGACY_STATUSBAR_HEIGHT;
			} else if (isIphone() || isIpad()) {
				return _IOS_RETINA_STATUSBAR_HEIGHT;
			} else
				throw Error(" Unknown / New iOS device - Please request 'Platform.as' to be updated.");
		}
		
		static public function get iPHONE_WIDTH():uint {
			if (!isIOS())
				throw Error(" Not an iOS device!");
			if (isIphoneLegacy())
				return _IPHONE_LEGACY_WIDTH;
			else if (isIphoneFour())
				return _IPHONE_RETINA_FOUR_WIDTH;
			else if (isIphoneFiveSE())
				return _IPHONE_RETINA_FIVESE_WIDTH;
			else if (isIphoneSixSeven())
				return _IPHONE_RETINA_SIXSEVEN_WIDTH;
			else if (isIphoneSixSevenPlus())
				return _IPHONE_RETINA_SIXSEVEN_PLUS_WIDTH;
			else
				throw Error(" Unknown / New iOS device - Please request 'Platform.as' to be updated.");
		}
		
		static public function get iPHONE_HEIGHT():uint {
			if (!isIOS())
				throw Error(" Not an iOS device!");
			
			if (isIphoneLegacy())
				return _IPHONE_LEGACY_HEIGHT;
			else if (isIphoneFour())
				return _IPHONE_RETINA_FOUR_HEIGHT;
			else if (isIphoneFiveSE())
				return _IPHONE_RETINA_FIVESE_HEIGHT;
			else if (isIphoneSixSeven())
				return _IPHONE_RETINA_SIXSEVEN_HEIGHT;
			else if (isIphoneSixSevenPlus())
				return _IPHONE_RETINA_SIXSEVEN_PLUS_HEIGHT;
			else
				throw Error(" Unknown / New iOS device - Please request 'Platform.as' to be updated.");
		}
		
		static public function get iPAD_WIDTH():uint {
			if (!isIOS())
				throw Error(" Not an iOS device!");
			
			if (isIpadLegacy())
				return _IPAD_LEGACY_WIDTH;
			else if (isIpadRetinaLegacy())
				return _IPAD_RETINA_LEGACY_WIDTH;
			else if (isIpadRetinaPro())
				return _IPAD_RETINA_PRO_WIDTH;
			else
				throw Error(" Unknown / New iOS device - Please request 'Platform.as' to be updated.");
		}
		
		static public function get iPAD_HEIGHT():uint {
			if (!isIOS())
				throw Error(" Not an iOS device!");
			
			if (isIpadLegacy())
				return _IPAD_LEGACY_HEIGHT;
			else if (isIpadRetinaLegacy())
				return _IPAD_RETINA_LEGACY_HEIGHT;
			else if (isIpadRetinaPro())
				return _IPAD_RETINA_PRO_HEIGHT;
			else
				throw Error(" Unknown / New iOS device - Please request 'Platform.as' to be updated.");
		}
		
		// PRIVATE FINISHED SECTION - Used internally only.
		//     Results are stored in static vars.
		static protected function stageValidate():void {
			var _wrapper:* = CitrusEngine.getInstance();
			
			try {
				_FLASH_STAGE = _wrapper.stage;
			} catch (err:Error) {
				throw Error(" Wrapper is 'null'.      -->" + err.message);
			}
		}
		
		static protected function queryDesktop():uint {
			_PLATFORM_SPECIFICS_IS_WIN = uint(_PLAYER_VERSION == "WIN");
			_PLATFORM_SPECIFICS_IS_MAC = uint(_PLAYER_VERSION == "MAC");
			_PLATFORM_SPECIFICS_IS_LNX = uint(_PLAYER_VERSION == "LNX");
			return (_PLATFORM_SPECIFICS_IS_WIN || _PLATFORM_SPECIFICS_IS_MAC || _PLATFORM_SPECIFICS_IS_LNX);
		}
		
		static private function queryMobile():uint {
			_PLATFORM_SPECIFICS_IS_AND = uint(_PLAYER_VERSION == "AND");
			_PLATFORM_SPECIFICS_IS_IOS = uint(_PLAYER_VERSION == "IOS");
			_PLATFORM_SPECIFICS_IS_QNX = uint(_PLAYER_VERSION == "QNX");
			return (_PLATFORM_SPECIFICS_IS_AND || _PLATFORM_SPECIFICS_IS_IOS || _PLATFORM_SPECIFICS_IS_QNX);
		}
		
		static protected function queryWindows():uint {
			_PLATFORM_SPECIFICS_IS_WIN = uint(_PLAYER_VERSION == "WIN");
			return _PLATFORM_SPECIFICS_IS_WIN;
		}
		
		static protected function queryMac():uint {
			_PLATFORM_SPECIFICS_IS_MAC = uint(_PLAYER_VERSION == "MAC");
			return _PLATFORM_SPECIFICS_IS_MAC;
		}
		
		static protected function queryLinux():uint {
			_PLATFORM_SPECIFICS_IS_LNX = uint(_PLAYER_VERSION == "LNX");
			return _PLATFORM_SPECIFICS_IS_LNX;
		}
		
		static protected function queryIphoneLegacy():uint {
			if (queryIOS()) {
				stageValidate();
				if (isLandscape())
					return (uint(_FLASH_STAGE.stageWidth == _IPHONE_LEGACY_HEIGHT) || uint(_FLASH_STAGE.stageWidth == (_IPHONE_LEGACY_HEIGHT - _IOS_LEGACY_STATUSBAR_HEIGHT)));
				else
					return (uint(_FLASH_STAGE.stageWidth == _IPHONE_LEGACY_WIDTH) || uint(_FLASH_STAGE.stageWidth == (_IPHONE_LEGACY_WIDTH - _IOS_LEGACY_STATUSBAR_HEIGHT)));
			} else
				return 0;
		}
		
		static protected function queryIphoneFour():uint {
			if (queryIOS()) {
				stageValidate();
				if (isLandscape())
					return (uint((_FLASH_STAGE.stageWidth == _IPHONE_RETINA_FOUR_HEIGHT) && (_FLASH_STAGE.stageHeight == _IPHONE_RETINA_FOUR_WIDTH)) || uint((_FLASH_STAGE.stageWidth == (_IPHONE_RETINA_FOUR_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT) && (_FLASH_STAGE.stageHeight == (_IPHONE_RETINA_FOUR_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT)))));
				else
					return (uint((_FLASH_STAGE.stageWidth == _IPHONE_RETINA_FOUR_WIDTH) && (_FLASH_STAGE.stageHeight == _IPHONE_RETINA_FOUR_HEIGHT)) || uint((_FLASH_STAGE.stageWidth == (_IPHONE_RETINA_FOUR_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT) && (_FLASH_STAGE.stageHeight == (_IPHONE_RETINA_FOUR_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT)))));
			} else
				return 0;
		}
		
		static protected function queryIphoneFiveSE():uint {
			if (queryIOS()) {
				stageValidate();
				if (isLandscape())
					return (uint((_FLASH_STAGE.stageWidth == _IPHONE_RETINA_FIVESE_HEIGHT) && (_FLASH_STAGE.stageHeight == _IPHONE_RETINA_FIVESE_WIDTH)) || uint((_FLASH_STAGE.stageWidth == (_IPHONE_RETINA_FIVESE_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT) && (_FLASH_STAGE.stageHeight == (_IPHONE_RETINA_FIVESE_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT)))));
				else
					return (uint((_FLASH_STAGE.stageWidth == _IPHONE_RETINA_FIVESE_WIDTH) && (_FLASH_STAGE.stageHeight == _IPHONE_RETINA_FIVESE_HEIGHT)) || uint((_FLASH_STAGE.stageWidth == (_IPHONE_RETINA_FIVESE_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT) && (_FLASH_STAGE.stageHeight == (_IPHONE_RETINA_FIVESE_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT)))));
			} else
				return 0;
		}
		
		static protected function queryIphoneSixSeven():uint {
			if (queryIOS()) {
				stageValidate();
				if (isLandscape())
					return (uint(_FLASH_STAGE.stageWidth == _IPHONE_RETINA_SIXSEVEN_HEIGHT) || uint(_FLASH_STAGE.stageWidth == (_IPHONE_RETINA_SIXSEVEN_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT)));
				else
					return (uint(_FLASH_STAGE.stageWidth == _IPHONE_RETINA_SIXSEVEN_WIDTH) || uint(_FLASH_STAGE.stageWidth == (_IPHONE_RETINA_SIXSEVEN_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT)));
			} else
				return 0;
		}
		
		static protected function queryIphoneSixSevenPlus():uint {
			if (queryIOS()) {
				stageValidate();
				if (isLandscape())
					return (uint(_FLASH_STAGE.stageWidth == _IPHONE_RETINA_SIXSEVEN_PLUS_HEIGHT) || uint(_FLASH_STAGE.stageWidth == (_IPHONE_RETINA_SIXSEVEN_PLUS_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT)));
				else
					return (uint(_FLASH_STAGE.stageWidth == _IPHONE_RETINA_SIXSEVEN_PLUS_WIDTH) || uint(_FLASH_STAGE.stageWidth == (_IPHONE_RETINA_SIXSEVEN_PLUS_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT)));
			} else
				return 0;
		}
		
		// ip1/ip2/ipm1
		static protected function queryIpadLegacy():uint {
			if (queryIOS()) {
				if (isLandscape())
					return (uint(_FLASH_STAGE.stageWidth == _IPAD_LEGACY_HEIGHT) || uint(_FLASH_STAGE.stageWidth == (_IPAD_LEGACY_HEIGHT - _IOS_LEGACY_STATUSBAR_HEIGHT)));
				else
					return (uint(_FLASH_STAGE.stageWidth == _IPAD_LEGACY_WIDTH) || uint(_FLASH_STAGE.stageWidth == (_IPAD_LEGACY_WIDTH - _IOS_LEGACY_STATUSBAR_HEIGHT)));
			} else
				return 0;
		}
		
		// ip3/ip4/ipm2/ipm3/ipa1/ipa2
		static protected function queryIpadRetinaLegacy():uint {
			if (queryIOS()) {
				if (isLandscape())
					return (uint(_FLASH_STAGE.stageWidth == _IPAD_RETINA_LEGACY_HEIGHT) || uint(_FLASH_STAGE.stageWidth == (_IPAD_RETINA_LEGACY_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT)));
				else
					return (uint(_FLASH_STAGE.stageWidth == _IPAD_RETINA_LEGACY_WIDTH) || uint(_FLASH_STAGE.stageWidth == (_IPAD_RETINA_LEGACY_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT)));
			} else
				return 0;
		}
		
		static protected function queryIpadRetinaPro():uint {
			if (queryIOS()) {
				if (isLandscape())
					return (uint(_FLASH_STAGE.stageWidth == _IPAD_RETINA_PRO_HEIGHT) || uint(_FLASH_STAGE.stageWidth == (_IPAD_RETINA_PRO_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT)));
				else
					return (uint(_FLASH_STAGE.stageWidth == _IPAD_RETINA_PRO_WIDTH) || uint(_FLASH_STAGE.stageWidth == (_IPAD_RETINA_PRO_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT)));
			} else
				return 0;
		}
		
		// It is indeed possible to get a more specific browser ( Result may not be accurate, this method has room for improvement ).
		static protected function queryBrowser():uint {
			_PLATFORM_IS_BROWSER = (uint(_PLAYER_TYPE == "PlugIn") || uint(_PLAYER_TYPE == "ActiveX") || uint(_PLAYER_TYPE == "OpenFL"));
			return _PLATFORM_IS_BROWSER;
		}
		
		// It is indeed possible to cache all device specifications in one call ( ( apart from isLandscape and isFullscreen ), this method has room for improvement ).
		static protected function queryIOS():uint {
			_PLATFORM_SPECIFICS_IS_IOS = uint(_PLAYER_VERSION == "IOS");
			if (1 == _PLATFORM_SPECIFICS_IS_IOS) {
				// ...query everything for iOS
			}
			return _PLATFORM_SPECIFICS_IS_IOS;
		}
		
		// It is indeed possible to cache all device specifications in one call ( ( apart from isLandscape and isFullscreen ), this method has room for improvement ).
		static protected function queryAndroid():uint {
			_PLATFORM_SPECIFICS_IS_AND = uint(_PLAYER_VERSION == "AND");
			if (1 == _PLATFORM_SPECIFICS_IS_AND) {
				// ...query everything for Android
			}
			return _PLATFORM_SPECIFICS_IS_AND;
		}
		
		// It is indeed possible to cache all device specifications in one call ( ( apart from isLandscape and isFullscreen ), this method has room for improvement ).
		static protected function queryBlackberry():uint {
			_PLATFORM_SPECIFICS_IS_QNX = uint(_PLAYER_VERSION == "QNX");
			if (1 == _PLATFORM_SPECIFICS_IS_QNX) {
				// ...query everything for Blackberry
			}
			return _PLATFORM_SPECIFICS_IS_QNX;
		}
	
		///.. eof
}	}
