package dragonBones.factorys
{
	import dragonBones.Armature;
	import dragonBones.Slot;
	import dragonBones.display.NativeDisplayBridge;
	import dragonBones.textures.ITextureAtlas;
	import dragonBones.textures.NativeTextureAtlas;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/
	
	public class NativeFactory extends BaseFactory
	{
		public var fillBitmapSmooth:Boolean;
		
		public function NativeFactory()
		{
			super(this);
		}
		
		/** @private */
		override protected function generateTextureAtlas(content:Object, textureAtlasRawData:Object):ITextureAtlas
		{
			var textureAtlas:NativeTextureAtlas = new NativeTextureAtlas(content, textureAtlasRawData, 1, false);
			return textureAtlas;
		}
		
		/** @private */
		override protected function generateArmature():Armature
		{
			var display:Sprite = new Sprite();
			var armature:Armature = new Armature(display);
			return armature;
		}
		
		/** @private */
		override protected function generateSlot():Slot
		{
			var slot:Slot = new Slot(new NativeDisplayBridge());
			return slot;
		}
		
		/** @private */
		override protected function generateDisplay(textureAtlas:Object, fullName:String, pivotX:Number, pivotY:Number):Object
		{
			if(textureAtlas is NativeTextureAtlas)
			{
				var nativeTextureAtlas:NativeTextureAtlas = textureAtlas as NativeTextureAtlas;
			}
			
			if(nativeTextureAtlas)
			{
				var movieClip:MovieClip = nativeTextureAtlas.movieClip;
				if (movieClip && movieClip.totalFrames >= 3)
				{
					movieClip.gotoAndStop(movieClip.totalFrames);
					movieClip.gotoAndStop(fullName);
					if (movieClip.numChildren > 0)
					{
						try
						{
							var displaySWF:Object = movieClip.getChildAt(0);
							displaySWF.x = 0;
							displaySWF.y = 0;
							return displaySWF;
						}
						catch(e:Error)
						{
							throw new Error("Can not get the movie clip, please make sure the version of the resource compatible with app version!");
						}
					}
				}
				else if(nativeTextureAtlas.bitmapData)
				{
					var subTextureData:Rectangle = nativeTextureAtlas.getRegion(fullName);
					if (subTextureData)
					{
						var displayShape:Shape = new Shape();
						_helpMatrix.a = 1;
						_helpMatrix.b = 0;
						_helpMatrix.c = 0;
						_helpMatrix.d = 1;
						_helpMatrix.scale(1 / nativeTextureAtlas.scale, 1 / nativeTextureAtlas.scale);
						_helpMatrix.tx = -pivotX - subTextureData.x;
						_helpMatrix.ty = -pivotY - subTextureData.y;
						
						displayShape.graphics.beginBitmapFill(nativeTextureAtlas.bitmapData, _helpMatrix, false, fillBitmapSmooth);
						displayShape.graphics.drawRect(-pivotX, -pivotY, subTextureData.width, subTextureData.height);
						
						return displayShape;
					}
				}
				else
				{
					throw new Error();
				}
			}
			return null;
		}
	}
}