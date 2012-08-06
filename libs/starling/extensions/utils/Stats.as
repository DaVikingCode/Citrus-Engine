/**
 * Stats.as, a Starling port of Mrdoob Stat.as
 * For original version, see :
 * https://github.com/mrdoob/Hi-ReS-Stats
 * 
 * And : 
 * http://www.starling-framework.org
 * 
 * Released under MIT license:
 * http://www.opensource.org/licenses/mit-license.php
 *
 * How to use:
 * 
 *	addChild( new Stats() );
 * 
 * 
 * Author : Nicolas Gans
 * To get the latest updates and make suggestions, 
 * see : http://forum.starling-framework.org/topic/starling-port-of-mrdoobs-stats-class
 * 
 * 
 * HISTORY :
 * 
 * 2011-09-26
 * V0.3 :
 * - since a commit (https://github.com/PrimaryFeather/Starling-Framework/commit/f0a1a18ffff727c2c83f6eeaca13aa59ecdb2bd7)
 * gives us access to the nativeStage in the Starling.as class, I just removed the dirty hack of version 0.2
 * *** PLEASE UPDATE your Starling framework to the last version *** 
 * 
 * 2011-09-23
 * V0.2 : 
 * - added Bitmap Font support for better performances and display
 * - Use a dirty hack to access to flash.display.Stage::frameRate since we have no access to the stage.frameRate in Starling
 * Now you don't have to pass the frameRate to the constructor
 * 
 * 2011-09-22
 * V0.1 : 
 * - First version, quick port of Mrdoob's Stats
 *
 **/
