package citrus.utils {
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.system.Capabilities;
	import citrus.core.CitrusEngine;
    
	/**
	* Author(s): @SnkyGames ( Jas 'Snky' M. )
	* Copyright (c) 2015-2016 SnkyGames
	* License adopted: The MIT License (MIT)
	*
	* The views presented and the conclusions made in this software are those of the author(s);
	* They do not necessarily represent official concepts nor proper use cases, whether expressed or implied, by aforementioned author(s).
	*
	* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	* This class provides platform information.
	* Last updated: 03/July/2016
	* 
	*     TODO: Status Bar - On/Off? Affects Platform.as calculations?
	*     TODO: Display Zoom - On/Off? Affects Platform.as calculations?
	*     TODO: iPhone 6s
	*     TODO: iPhone 6s Plus
	*     TODO: iPhone SE
	* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	*
	* 
	* 
	* Notes:
	*     +Methods 'isLandscape()' and 'isFullscreen()' can return three different values(0,1 and 2). 
	*         Value '2' can be used to identify if using 'FULL_SCREEN_INTERACTIVE' or if the device's width is equal to the device's height.
	*
	*     +Do not use Capabilities.os or Capabilities.manufacturer to determine a capability based on the operating system.
	*     +Different launch images can be displayed on an iPad and iPhone 6 plus, based on their orientation, at the time of application launch.
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
	* 	       http://forum.starling-framework.org/topic/iphone-6-question
	*         http://qz.com/109657/here-are-the-11868-devices-and-counting-that-every-android-app-has-to-work-on/
	*         http://carl-topham.com/theblog/post/cross-platform-flash-as3-cd-rom-part-1/
	*         http://ivomynttinen.com/blog/the-ios-7-design-cheat-sheet/
	*         http://jacksondunstan.com/articles/2596#more-2596
	*         http://forum.starling-framework.org/topic/detect-device-modelperformance/page/2
	* 
	*     +Method 'stageValidate()' determines the wrapper this class supports, current copy customised to support: Citrus Engine ( Flash, AS3 ).
	*/
    
	public class Platform {
        
		// ( iOS Status Bar ) Height
		static private const _IOS_LEGACY_STATUSBAR_HEIGHT:uint = 20;
		static private const _IOS_RETINA_STATUSBAR_HEIGHT:uint = 40;
		// ( 2G , 3G , 3GS ) Portrait: Default~iphone.png
		static private const _IPHONE_LEGACY_WIDTH:uint = 320;
		static private const _IPHONE_LEGACY_HEIGHT:uint = 480;
		// ( 4 / 4S ) Portrait: Default@2x~iphone.png
		static private const _IPHONE_RETINA_FOUR_WIDTH:uint = 640;
		static private const _IPHONE_RETINA_FOUR_HEIGHT:uint = 960;
		// ( 5 , 5C , 5S , iPOD Touch 5g ) Portrait: Default-568h@2x~iphone.png
		static private const _IPHONE_RETINA_FIVE_WIDTH:uint = 640;
		static private const _IPHONE_RETINA_FIVE_HEIGHT:uint = 1136;
		// ( 6 , 6 zoom ) Portrait: Default-375w-667h@2x~iphone.png
		static private const _IPHONE_RETINA_SIX_WIDTH:uint = 750;
		static private const _IPHONE_RETINA_SIX_HEIGHT:uint = 1334;
		// ( 6+ , 6+ zoom ) Portrait: Default-414w-736h@3x~iphone.png | Landscape: Default-Landscape-414w-736h@3x~iphone.png
		static private const _IPHONE_RETINA_SIX_PLUS_WIDTH:uint = 1242;
		static private const _IPHONE_RETINA_SIX_PLUS_HEIGHT:uint = 2208;
		// ( 1 / 2 / mini ) Portrait: Default-Portrait~ipad.png | Upside down Portrait: Default-PortraitUpsideDown~ipad.png | Left Landscape: Default-Landscape~ipad.png | Right Landscape: Default-LandscapeRight~ipad.png
		static private const _IPAD_LEGACY_WIDTH:uint = 768;
		static private const _IPAD_LEGACY_HEIGHT:uint = 1024;
		// ( 3 / 4 / mini 2 / mini 3 / air / air 2 ) Portrait: Default-Portrait@2x~ipad.png | Upside down Portrait: Default-PortraitUpsideDown@2x~ipad.png | Left Landscape: Default-LandscapeLeft@2x~ipad.png | Right Landscape: Default-LandscapeRight@2x~ipad.png
		static private const _IPAD_RETINA_LEGACY_WIDTH:uint = 1536;
		static private const _IPAD_RETINA_LEGACY_HEIGHT:uint = 2048;
		// ( N/A ) Portrait: N/A | Landscape: N/A
		static private const _IPAD_RETINA_PRO_WIDTH:uint = 2048;
		static private const _IPAD_RETINA_PRO_HEIGHT:uint = 2732;
		static private var _PLATFORM_IS_BROWSER:uint = 2;
		static private var _PLATFORM_IS_DESKTOP:uint = 2;
		static private var _PLATFORM_IS_IOS:uint = 2;
		static private var _PLATFORM_IS_AND:uint = 2;
		static private var _PLATFORM_SPECIFICS_IS_IPAD:uint = 2;
		static private var _PLATFORM_SPECIFICS_IS_IPAD_LEGACY:uint = 2;
		static private var _PLATFORM_SPECIFICS_IS_IPAD_RETINA_LEGACY:uint = 2;
		static private var _PLATFORM_SPECIFICS_IS_IPAD_RETINA_PRO:uint = 2;
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
		static private var _PLATFORM_SPECIFICS_IS_LANDSCAPE:uint;
		static private var _PLATFORM_SPECIFICS_IS_FULLSCREEN:uint;
		static private const _PLAYER_VERSION:String = Capabilities.version.substr(0, 3);
		static private const _PLAYER_TYPE:String = Capabilities.playerType;
		static private var _FLASH_STAGE:Stage;
		        
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
	        
		static public function isIOS():uint {
			return _PLATFORM_IS_IOS != 2 ? _PLATFORM_IS_IOS : queryIOS();
		}
	        
		static public function isAndroid():uint {
			return _PLATFORM_IS_AND != 2 ? _PLATFORM_IS_AND : queryAndroid();
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
			else if (isIphoneFive())
				return _IPHONE_RETINA_FIVE_WIDTH;
			else if (isIphoneSix())
				return _IPHONE_RETINA_SIX_WIDTH;
			else if (isIphoneSixPlus())
				return _IPHONE_RETINA_SIX_PLUS_WIDTH;
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
			else if (isIphoneFive())
				return _IPHONE_RETINA_FIVE_HEIGHT;
			else if (isIphoneSix())
				return _IPHONE_RETINA_SIX_HEIGHT;
			else if (isIphoneSixPlus())
				return _IPHONE_RETINA_SIX_PLUS_HEIGHT;
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
	        
	        static private function stageValidate():void {
			var _wrapper:* = CitrusEngine.getInstance();
	            
			try {
				_FLASH_STAGE = _wrapper.stage;
			} catch (err:Error) {
				throw Error(" Wrapper is 'null'.      -->" + err.message);
			}
	        }
	        
	        static private function queryDesktop():uint {
			_PLATFORM_SPECIFICS_IS_WIN = uint(_PLAYER_VERSION == "WIN");
			_PLATFORM_SPECIFICS_IS_MAC = uint(_PLAYER_VERSION == "MAC");
			_PLATFORM_SPECIFICS_IS_LNX = uint(_PLAYER_VERSION == "LNX");
			return (_PLATFORM_SPECIFICS_IS_WIN || _PLATFORM_SPECIFICS_IS_MAC || _PLATFORM_SPECIFICS_IS_LNX);
	        }
	        
	        static private function queryWindows():uint {
			_PLATFORM_SPECIFICS_IS_WIN = uint(_PLAYER_VERSION == "WIN");
			return _PLATFORM_SPECIFICS_IS_WIN;
	        }
	        
	        static private function queryMac():uint {
			_PLATFORM_SPECIFICS_IS_MAC = uint(_PLAYER_VERSION == "MAC");
			return _PLATFORM_SPECIFICS_IS_MAC;
	        }
	        
	        static private function queryLinux():uint {
			_PLATFORM_SPECIFICS_IS_LNX = uint(_PLAYER_VERSION == "LNX");
			return _PLATFORM_SPECIFICS_IS_LNX;
	        }
	        
	        static private function queryIphoneLegacy():uint {
			if (queryIOS()) {
				stageValidate();
			if (isLandscape())
				return (uint(_FLASH_STAGE.stageWidth == _IPHONE_LEGACY_HEIGHT) || uint(_FLASH_STAGE.stageWidth == (_IPHONE_LEGACY_HEIGHT - _IOS_LEGACY_STATUSBAR_HEIGHT)));
			else
				return (uint(_FLASH_STAGE.stageWidth == _IPHONE_LEGACY_WIDTH) || uint(_FLASH_STAGE.stageWidth == (_IPHONE_LEGACY_WIDTH - _IOS_LEGACY_STATUSBAR_HEIGHT)));
			} else
				return 0;
	        }
	        
	        static private function queryIphoneFour():uint {
			if (queryIOS()) {
				stageValidate();
			if (isLandscape())
				return (uint((_FLASH_STAGE.stageWidth == _IPHONE_RETINA_FOUR_HEIGHT) && (_FLASH_STAGE.stageHeight == _IPHONE_RETINA_FOUR_WIDTH)) || uint((_FLASH_STAGE.stageWidth == (_IPHONE_RETINA_FOUR_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT) && (_FLASH_STAGE.stageHeight == (_IPHONE_RETINA_FOUR_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT)))));
			else
				return (uint((_FLASH_STAGE.stageWidth == _IPHONE_RETINA_FOUR_WIDTH) && (_FLASH_STAGE.stageHeight == _IPHONE_RETINA_FOUR_HEIGHT)) || uint((_FLASH_STAGE.stageWidth == (_IPHONE_RETINA_FOUR_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT) && (_FLASH_STAGE.stageHeight == (_IPHONE_RETINA_FOUR_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT)))));
			} else
				return 0;
	        }
	        
	        static private function queryIphoneFive():uint {
			if (queryIOS()) {
				stageValidate();
			if (isLandscape())
				return (uint((_FLASH_STAGE.stageWidth == _IPHONE_RETINA_FIVE_HEIGHT) && (_FLASH_STAGE.stageHeight == _IPHONE_RETINA_FIVE_WIDTH)) || uint((_FLASH_STAGE.stageWidth == (_IPHONE_RETINA_FIVE_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT) && (_FLASH_STAGE.stageHeight == (_IPHONE_RETINA_FIVE_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT)))));
			else
				return (uint((_FLASH_STAGE.stageWidth == _IPHONE_RETINA_FIVE_WIDTH) && (_FLASH_STAGE.stageHeight == _IPHONE_RETINA_FIVE_HEIGHT)) || uint((_FLASH_STAGE.stageWidth == (_IPHONE_RETINA_FIVE_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT) && (_FLASH_STAGE.stageHeight == (_IPHONE_RETINA_FIVE_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT)))));
			} else
			return 0;
	        }
	        
	        static private function queryIphoneSix():uint {
			if (queryIOS()) {
				stageValidate();
			if (isLandscape())
				return (uint(_FLASH_STAGE.stageWidth == _IPHONE_RETINA_SIX_HEIGHT) || uint(_FLASH_STAGE.stageWidth == (_IPHONE_RETINA_SIX_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT)));
			else
				return (uint(_FLASH_STAGE.stageWidth == _IPHONE_RETINA_SIX_WIDTH) || uint(_FLASH_STAGE.stageWidth == (_IPHONE_RETINA_SIX_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT)));
			} else
				return 0;
	        }
	        
	        static private function queryIphoneSixPlus():uint {
			if (queryIOS()) {
				stageValidate();
			if (isLandscape())
				return (uint(_FLASH_STAGE.stageWidth == _IPHONE_RETINA_SIX_PLUS_HEIGHT) || uint(_FLASH_STAGE.stageWidth == (_IPHONE_RETINA_SIX_PLUS_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT)));
			else
				return (uint(_FLASH_STAGE.stageWidth == _IPHONE_RETINA_SIX_PLUS_WIDTH) || uint(_FLASH_STAGE.stageWidth == (_IPHONE_RETINA_SIX_PLUS_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT)));
			} else
				return 0;
	        }
	        
	        // ip1/ip2/ipm1
	        static private function queryIpadLegacy():uint {
			if (queryIOS()) {
				if (isLandscape())
					return (uint(_FLASH_STAGE.stageWidth == _IPAD_LEGACY_HEIGHT) || uint(_FLASH_STAGE.stageWidth == (_IPAD_LEGACY_HEIGHT - _IOS_LEGACY_STATUSBAR_HEIGHT)));
				else
					return (uint(_FLASH_STAGE.stageWidth == _IPAD_LEGACY_WIDTH) || uint(_FLASH_STAGE.stageWidth == (_IPAD_LEGACY_WIDTH - _IOS_LEGACY_STATUSBAR_HEIGHT)));
			} else
				return 0;
	        }
	        
	        // ip3/ip4/ipm2/ipm3/ipa1/ipa2
	        static private function queryIpadRetinaLegacy():uint {
			if (queryIOS()) {
				if (isLandscape())
					return (uint(_FLASH_STAGE.stageWidth == _IPAD_RETINA_LEGACY_HEIGHT) || uint(_FLASH_STAGE.stageWidth == (_IPAD_RETINA_LEGACY_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT)));
				else
					return (uint(_FLASH_STAGE.stageWidth == _IPAD_RETINA_LEGACY_WIDTH) || uint(_FLASH_STAGE.stageWidth == (_IPAD_RETINA_LEGACY_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT)));
			} else
				return 0;
	        }
	        
	        static private function queryIpadRetinaPro():uint {
			if (queryIOS()) {
				if (isLandscape())
					return (uint(_FLASH_STAGE.stageWidth == _IPAD_RETINA_PRO_HEIGHT) || uint(_FLASH_STAGE.stageWidth == (_IPAD_RETINA_PRO_HEIGHT - _IOS_RETINA_STATUSBAR_HEIGHT)));
				else
					return (uint(_FLASH_STAGE.stageWidth == _IPAD_RETINA_PRO_WIDTH) || uint(_FLASH_STAGE.stageWidth == (_IPAD_RETINA_PRO_WIDTH - _IOS_RETINA_STATUSBAR_HEIGHT)));
			} else
				return 0;
	        }
	        
	        // It is indeed possible to get a more specific browser ( Result may not be accurate, this method has room for improvement ).
	        static private function queryBrowser():uint {
			_PLATFORM_IS_BROWSER = (uint(_PLAYER_TYPE == "PlugIn") || uint(_PLAYER_TYPE == "ActiveX"));
			return _PLATFORM_IS_BROWSER;
	        }
	        
	        // It is indeed possible to cache all device specifications in one call ( ( apart from isLandscape and isFullscreen ), this method has room for improvement ).
	        static private function queryIOS():uint {
			_PLATFORM_IS_IOS = uint(_PLAYER_VERSION == "IOS");
			if (1 == _PLATFORM_IS_IOS) {
				// ...query everything for iOS
			}
			return _PLATFORM_IS_IOS;
	        }
			
	        // It is indeed possible to cache all device specifications in one call ( ( apart from isLandscape and isFullscreen ), this method has room for improvement ).
	        static private function queryAndroid():uint {
			_PLATFORM_IS_AND = uint(_PLAYER_VERSION == "AND");
			if (1 == _PLATFORM_IS_AND) {
				// ...query everything for Android
			}
			return _PLATFORM_IS_AND;
		}
    
		///.. eof
	}
}
