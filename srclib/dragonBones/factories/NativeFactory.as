package dragonBones.factories
{
	import dragonBones.Armature;
	import dragonBones.display.NativeFastSlot;
	import dragonBones.fast.FastArmature;
	import dragonBones.fast.FastSlot;
	import dragonBones.Slot;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.display.NativeSlot;
	import dragonBones.textures.ITextureAtlas;
	import dragonBones.textures.NativeTextureAtlas;
	
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	use namespace dragonBones_internal;
	
	/**
	* Copyright 2012-2013. DragonBones. All Rights Reserved.
	* @playerversion Flash 10.0, Flash 10
	* @langversion 3.0
	* @version 2.0
	*/
	
	public class NativeFactory extends BaseFactory
	{
		/**
		 * If enable BitmapSmooth
		 */		
		public var fillBitmapSmooth:Boolean;
		
		/**
		 * If use bitmapData Texture（When using dbswf，you can use vector element，if enable useBitmapDataTexture，dbswf will be force converted to BitmapData）
		 */		
		public var useBitmapDataTexture:Boolean;
		
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
		
		override protected function generateFastArmature():FastArmature
		{
			var armature:FastArmature = new FastArmature(new Sprite());
			return armature;
		}
		
		override protected function generateFastSlot():FastSlot
		{
			var slot:FastSlot = new NativeFastSlot();
			return slot;
		}
		
		/** @private */
		override protected function generateSlot():Slot
		{
			var slot:Slot = new NativeSlot();
			return slot;
		}
		
		/** @private */
		override protected function generateDisplay(textureAtlas:Object, fullName:String, pivotX:Number, pivotY:Number):Object
		{
			var nativeTextureAtlas:NativeTextureAtlas;
			if(textureAtlas is NativeTextureAtlas)
			{
				nativeTextureAtlas = textureAtlas as NativeTextureAtlas;
			}
			
			if(nativeTextureAtlas)
			{
				var movieClip:MovieClip = nativeTextureAtlas.movieClip;
				if(useBitmapDataTexture && movieClip)
				{
					nativeTextureAtlas.movieClipToBitmapData();
				}
				
				//TO DO 问春雷
				if (!useBitmapDataTexture && movieClip && movieClip.totalFrames >= 3)
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
					var subTextureRegion:Rectangle = nativeTextureAtlas.getRegion(fullName);
					if (subTextureRegion)
					{
						var subTextureFrame:Rectangle = nativeTextureAtlas.getFrame(fullName);
						
						if (isNaN(pivotX) || isNaN(pivotX))
						{
							if (subTextureFrame)
							{
								pivotX = subTextureFrame.width / 2 + subTextureFrame.x;
								pivotY = subTextureFrame.height / 2 + subTextureFrame.y;
							}
							else
							{
								pivotX = subTextureRegion.width / 2;
								pivotY = subTextureRegion.height / 2;
							}
							
						}
						else
						{
							if(subTextureFrame)
							{
								pivotX += subTextureFrame.x;
								pivotY += subTextureFrame.y;
							}
						}
						
						var displayShape:Shape = new Shape();
						_helpMatrix.a = 1;
						_helpMatrix.b = 0;
						_helpMatrix.c = 0;
						_helpMatrix.d = 1;
						_helpMatrix.scale(1 / nativeTextureAtlas.scale, 1 / nativeTextureAtlas.scale);
						_helpMatrix.tx = -pivotX - subTextureRegion.x;
						_helpMatrix.ty = -pivotY - subTextureRegion.y;
						
						displayShape.graphics.beginBitmapFill(nativeTextureAtlas.bitmapData, _helpMatrix, false, fillBitmapSmooth);
						displayShape.graphics.drawRect(-pivotX, -pivotY, subTextureRegion.width, subTextureRegion.height);
						
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