package starling.extensions.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	import flash.system.System;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	
	public class Stats extends Sprite
	{
		
		protected static const version:String = "V0.3";
		
		protected const WIDTH:uint = 70;
		protected const HEIGHT:uint = 100;
		
		protected var fps:uint;
		protected var ms:uint;
		protected var mem:Number;
		protected var memMax:Number;
		
		protected var frameTime:Number = 0;
		protected var frameCount:uint;
		
		protected var colors:Colors = new Colors();
		
		protected var fpsText:TextField;
		protected var msText:TextField;
		protected var memText:TextField;
		protected var memMaxText:TextField;
		
		protected var graphHeight:Number;
		protected var graphWidth:Number;
		protected var graphTexture:Texture;
		protected var graphImage:Image;
		
		protected const GRAPH_Y:Number = 50;
		
		protected var graphBuffer:BitmapData;
		protected var rectangle:Rectangle;
		
		protected var fpsGraph:uint;
		protected var memGraph:uint;
		protected var memMaxGraph:uint;
		
		protected var nativeStage:flash.display.Stage;
		
		protected var fontSize:Number = 10;
		protected var fontFamily:String = "standard 07_55";
		
		[Embed(source = "standard_07_55.png")] 
		protected static const StandardAtlas:Class;
		
		[Embed(source="standard_07_55.fnt", mimeType="application/octet-stream")] 
		protected static const StandardXML:Class;
		
		public function Stats():void
		{
			init();
		}
		
		protected function init():void
		{
			// access to nativeStage thx to commit 
			// see https://github.com/PrimaryFeather/Starling-Framework/commit/f0a1a18ffff727c2c83f6eeaca13aa59ecdb2bd7
			nativeStage = Starling.current.nativeStage;
			
			memMax = 0;
			
			var spacer:Number = 6;
			
			// bitmap font
			var fontBitmap:Bitmap = new StandardAtlas();
			var fontTexture:Texture = Texture.fromBitmap(fontBitmap);
			var fontXML:XML = XML(new StandardXML());
			TextField.registerBitmapFont(new BitmapFont(fontTexture, fontXML));
			
			fontSize = BitmapFont.NATIVE_SIZE;
			
			fpsText = new TextField(WIDTH, 14, "FPS: ?", fontFamily, fontSize, colors.fps);
			fpsText.hAlign = HAlign.LEFT;
			
			msText = new TextField(WIDTH, 14, "MS: ?", fontFamily, fontSize, colors.ms);
			msText.y = fpsText.y + fpsText.height - spacer;
			msText.hAlign = HAlign.LEFT;
			
			memText = new TextField(WIDTH, 14, "MEM: ?", fontFamily, fontSize, colors.mem);
			memText.y = msText.y + msText.height - spacer;
			memText.hAlign = HAlign.LEFT;
			
			memMaxText = new TextField(WIDTH, 14, "MAX: ?", fontFamily, fontSize, colors.memmax);
			memMaxText.y = memText.y + memText.height - spacer;
			memMaxText.hAlign = HAlign.LEFT;
			
			rectangle = new Rectangle(WIDTH - 1, GRAPH_Y, 1, HEIGHT - GRAPH_Y);
			graphHeight = HEIGHT - GRAPH_Y;
			graphWidth = WIDTH - 1;
			
			addEventListener(starling.events.Event.ADDED_TO_STAGE, onAdded);
			addEventListener(starling.events.Event.REMOVED_FROM_STAGE, destroy);
		}
		
		protected function onAdded(event:Event):void 
		{
			
			addChild(fpsText);
			addChild(msText);
			addChild(memText);
			addChild(memMaxText);
			
			graphBuffer = new BitmapData(WIDTH, HEIGHT, false, colors.bg);
			graphTexture = Texture.fromBitmapData(graphBuffer);
			graphImage = new Image(graphTexture);
			addChildAt(graphImage, 0);
			
			// since the frameRate is stuck at 60 fps, we don't need this one
			//addEventListener(TouchEvent.TOUCH, onClick);
			addEventListener(starling.events.Event.ENTER_FRAME, update);
			
		}
		
		// since the frameRate is stuck at 60 fps, we don't need this one
		protected function onClick(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this);
			
			if (touch && touch.phase == TouchPhase.BEGAN)
			{
				var mouseY:Number = touch.getLocation(this).y;
				mouseY / HEIGHT > .5 ? nativeStage.frameRate-- : nativeStage.frameRate++;
				fpsText.text = "FPS: " + fps + " / " + nativeStage.frameRate;  
			}
		}
		
		protected function destroy(event:Event):void
		{
			removeChildren();			
			graphBuffer.dispose();
			graphImage.dispose();
			removeEventListener(starling.events.Event.ENTER_FRAME, update);
			//removeEventListener(TouchEvent.TOUCH, onClick);
		}
		
		protected function update(event:EnterFrameEvent) : void 
		{
			
			frameCount++;
			frameTime += event.passedTime;
			
			ms = event.passedTime * 1000;
			msText.text = "MS: " + ms;
			
			if (frameTime > 1)
			{
				fps = int(frameCount / frameTime);
				
				fpsText.text = "FPS: " + fps + " / " + nativeStage.frameRate;
				
				mem = Number((System.totalMemory * 0.000000954).toFixed(3));
				memMax = memMax > mem ? memMax : mem;
				
				memText.text = "MEM: " + String(mem);
				memMaxText.text = "MAX: " + String(memMax);
				
				fpsGraph = Math.min(graphHeight, ( fps / nativeStage.frameRate ) * graphHeight);
				memGraph = Math.min(graphHeight, Math.sqrt(Math.sqrt(mem * 5000))) - 2;
				memMaxGraph = Math.min(graphHeight, Math.sqrt(Math.sqrt(memMax * 5000))) - 2;
				
				graphBuffer.scroll(-1, 0);
				
				graphBuffer.fillRect(rectangle, colors.bg);
				graphBuffer.setPixel(graphWidth, graphHeight - fpsGraph + GRAPH_Y, colors.fps);
				graphBuffer.setPixel(graphWidth, graphHeight - (ms >> 1) + GRAPH_Y, colors.ms);
				graphBuffer.setPixel(graphWidth, graphHeight - memGraph + GRAPH_Y, colors.mem);
				graphBuffer.setPixel(graphWidth, graphHeight - memMaxGraph + GRAPH_Y, colors.memmax);
				
				graphImage.texture.dispose();
				graphImage.texture = Texture.fromBitmapData(graphBuffer);
				
				frameTime = frameCount = 0;
			}
			
			
		}
		
	}
}

class Colors {
	
	public var bg : uint = 0x000033;
	public var fps : uint = 0xffff00;
	public var ms : uint = 0x00ff00;
	public var mem : uint = 0x00ffff;
	public var memmax : uint = 0xff0070;
	
}