package starling.extensions.textureAtlas
{

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
    import flash.utils.getQualifiedClassName;

    import starling.text.BitmapFont;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.text.TextField;
	
	/**
	 * DynamicAtlas.as
	 * https://github.com/emibap/Dynamic-Texture-Atlas-Generator
	 * @author Emibap (Emiliano Angelini) - http://www.emibap.com
		 * Contribution by Thomas Haselwanter - https://github.com/thomashaselwanter
	 * Most of this comes thanks to the inspiration (and code) of Thibault Imbert (http://www.bytearray.org) and Nicolas Gans (http://www.flashxpress.net/)
	 * 
	 * Dynamic Texture Atlas and Bitmap Font Generator (Starling framework Extension)
	 * ========
	 *
	 * This tool will convert any MovieClip containing Other MovieClips, Sprites or Graphics into a starling Texture Atlas, all in runtime.
	 * It can also register bitmap Fonts from system or embedded regular fonts.
	 * By using it, you won't have to statically create your spritesheets or fonts. For instance, you can just take a regular MovieClip containing all the display objects you wish to put into your Altas, and convert everything from vectors to bitmap textures.
	 * Or you can select which font (specifying characters) you'd like to register as a Bitmap Font, using a string or passing a Regular TextField as a parameter.
	 * This extension could save you a lot of time specially if you'll be coding mobile apps with the [starling framework](http://www.starling-framework.org/).
	 *
	 * # version 1.0 #
	 * - Added the checkBounds parameter to scan the clip prior the rasterization in order to get the bounds of the entire MovieClip (prevent scaling in some cases). Thank you Aymeric Lamboley.
	 * - Added the fontCustomID parameter to the Bitmap font creation. Thank you Regan.
	 *
	 * ### Features ###
	 *
	 * * Dynamic creation of a Texture Atlas from a MovieClip (flash.display.MovieClip) container that could act as a sprite sheet, or from a Vector of Classes
	 * * Filters made to the objects are captured
	 * * Color transforms (tint, alpha) are optionally captured
	 * * Scales the objects (and also the filters) to a specified value
	 * * Automatically detects the objects bounds so you don't necessarily have to set the registration points to TOP LEFT
	 * * Registers Bitmap Fonts based on system or embedded fonts from strings or from good old Flash TextFields
	 * 
	 * ### TODO List ###
	 *
	 * * Further code optimization
	 * * A better implementation of the Bitmap Font creation process
	 * * Documentation (?)
	 *
	 * ### Whish List ###
	 * * Optional division of the process into small intervals (for smooth performance of the app)
	 * 
	 * ### Usage ###
	 * 
	 * 	You can use the following static methods (examples at the gitHub Repo):
	 *	
	 * 	[Texture Atlas creation]
	 * 	- DynamicAtlas.fromMovieClipContainer(swf:flash.display.MovieClip, scaleFactor:Number = 1, margin:uint=0, preserveColor:Boolean = true):starling.textures.TextureAtlas
	 * 	- DynamicAtlas.fromClassVector(assets:Vector.<Class>, scaleFactor:Number = 1, margin:uint=0, preserveColor:Boolean = true):starling.textures.TextureAtlas
	 *
	 * [Bitmap Font registration]
	 * - DynamicAtlas.bitmapFontFromString(chars:String, fontFamily:String, fontSize:Number = 12, bold:Boolean = false, italic:Boolean = false, charMarginX:int=0):void
	 * - DynamicAtlas.bitmapFontFromTextField(tf:flash.text.TextField, charMarginX:int=0):void
	 *
	 * 	Enclose inside a try/catch for error handling:
	 * 		try {
	 * 				var atlas:TextureAtlas = DynamicAtlas.fromMovieClipContainer(mc);
	 * 			} catch (e:Error) {
	 * 				trace("There was an error in the creation of the texture Atlas. Please check if the dimensions of your clip exceeded the maximun allowed texture size. -", e.message);
	 * 			}
	 *
	 *  History:
	 *  -------
	 * # version 0.9.5 #
	 * - Added the fromClassVector static function. Thank you Thomas Haselwanter
	 * 
	 * # version 0.9 #
	 * - Added Bitmap Font creation support
	 * - Scaling also applies to filters.
	 * - Added Margin and PreserveColor Properties
	 * 
	 * # version 0.8 #
	 * - Added the scaleFactor constructor parameter. Now you can define a custom scale to the final result.
	 * - Scaling also applies to filters.
	 * - Added Margin and PreserveColor Properties
	 * 
	 * # version 0.7 #
	 * First Public version
	 **/
	
	public class DynamicAtlas
	{
		static protected const DEFAULT_CANVAS_WIDTH:Number = 640;
		
		static protected var _items:Array;
		static protected var _canvas:Sprite;
		
		static protected var _currentLab:String;
		
		static protected var _x:Number;
		static protected var _y:Number;
		
		static protected var _bData:BitmapData;
		static protected var _mat:Matrix;
		static protected var _margin:Number;
		static protected var _preserveColor:Boolean;
		
		// Will not be used - Only using one static method
		public function DynamicAtlas()
		{
		
		}
		
		// Private methods
		
		static protected function appendIntToString(num:int, numOfPlaces:int):String
		{
			var numString:String = num.toString();
			var outString:String = "";
			for (var i:int = 0; i < numOfPlaces - numString.length; i++)
			{
				outString += "0";
			}
			return outString + numString;
		}
		
		static protected function layoutChildren():void
		{
			var xPos:Number = 0;
			var yPos:Number = 0;
			var maxY:Number = 0;
			var len:int = _items.length;
			
			var itm:TextureItem;
			
			for (var i:uint = 0; i < len; i++)
			{
				itm = _items[i];
				if ((xPos + itm.width) > DEFAULT_CANVAS_WIDTH)
				{
					xPos = 0;
					yPos += maxY;
					maxY = 0;
				}
				if (itm.height + 1 > maxY)
				{
					maxY = itm.height + 1;
				}
				itm.x = xPos;
				itm.y = yPos;
				xPos += itm.width + 1;
			}
		}
	
		/**
		* isEmbedded
		* 
		* @param	fontFamily:Boolean - The name of the Font
		* @return Boolean - True if the font is an embedded one
		*/
		static protected function isEmbedded(fontFamily:String):Boolean 
		{
		   var embeddedFonts:Vector.<Font> = Vector.<Font>(Font.enumerateFonts());
		   
		   for (var i:int = embeddedFonts.length - 1; i > -1 && embeddedFonts[i].fontName != fontFamily; i--) { }
		   
		   return (i > -1);
		   
		}
		
		static protected function getRealBounds(clip:DisplayObject):Rectangle {
			var bounds:Rectangle = clip.getBounds(clip.parent);
			bounds.x = Math.floor(bounds.x);
			bounds.y = Math.floor(bounds.y);
			bounds.height = Math.ceil(bounds.height);
			bounds.width = Math.ceil(bounds.width);
			
			var realBounds:Rectangle = new Rectangle(0, 0, bounds.width + _margin * 2, bounds.height + _margin * 2);
			
			// Checking filters in case we need to expand the outer bounds
			if (clip.filters.length > 0)
			{
				// filters
				var j:int = 0;
				//var clipFilters:Array = clipChild.filters.concat();
				var clipFilters:Array = clip.filters;
				var clipFiltersLength:int = clipFilters.length;
				var tmpBData:BitmapData;
				var filterRect:Rectangle;
				
				tmpBData = new BitmapData(realBounds.width, realBounds.height, false);
				filterRect = tmpBData.generateFilterRect(tmpBData.rect, clipFilters[j]);
				tmpBData.dispose();
				
				while (++j < clipFiltersLength)
				{
					tmpBData = new BitmapData(filterRect.width, filterRect.height, true, 0);
					filterRect = tmpBData.generateFilterRect(tmpBData.rect, clipFilters[j]);
					realBounds = realBounds.union(filterRect);
					tmpBData.dispose();
				}
			}
			
			realBounds.offset(bounds.x, bounds.y);
			realBounds.width = Math.max(realBounds.width, 1);
			realBounds.height = Math.max(realBounds.height, 1);
			
			tmpBData = null;
			return realBounds;
		}
		
		/**
		 * drawItem - This will actually rasterize the display object passed as a parameter
		 * @param	clip
		 * @param	name
		 * @param	baseName
		 * @param	clipColorTransform
		 * @param	frameBounds
		 * @return TextureItem
		 */
		static protected function drawItem(clip:DisplayObject, name:String = "", baseName:String = "", clipColorTransform:ColorTransform = null, frameBounds:Rectangle=null):TextureItem
		{
			var realBounds:Rectangle = getRealBounds(clip);
			
			_bData = new BitmapData(realBounds.width, realBounds.height, true, 0);
			_mat = clip.transform.matrix;
			_mat.translate(-realBounds.x + _margin, -realBounds.y + _margin);
			
			_bData.draw(clip, _mat, _preserveColor ? clipColorTransform : null);
			
			var label:String = "";
			if (clip is MovieClip) {
				if (clip["currentLabel"] != _currentLab && clip["currentLabel"] != null)
				{
					_currentLab = clip["currentLabel"];
					label = _currentLab;
				}
			}
			
			if (frameBounds) {
				realBounds.x = frameBounds.x - realBounds.x;
				realBounds.y = frameBounds.y - realBounds.y;
				realBounds.width = frameBounds.width;
				realBounds.height = frameBounds.height;
			}
			
			var item:TextureItem = new TextureItem(_bData, name, label, realBounds.x, realBounds.y, realBounds.width, realBounds.height);
			
			_items.push(item);
			_canvas.addChild(item);
			
			
			_bData = null;
			
			return item;
		}
		
		// Public methods

        /**
         * This method takes a vector of MovieClip class and converts it into a Texture Atlas.
		 *
         * @param	assets:Vector.<Class> - The MovieClip classes you wish to convert into a TextureAtlas. Must contain classes whose instances are of type MovieClip that will be rasterized and become the subtextures of your Atlas.
         * @param	scaleFactor:Number - The scaling factor to apply to every object. Default value is 1 (no scaling).
         * @param	margin:uint - The amount of pixels that should be used as the resulting image margin (for each side of the image). Default value is 0 (no margin).
         * @param	preserveColor:Boolean - A Flag which indicates if the color transforms should be captured or not. Default value is true (capture color transform).
		 * @param 	checkBounds:Boolean - A Flag used to scan the clip prior the rasterization in order to get the bounds of the entire MovieClip. By default is false because it adds overhead to the process.
         * @return  TextureAtlas - The dynamically generated Texture Atlas.
         */
        static public function fromClassVector(assets:Vector.<Class>, scaleFactor:Number = 1, margin:uint=0, preserveColor:Boolean = true, checkBounds:Boolean=false):TextureAtlas
        {
            var container:MovieClip = new MovieClip();
            for each (var assetClass:Class in assets) {
                var assetInstance:MovieClip = new assetClass();
                assetInstance.name = getQualifiedClassName(assetClass);
                container.addChild(assetInstance);
            }
            return fromMovieClipContainer(container, scaleFactor, margin, preserveColor, checkBounds);
        }

        /** Retrieves all textures for a class. Returns <code>null</code> if it is not found.
         * This method can be used if TextureAtlass doesn't support classes.
         */
        static public function getTexturesByClass(textureAtlas:TextureAtlas, assetClass:Class):Vector.<Texture> {
            return textureAtlas.getTextures(getQualifiedClassName(assetClass));
        }
		
		/**
		 * This method will take a MovieClip sprite sheet (containing other display objects) and convert it into a Texture Atlas.
		 * 
		 * @param	swf:MovieClip - The MovieClip sprite sheet you wish to convert into a TextureAtlas. I must contain named instances of every display object that will be rasterized and become the subtextures of your Atlas.
		 * @param	scaleFactor:Number - The scaling factor to apply to every object. Default value is 1 (no scaling).
		 * @param	margin:uint - The amount of pixels that should be used as the resulting image margin (for each side of the image). Default value is 0 (no margin).
		 * @param	preserveColor:Boolean - A Flag which indicates if the color transforms should be captured or not. Default value is true (capture color transform).
		 * @param 	checkBounds:Boolean - A Flag used to scan the clip prior the rasterization in order to get the bounds of the entire MovieClip. By default is false because it adds overhead to the process.
		 * @return  TextureAtlas - The dynamically generated Texture Atlas.
		 */
		static public function fromMovieClipContainer(swf:MovieClip, scaleFactor:Number = 1, margin:uint=0, preserveColor:Boolean = true, checkBounds:Boolean=false):TextureAtlas
		{
			var parseFrame:Boolean = false;
			var selected:MovieClip;
			var selectedTotalFrames:int;
			var selectedColorTransform:ColorTransform;
			var frameBounds:Rectangle = new Rectangle(0, 0, 0, 0);
			
			var children:uint = swf.numChildren;
			
			var canvasData:BitmapData;
			
			var texture:Texture;
			var xml:XML;
			var subText:XML;
			var atlas:TextureAtlas;
			
			var itemsLen:int;
			var itm:TextureItem;
			
			var m:uint;
			
			_margin = margin;
			_preserveColor = preserveColor;
			
			_items = [];
			
			if (!_canvas)
				_canvas = new Sprite();
			
			swf.gotoAndStop(1);
			
			for (var i:uint = 0; i < children; i++)
			{
				selected = MovieClip(swf.getChildAt(i));
				selectedTotalFrames = selected.totalFrames;
				selectedColorTransform = selected.transform.colorTransform;
				_x = selected.x;
				_y = selected.y;
				
				// Scaling if needed (including filters)
				if (scaleFactor != 1)
				{
					
					selected.scaleX *= scaleFactor;
					selected.scaleY *= scaleFactor;
					
					if (selected.filters.length > 0)
					{
						var filters:Array = selected.filters;
						var filtersLen:int = selected.filters.length;
						var filter:Object;
						for (var j:uint = 0; j < filtersLen; j++)
						{
							filter = filters[j];
							
							if (filter.hasOwnProperty("blurX"))
							{
								filter.blurX *= scaleFactor;
								filter.blurY *= scaleFactor;
							}
							if (filter.hasOwnProperty("distance"))
							{
								filter.distance *= scaleFactor;
							}
						}
						selected.filters = filters;
					}
				}
				
				
				
				// Gets the frame bounds by performing a frame-by-frame check
				if (selectedTotalFrames > 1 && checkBounds) {
					selected.gotoAndStop(0);
					frameBounds = getRealBounds(selected);
					m = 1;
					while (++m <= selectedTotalFrames)
					{
						selected.gotoAndStop(m);
						frameBounds = frameBounds.union(getRealBounds(selected));
					}
				}
				m = 0;
				// Draw every frame
				
				while (++m <= selectedTotalFrames)
				{
					selected.gotoAndStop(m);
					drawItem(selected, selected.name + "_" + appendIntToString(m - 1, 5), selected.name, selectedColorTransform, frameBounds);
				}
			}
			
			_currentLab = "";
			
			layoutChildren();
			
			canvasData = new BitmapData(_canvas.width, _canvas.height, true, 0x000000);
			canvasData.draw(_canvas);
			
			xml = new XML(<TextureAtlas></TextureAtlas>);
			xml.@imagePath = "atlas.png";
			
			itemsLen = _items.length;
			
			for (var k:uint = 0; k < itemsLen; k++)
			{
				itm = _items[k];
				
				itm.graphic.dispose();
				
				// xml
				subText = new XML(<SubTexture />); 
				subText.@name = itm.textureName;
				subText.@x = itm.x;
				subText.@y = itm.y;
				subText.@width = itm.width;
				subText.@height = itm.height;
				subText.@frameX = itm.frameX;
				subText.@frameY = itm.frameY;
				subText.@frameWidth = itm.frameWidth;
				subText.@frameHeight = itm.frameHeight;
				
				if (itm.frameName != "")
					subText.@frameLabel = itm.frameName;
				xml.appendChild(subText);
			}
			texture = Texture.fromBitmapData(canvasData);
			atlas = new TextureAtlas(texture, xml);
			
			_items.length = 0;
			_canvas.removeChildren();
			
			_items = null;
			xml = null;
			_canvas = null;
			_currentLab = null;
			//_x = _y = _margin = null;
			
			return atlas;
		}
		
		/**
		 * This method will register a Bitmap Font based on each char that belongs to a String.
		 * 
		 * @param	chars:String - The collection of chars which will become the Bitmap Font
		 * @param	fontFamily:String - The name of the Font that will be converted to a Bitmap Font
		 * @param	fontSize:Number - The size in pixels of the font.
		 * @param	bold:Boolean - A flag indicating if the font will be rasterized as bold.
		 * @param	italic:Boolean - A flag indicating if the font will be rasterized as italic.
		 * @param	charMarginX:int - The number of pixels that each character should have as horizontal margin (negative values are allowed). Default value is 0.
		 * @param	fontCustomID:String - A custom font family name indicated by the user. Helpful when using differnt effects for the same font. [Optional]
		 */
		static public function bitmapFontFromString(chars:String, fontFamily:String, fontSize:Number = 12, bold:Boolean = false, italic:Boolean = false, charMarginX:int=0, fontCustomID:String=""):void {
			var format:TextFormat = new TextFormat(fontFamily, fontSize, 0xFFFFFF, bold, italic);
			var tf:flash.text.TextField = new flash.text.TextField();
			
			tf.autoSize = TextFieldAutoSize.LEFT;
			
			
			// If the font is an embedded one (I couldn't get to work the Array.indexOf method) :(
			if (isEmbedded(fontFamily)) {
				tf.antiAliasType = AntiAliasType.ADVANCED;
				tf.embedFonts = true;
			}
			
			tf.defaultTextFormat = format;
			tf.text = chars;
			
			if (fontCustomID == "") fontCustomID = fontFamily;
			bitmapFontFromTextField(tf, charMarginX, fontCustomID);
		}
		
		/**
		 * This method will register a Bitmap Font based on each char that belongs to a regular flash TextField, rasterizing filters and color transforms as well.
		 * 
		 * @param	tf:flash.text.TextField - The textfield that will be used to rasterize every char of the text property
		 * @param	charMarginX:int - The number of pixels that each character should have as horizontal margin (negative values are allowed). Default value is 0.
		 * @param	fontCustomID:String - A custom font family name indicated by the user. Helpful when using differnt effects for the same font. [Optional]
		 */
		static public function bitmapFontFromTextField(tf:flash.text.TextField, charMarginX:int=0, fontCustomID:String=""):void {
			var charCol:Vector.<String> = Vector.<String>(tf.text.split(""));
			var format:TextFormat = tf.defaultTextFormat;
			var fontFamily:String = format.font;
			var fontSize:Object = format.size;
			
			var oldAutoSize:String = tf.autoSize;
			tf.autoSize = TextFieldAutoSize.LEFT;
			
			var canvasData:BitmapData;
			var texture:Texture;
			var xml:XML;
			
			var myChar:String;
			
			_margin = 0;
			_preserveColor = true;
			
			_items = [];
			var itm:TextureItem;
			var itemsLen:int;
			
			if (!_canvas) _canvas = new Sprite();
			
			// Add the blank space char if not present;
			if (charCol.indexOf(" ") == -1) charCol.push(" ");
				
			for (var i:int = charCol.length - 1; i > -1; i--) {
				myChar = tf.text = charCol[i];
				drawItem(tf, myChar.charCodeAt().toString());
			}
			
			_currentLab = "";
			
			layoutChildren();
			
			canvasData = new BitmapData(_canvas.width, _canvas.height, true, 0x000000);
			canvasData.draw(_canvas);
			
			itemsLen = _items.length;
			
			
			xml = new XML(<font></font>);
			var infoNode:XML = new XML(<info />);
			infoNode.@face = (fontCustomID == "")? fontFamily : fontCustomID;
			infoNode.@size = fontSize;
			xml.appendChild(infoNode);
			//var commonNode:XML = new XML(<common alphaChnl="1" redChnl="0" greenChnl="0" blueChnl="0" />);
			var commonNode:XML = new XML(<common />);
			commonNode.@lineHeight = fontSize;
			xml.appendChild(commonNode);
			xml.appendChild(new XML(<pages><page id="0" file="texture.png" /></pages>));
			var charsNode:XML = new XML(<chars> </chars>);
			charsNode.@count = itemsLen;
			var charNode:XML;
			
			for (var k:uint = 0; k < itemsLen; k++)
			{
				itm = _items[k];
				
				itm.graphic.dispose();
				
				// xml
				charNode = new XML(<char page="0" xoffset="0" yoffset="0"/>); 
				charNode.@id = itm.textureName;
				charNode.@x = itm.x;
				charNode.@y = itm.y;
				charNode.@width = itm.width;
				charNode.@height = itm.height;
				charNode.@xadvance = itm.width + 2*charMarginX;
				charsNode.appendChild(charNode);
			}
			
			xml.appendChild(charsNode);
			
			texture = Texture.fromBitmapData(canvasData);
			TextField.registerBitmapFont(new BitmapFont(texture, xml));
			
			_items.length = 0;
			_canvas.removeChildren();
			
			tf.autoSize = oldAutoSize;
			tf.text = charCol.join();
			
			_items = null;
			xml = null;
			_canvas = null;
			_currentLab = null;
		}
		
	}

}