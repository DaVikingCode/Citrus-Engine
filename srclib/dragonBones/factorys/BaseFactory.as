package dragonBones.factorys
{
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.Slot;
	import dragonBones.core.dragonBones_internal;
	import dragonBones.objects.ArmatureData;
	import dragonBones.objects.BoneData;
	import dragonBones.objects.DataParser;
	import dragonBones.objects.DecompressedData;
	import dragonBones.objects.DisplayData;
	import dragonBones.objects.SkeletonData;
	import dragonBones.objects.SkinData;
	import dragonBones.objects.SlotData;
	import dragonBones.textures.ITextureAtlas;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	use namespace dragonBones_internal;
	
	/** Dispatched after a sucessful call to parseData(). */
	[Event(name="complete", type="flash.events.Event")]
	
	public class BaseFactory extends EventDispatcher
	{
		/** @private */
		protected static const _helpMatrix:Matrix = new Matrix();
		private static const _loaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
		
		/** @private */
		protected var _dataDic:Object;
		/** @private */
		protected var _textureAtlasDic:Object;
		/** @private */
		protected var _currentDataName:String;
		/** @private */
		protected var _currentTextureAtlasName:String;
		
		public function BaseFactory(self:BaseFactory)
		{
			super(this);
			
			if(self != this)
			{
				throw new IllegalOperationError("Abstract class can not be instantiated!");
			}
			
			_loaderContext.allowCodeImport = true;
			
			_dataDic = {};
			_textureAtlasDic = {};
			
			_currentDataName = null;
			_currentTextureAtlasName = null;
		}
		
		/**
		 * Returns a SkeletonData instance.
		 * @param The name of an existing SkeletonData instance.
		 * @return A SkeletonData instance with given name (if exist).
		 */
		public function getSkeletonData(name:String):SkeletonData
		{
			return _dataDic[name];
		}
		
		/**
		 * Add a SkeletonData instance to this BaseFactory instance.
		 * @param A SkeletonData instance.
		 * @param (optional) A name for this SkeletonData instance.
		 */
		public function addSkeletonData(data:SkeletonData, name:String = null):void
		{
			if(!data)
			{
				throw new ArgumentError();
			}
			name = name || data.name;
			if(!name)
			{
				throw new ArgumentError("Unnamed data!");
			}
			if(_dataDic[name])
			{
				throw new ArgumentError();
			}
			_dataDic[name] = data;
		}
		
		/**
		 * Remove a SkeletonData instance from this BaseFactory instance.
		 * @param The name for the SkeletonData instance to remove.
		 */
		public function removeSkeletonData(name:String):void
		{
			delete _dataDic[name];
		}
		
		/**
		 * Return the TextureAtlas by that name.
		 * @param The name of the TextureAtlas to return.
		 * @return A textureAtlas.
		 */
		public function getTextureAtlas(name:String):Object
		{
			return _textureAtlasDic[name];
		}
		
		/**
		 * Add a textureAtlas to this BaseFactory instance.
		 * @param A textureAtlas to add to this BaseFactory instance.
		 * @param (optional) A name for this TextureAtlas.
		 */
		public function addTextureAtlas(textureAtlas:Object, name:String = null):void
		{
			if(!textureAtlas)
			{
				throw new ArgumentError();
			}
			if(!name && textureAtlas is ITextureAtlas)
			{
				name = textureAtlas.name;
			}
			if(!name)
			{
				throw new ArgumentError("Unnamed data!");
			}
			if(_textureAtlasDic[name])
			{
				throw new ArgumentError();
			}
			_textureAtlasDic[name] = textureAtlas;
		}
		
		/**
		 * Remove a textureAtlas from this baseFactory instance.
		 * @param The name of the TextureAtlas to remove.
		 */
		public function removeTextureAtlas(name:String):void
		{
			delete _textureAtlasDic[name];
		}
		
		/**
		 * Cleans up resources used by this BaseFactory instance.
		 * @param (optional) Destroy all internal references.
		 */
		public function dispose(disposeData:Boolean = true):void
		{
			if(disposeData)
			{
				for(var skeletonName:String in _dataDic)
				{
					(_dataDic[skeletonName] as SkeletonData).dispose();
					delete _dataDic[skeletonName];
				}
				
				for(var textureAtlasName:String in _textureAtlasDic)
				{
					(_textureAtlasDic[textureAtlasName] as ITextureAtlas).dispose();
					delete _textureAtlasDic[textureAtlasName];
				}
			}
			
			_dataDic = null;
			_textureAtlasDic = null;
			_currentDataName = null;
			_currentTextureAtlasName = null;
		}
		
		/**
		 * Build and returns a new Armature instance.
		 * @example 
		 * <listing>
		 * var armature:Armature = factory.buildArmature('dragon');
		 * </listing>
		 * @param armatureName The name of this Armature instance.
		 * @param The name of this animation.
		 * @param The name of this SkeletonData.
		 * @param The name of this textureAtlas.
		 * @param The name of this skin.
		 * @return A Armature instance.
		 */
		public function buildArmature(armatureName:String, animationName:String = null, skeletonName:String = null, textureAtlasName:String = null, skinName:String = null):Armature
		{
			var data:SkeletonData;
			var armatureData:ArmatureData;
			var animationArmatureData:ArmatureData;
			var skinData:SkinData;
			
			var armatureDataCopy:ArmatureData;
			var skinDataCopy:SkinData;
			
			if(skeletonName)
			{
				data = _dataDic[skeletonName];
				if(data)
				{
					armatureData = data.getArmatureData(armatureName);
				}
			}
			else
			{
				for(skeletonName in _dataDic)
				{
					data = _dataDic[skeletonName];
					armatureData = data.getArmatureData(armatureName);
					if(armatureData)
					{
						break;
					}
				}
			}
			
			if(!armatureData)
			{
				return null;
			}
			
			_currentDataName = skeletonName;
			_currentTextureAtlasName = textureAtlasName || skeletonName;
			
			if(animationName && animationName != armatureName)
			{
				animationArmatureData = data.getArmatureData(animationName);
				if(!animationArmatureData)
				{
					for (skeletonName in _dataDic)
					{
						data = _dataDic[skeletonName];
						animationArmatureData = data.getArmatureData(animationName);
						if(animationArmatureData)
						{
							break;
						}
					}
				}
				
				if(animationArmatureData)
				{
					skinDataCopy = animationArmatureData.getSkinData("");
				}
			}
			
			skinData = armatureData.getSkinData(skinName);
			
			var armature:Armature = generateArmature();
			armature.name = armatureName;
			armature._armatureData = armatureData;
			
			if(animationArmatureData)
			{
				armature.animation.animationDataList = animationArmatureData.animationDataList;
			}
			else
			{
				armature.animation.animationDataList = armatureData.animationDataList;
			}
			
			//
			buildBones(armature, armatureData);
			
			//
			if(skinData)
			{
				buildSlots(armature, armatureData, skinData, skinDataCopy);
			}
			
			//
			armature.advanceTime(0);
			return armature;
		}
		
		/**
		 * Add a new animation to armature.
		 * @param animationRawData (XML, JSON).
		 * @param target armature.
		 */
		public function addAnimationToArmature(animationRawData:Object, armature:Armature):void
		{
			armature._armatureData.addAnimationData(DataParser.parseAnimationDataByAnimationRawData(animationRawData,armature._armatureData));
		}
		
		/**
		 * Return the TextureDisplay.
		 * @param The name of this Texture.
		 * @param The name of the TextureAtlas.
		 * @param The registration pivotX position.
		 * @param The registration pivotY position.
		 * @return An Object.
		 */
		public function getTextureDisplay(textureName:String, textureAtlasName:String = null, pivotX:Number = NaN, pivotY:Number = NaN):Object
		{
			var textureAtlas:Object;
			if(textureAtlasName)
			{
				textureAtlas = _textureAtlasDic[textureAtlasName];
			}
			
			if(!textureAtlas && !textureAtlasName)
			{
				for (textureAtlasName in _textureAtlasDic)
				{
					textureAtlas = _textureAtlasDic[textureAtlasName];
					if(textureAtlas.getRegion(textureName))
					{
						break;
					}
					textureAtlas = null;
				}
			}
			
			if(textureAtlas)
			{
				if(isNaN(pivotX) || isNaN(pivotY))
				{
					var data:SkeletonData = _dataDic[textureAtlasName];
					if(data)
					{
						var pivot:Point = data.getSubTexturePivot(textureName);
						if(pivot)
						{
							pivotX = pivot.x;
							pivotY = pivot.y;
						}
					}
				}
				
				return generateDisplay(textureAtlas, textureName, pivotX, pivotY);
			}
			return null;
		}
		
		/** @private */
		protected function buildBones(armature:Armature, armatureData:ArmatureData):void
		{
			//按照从属关系的顺序建立
			for(var i:int = 0;i < armatureData.boneDataList.length;i ++)
			{
				var boneData:BoneData = armatureData.boneDataList[i];
				var bone:Bone = new Bone();
				bone.name = boneData.name;
				bone.inheritRotation = boneData.inheritRotation;
				bone.inheritScale = boneData.inheritScale;
				bone.origin.copy(boneData.transform);
				if(armatureData.getBoneData(boneData.parent))
				{
					armature.addBone(bone, boneData.parent);
				}
				else
				{
					armature.addBone(bone);
				}
			}
		}
		
		/** @private */
		protected function buildSlots(armature:Armature, armatureData:ArmatureData, skinData:SkinData, skinDataCopy:SkinData):void
		{
			var helpArray:Array = [];
			for each(var slotData:SlotData in skinData.slotDataList)
			{
				var bone:Bone = armature.getBone(slotData.parent);
				if(!bone)
				{
					continue;
				}
				var slot:Slot = generateSlot();
				slot.name = slotData.name;
				slot.blendMode = slotData.blendMode;
				slot._originZOrder = slotData.zOrder;
				slot._displayDataList = slotData.displayDataList;
				
				helpArray.length = 0;
				var i:int = slotData.displayDataList.length;
				while(i --)
				{
					var displayData:DisplayData = slotData.displayDataList[i];
					
					switch(displayData.type)
					{
						case DisplayData.ARMATURE:
							var displayDataCopy:DisplayData = null;
							if(skinDataCopy)
							{
								var slotDataCopy:SlotData = skinDataCopy.getSlotData(slotData.name);
								if(slotDataCopy)
								{
									displayDataCopy = slotDataCopy.displayDataList[i];
								}
							}
							
							var childArmature:Armature = buildArmature(displayData.name, displayDataCopy?displayDataCopy.name:null, _currentDataName, _currentTextureAtlasName);
							if(childArmature)
							{
								helpArray[i] = childArmature;
							}
							break;
						
						case DisplayData.IMAGE:
						default:
							helpArray[i] = generateDisplay(_textureAtlasDic[_currentTextureAtlasName], displayData.name, displayData.pivot.x, displayData.pivot.y);
							break;
						
					}
				}
				
				//==================================================
				//如果显示对象有name属性并且name属性可以设置的话，将name设置为与slot同名，dragonBones并不依赖这些属性，只是方便开发者
				for each(var displayObject:Object in helpArray)
				{
					if(displayObject && "name" in displayObject)
					{
						try
						{
							displayObject["name"] = slot.name;
						}
						catch(err:Error)
						{
						}
					}
				}
				//==================================================
				
				bone.addChild(slot);
				slot.displayList = helpArray;
				slot.changeDisplay(0);
			}
		}
		
		/** @private */
		protected function generateTextureAtlas(content:Object, textureAtlasRawData:Object):ITextureAtlas
		{
			return null;
		}
		
		/**
		 * @private
		 * Generates an Armature instance.
		 * @return Armature An Armature instance.
		 */
		protected function generateArmature():Armature
		{
			return null;
		}
		
		/**
		 * @private
		 * Generates an Slot instance.
		 * @return Slot An Slot instance.
		 */
		protected function generateSlot():Slot
		{
			return null;
		}
		
		/**
		 * @private
		 * Generates a DisplayObject
		 * @param textureAtlas The TextureAtlas.
		 * @param fullName A qualified name.
		 * @param pivotX A pivot x based value.
		 * @param pivotY A pivot y based value.
		 * @return
		 */
		protected function generateDisplay(textureAtlas:Object, fullName:String, pivotX:Number, pivotY:Number):Object
		{
			return null;
		}
		
		
		
		//==================================================
		//解析dbswf和dbpng，如果不能序列化amf3格式无法实现解析
		/** @private */
		protected var _textureAtlasLoadingDic:Object = {};
		
		/**
		 * Parses the raw data and returns a SkeletonData instance.	
		 * @example 
		 * <listing>
		 * import flash.events.Event; 
		 * import dragonBones.factorys.NativeFactory;
		 * 
		 * [Embed(source = "../assets/Dragon1.swf", mimeType = "application/octet-stream")]
		 *	private static const ResourcesData:Class;
		 * var factory:NativeFactory = new NativeFactory(); 
		 * factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
		 * factory.parseData(new ResourcesData());
		 * </listing>
		 * @param ByteArray. Represents the raw data for the whole DragonBones system.
		 * @param String. (optional) The SkeletonData instance name.
		 * @param Boolean. (optional) flag if delay animation data parsing. Delay animation data parsing can reduce the data paring time to improve loading performance.
		 * @param Dictionary. (optional) output parameter. If it is not null, and ifSkipAnimationData is true, it will be fulfilled animationData, so that developers can parse it later.
		 * @return A SkeletonData instance.
		 */
		public function parseData(bytes:ByteArray, dataName:String = null, ifSkipAnimationData:Boolean = false, outputAnimationDictionary:Dictionary = null):SkeletonData
		{
			if(!bytes)
			{
				throw new ArgumentError();
			}
			var decompressedData:DecompressedData = DataParser.decompressData(bytes);
			
			var data:SkeletonData = DataParser.parseData(decompressedData.dragonBonesData, ifSkipAnimationData, outputAnimationDictionary);
			
			dataName = dataName || data.name;
			addSkeletonData(data, dataName);
			var loader:Loader = new Loader();
			loader.name = dataName;
			_textureAtlasLoadingDic[dataName] = decompressedData.textureAtlasData;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			loader.loadBytes(decompressedData.textureBytes, _loaderContext);
			decompressedData.dispose();
			return data;
		}
		
		/** @private */
		protected function loaderCompleteHandler(e:Event):void
		{
			e.target.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
			var loader:Loader = e.target.loader;
			var content:Object = e.target.content;
			loader.unloadAndStop();
			
			var name:String = loader.name;
			var textureAtlasRawData:Object = _textureAtlasLoadingDic[name];
			delete _textureAtlasLoadingDic[name];
			if(name && textureAtlasRawData)
			{
				if (content is Bitmap)
				{
					content =  (content as Bitmap).bitmapData;
				}
				else if (content is Sprite)
				{
					content = (content as Sprite).getChildAt(0) as MovieClip;
				}
				else
				{
					//
				}
				
				var textureAtlas:Object = generateTextureAtlas(content, textureAtlasRawData);
				addTextureAtlas(textureAtlas, name);
				
				name = null;
				for(name in _textureAtlasLoadingDic)
				{
					break;
				}
				//
				if(!name && this.hasEventListener(Event.COMPLETE))
				{
					this.dispatchEvent(new Event(Event.COMPLETE));
				}
			}
		}
		//==================================================
	}
}